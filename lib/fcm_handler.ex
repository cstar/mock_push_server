defmodule FcmHandler do
    require Logger
    def init %{method: "POST", headers: headers} = req, state do
      MockPushServer.latency "fcm"
      {:ok, body, req} = :cowboy_req.read_body(req)
      case Poison.decode(body) do
        {:ok, val} ->
          prepare_reply(val, headers, req, state)
        _ ->
          Logger.info "Invalid JSON"
          body = "JSON_PARSING_ERROR: Unexpected character (n) at position 0.\n"
          req = :cowboy_req.reply 400, %{"content-type" => "text/plain; charset=UTF-8"}, body, req
          {:ok, req, state}
      end
    end

    def init(%{method: method} = req, state) do
      body = "<HTML>\n<HEAD>\n<TITLE>HTTP method #{method} is not supported by this URL</TITLE>\n</HEAD>\n<BODY BGCOLOR=\"#FFFFFF\" TEXT=\"#000000\">\n<H1>HTTP method #{method} is not supported by this URL</H1>\n<H2>Error 405</H2>\n</BODY>\n</HTML>\n"
      req = :cowboy_req.reply 405, %{"content-type" => "text/plain; charset=UTF-8"}, body, req
      {:ok, req, state}
    end

    def prepare_reply(%{"to" => recipient} = request, %{"authorization" => "key=" <> _ok} = headers, req, state) do
        process_body([recipient], request, %{}, req, state)
    end

    def prepare_reply(%{"registration_ids" => recipients} = request, %{"authorization" => "key=" <> _ok} = headers, req, state) do
        process_body(recipients, request, %{}, req, state)
    end

    def reply_error(code, reason, req, state) do
      {:ok, body} = Poison.encode %{reason: reason}
      req = :cowboy_req.reply code, %{"content-type" => "application/json"}, body, req
      {:ok, req, state}
    end

    def process_body(recipients, request, opts, req, state) do
      Logger.info "Sending reply to #{length(recipients)}"
      empty_response = %{
          multicast_id: UUID.uuid4,
          success: 0,
          failure: 0, 
          canonical_ids: 0,
          results: []
        }
      message_id = UUID.uuid4
      response = recipients
          |> List.foldl({message_id, empty_response}, &process_recipient/2)
          |> elem(1)
          |> Map.update!( :results, &Enum.reverse/1)
          |> Poison.encode!
      
      req = :cowboy_req.reply 200, %{"content-type" => "application/json"}, response, req
      {:ok, req, state}
    end

    def process_recipient "error:" <> error,  {message_id, %{failure: failure, results: results} = response} do
      { message_id, %{response |  failure: (failure + 1),
                                  results: [%{error: error} | results]}}
    end

    def process_recipient "update:" <> new_registration, {message_id, %{canonical_ids: cids, success: success, results: results} = response} do
      {message_id, %{response | success: success + 1, 
                                canonical_ids: cids + 1, 
                                results: [%{message_id: message_id, registration_id: new_registration} | results]}}
    end

    def process_recipient recipient, {message_id, %{success: success, results: results} = response} do
      {message_id, %{response | success: success + 1, results: [ %{message_id: message_id} | results]}}
    end
end