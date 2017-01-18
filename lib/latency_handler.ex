defmodule LatencyHandler do
    require Logger
    def init(%{method: "PUT"} = req, state) do
        {:ok, body, req} = :cowboy_req.read_body(req)
        body 
            |> Poison.decode!
            |> Enum.each(fn({service, latency}) -> MockPushServer.latency(service, latency) end)
        req = :cowboy_req.reply 200, %{"content-type" => "application/json"}, body, req
        {:ok, req, state}
    rescue e ->
        req = :cowboy_req.reply 400, %{"content-type" => "application/json"}, "{'error': #{inspect e.message}}", req
        {:ok, req, state}
    end
end