defmodule LatencyHandler do
    require Logger
    def init(%{method: "PUT"} = req, state) do
        {:ok, body, req} = :cowboy_req.read_body(req)
        ms = String.to_integer body
        MockPushServer.latency ms
        req = :cowboy_req.reply 200, %{"content-type" => "application/json"}, "{'message': 'latency set to #{ms} ms'}", req
        {:ok, req, state}
    rescue e ->
        req = :cowboy_req.reply 400, %{"content-type" => "application/json"}, "{'error': #{inspect e.message}}", req
        {:ok, req, state}
    end
end