defmodule ApnsHandler do
    require Logger

    def init(%{method: "POST", headers: headers} = req, state) do
        token  = :cowboy_req.binding(:token, req)
        Logger.info "method=POST;headers=#{inspect(headers)};token=#{token}"
        {:ok, body, req} = :cowboy_req.read_body(req)
        Logger.debug "body=#{inspect body}"
        prepare_reply(body, headers, token, req, state)
    end

    def init(req, state) do
        reply_error(405, "MethodNotAllowed", req, state)
    end

    def prepare_reply(body, %{"apns-id" => apns_id} = headers, token, req, state) do
        req = :cowboy_req.reply 200, %{"content-type" => "application/json", "apns-id" => apns_id}, "Hello XWorld", req
        {:ok, req, state}
    end

    def prepare_reply(_body, _headers, _token, req, state) do
        reply_error(400, "BadMessageId", req, state) 
    end


    def reply_error(code, reason, req, state) do
        {:ok, body} = Poison.encode %{reason: reason}
        req = :cowboy_req.reply code, %{"content-type" => "application/json"}, body, req
        {:ok, req, state}
    end
end

# curl -XPOST -H "Content-Type: application/json" -H "apns-id: toto" -H "apns-topic: topic" -d '{"aps": {"alert" : "test_msg", "badge": 3}}' https://localhost:8443/3/device/toto