defmodule GcmHandler do
    
    def init %{method: "POST", headers: headers} = req, state do
      MockPushServer.latency
      {:ok, body, req} = :cowboy_req.read_body(req)
      case Poison.decode(body) do
        {:ok, val} ->
          prepare_reply(val, headers, req, state)
        _ ->
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

    def prepare_reply(body, headers, req, state) do
        req = :cowboy_req.reply 200, %{"content-type" => "application/json"}, "", req
        {:ok, req, state}
    end

    def reply_error(code, reason, req, state) do
      {:ok, body} = Poison.encode %{reason: reason}
      req = :cowboy_req.reply code, %{"content-type" => "application/json"}, body, req
      {:ok, req, state}
    end
end