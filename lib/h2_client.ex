defmodule H2Client do

    def init(host, port, opts \\ []) do
        {:ok, pid} = Kadabra.open(host,  port, opts)
        pid
    end

    def request(pid, headers, body) do
        IO.puts "pid = #{inspect pid}"
        res =  Kadabra.request(pid, headers, body)
        IO.puts "res = #{inspect res}"
        receive do
          {:end_stream, %Kadabra.Stream{} = stream} ->
            {:ok, stream}
        after 5_000 ->
          {:error, :timeout}
        end
    end

    def request(host, port, headers, body, opts \\ []) do
       pid = init(host,  port, opts)
       request(pid, headers, body)
    end

    def init_local() do
        init('localhost', :https, verify: :verify_none, port: 8443)
    end

    def apns_local(pid) do
        headers =  [
          {":method", "POST"},
          {"apns-id", "my-app"},
          {":path", "/3/device/token"},
        ]
        request(pid, headers, ~s'{"aps" : { "alert" : "Message received from Bob" }}')
    end

    def apns_local_error(pid, message) do
        headers =  [
          {":method", "POST"},
          {"apns-id", "my-app"},
          {":path", "/3/device/error:#{message}"},
        ]
        request(pid, headers, ~s'{"aps": {"alert" : "Message received from Bob"}}')
    end

    def fcm_local(pid) do
      headers = [
        {":method", "POST"},
        {":path", "/fcm/send"},
        {"authorization", "key=thiskey" },
        {"content-type", "application/json" }
      ]
      request(pid, headers, ~s'{"to": "thisregid", "data": {"x": 12}}' )
    end

    def golang do
        headers =  [
          {":method", "PUT"},
          {":path", "/ECHO"},
        ]
        request('http2.golang.org', :https, headers, "this should be all caps")
    end
end