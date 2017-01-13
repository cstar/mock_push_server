defmodule H2Client do

    def init(host, port, opts \\ []) do
        {:ok, pid} = Kadabra.open(host,  port, opts)
        pid
    end

    def request(pid, headers, body) do
        Kadabra.request(pid, headers, body)
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

    def local(pid) do
        headers =  [
          {":method", "POST"},
          {"apns-id", "toto"},
          {":path", "/3/device/toto"},
        ]
        request(pid, headers, "toto")
    end

    def local_error(pid, message) do
        headers =  [
          {":method", "POST"},
          {"apns-id", "toto"},
          {":path", "/3/device/CustomError=#{message}"},
        ]
        request(pid, headers, "toto")
    end

    def golang do
        headers =  [
          {":method", "PUT"},
          {":path", "/ECHO"},
        ]
        request('http2.golang.org', :https, headers, "toto")
    end

end