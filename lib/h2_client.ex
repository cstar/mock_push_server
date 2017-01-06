#defmodule H2Client do
#
#    def request() do
#        {:ok, pid} = Kadabra.open('localhost', :https, port: 8443)
#    
#        path = "/3/device/toto" # Route echoes PUT body in uppercase
#        body = "sample echo request"
#        headers = [
#          {":method", "POST"},
#          {"aps-id", "toto"},
#          {":path", path},
#        ]
#    
#        Kadabra.request(pid, headers, body)
#    
#        receive do
#          {:end_stream, %Kadabra.Stream{} = stream} ->
#          IO.inspect stream
#        after 5_000 ->
#          IO.puts "Connection timed out."
#        end
#    end
#end

defmodule H2Client do

    def request(host, port, headers, body, opts \\ []) do
        {:ok, pid} = Kadabra.open(host,  port, opts)
        IO.puts "pid = #{inspect pid}"
        res =  Kadabra.request(pid, headers, body)
        IO.puts "res = #{inspect res}"
        receive do
          {:end_stream, %Kadabra.Stream{} = stream} ->
          IO.inspect stream
        after 5_000 ->
          IO.puts "Connection timed out."
        end
    end

    def local do
        headers =  [
          {":method", "POST"},
          {"apns-id", "toto"},
          {":path", "/3/device/toto"},
        ]
        request('localhost', :https, headers, "toto", verify: :verify_none, port: 8443)
    end

    def golang do
        headers =  [
          {":method", "PUT"},
          {":path", "/ECHO"},
        ]
        request('http2.golang.org', :https, headers, "toto")
    end

end