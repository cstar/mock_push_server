defmodule ApnsHandler do
    require Logger

    def init(%{method: "POST", headers: headers} = req, state) do
        token  = :cowboy_req.binding(:token, req)
        MockPushServer.latency
        Logger.info "method=POST;headers=#{inspect(headers)};token=#{token}"
        {:ok, body, req} = :cowboy_req.read_body(req)
        Logger.debug "body=#{inspect body}"
        prepare_reply(body, headers, token, req, state)
    end

    def init(req, state) do
        reply_error(405, "MethodNotAllowed", req, state)
    end

    def prepare_reply(_body, _headers, token, req, state) when token == :undefined do
        reply_error(400, "MissingDeviceToken", req, state) 
    end

    def prepare_reply(_body, _headers, "CustomError=" <> error, req, state) do
        {code, error} = get_code(error)
        reply_error(code, error, req, state)
    end

    def prepare_reply(_body, %{"apns-id" => apns_id} = _headers, _token, req, state) do
        req = :cowboy_req.reply 200, %{"content-type" => "application/json", "apns-id" => apns_id}, "", req
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

    def get_code(error) do
        case error do
            "BadCollapseId" = error -> {400, error}
            "BadDeviceToken" = error -> {400, error}
            "BadExpirationDate" = error -> {400, error}
            "BadMessageId" = error -> {400, error}
            "BadPriority" = error -> {400, error}
            "BadTopic" = error -> {400, error}
            "DeviceTokenNotForTopic" = error -> {400, error}
            "DuplicateHeaders" = error -> {400, error}
            "IdleTimeout" = error -> {400, error}
            "MissingDeviceToken" = error -> {400, error}
            "MissingTopic" = error -> {400, error}
            "PayloadEmpty" = error -> {400, error}
            "TopicDisallowed" = error -> {400, error}
            "BadCertificate" = error -> {403, error}
            "BadCertificateEnvironment" = error -> {403, error}
            "ExpiredProviderToken" = error -> {403, error}
            "Forbidden" = error -> {403, error}
            "InvalidProviderToken" = error -> {403, error}
            "MissingProviderToken" = error -> {403, error}
            "BadPath" = error -> {404, error}
            "MethodNotAllowed" = error -> {405, error}
            "Unregistered" = error -> {410, error}
            "PayloadTooLarge" = error -> {413, error}
            "TooManyProviderTokenUpdates" = error -> {429, error}
            "TooManyRequests" = error -> {429, error}
            "InternalServerError" = error -> {500, error}
            "ServiceUnavailable" = error -> {503, error}
            "Shutdown" = error -> {503, error}
            _  -> {400, "PayloadEmpty"}
        end
    end
end

# curl -XPOST -H "Content-Type: application/json" -H "apns-id: toto" -H "apns-topic: topic" -d '{"aps": {"alert" : "test_msg", "badge": 3}}' https://localhost:8443/3/device/toto