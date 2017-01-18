defmodule MockPushServer do
  use Application

  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    start_env Mix.env
    :ets.new(:latency, [:named_table, :set, :public,  read_concurrency: true])
    latency "fcm", 0
    latency "apns", 0
    start_cowboy
  end


  def start_env( :dev), do: ExSync.start
  def start_env( _), do: :ok

  def start_cowboy do

       dispatch = :cowboy_router.compile([
          {:_,
           [ {"/3/device/:token", ApnsHandler, []},
             {"/fcm/send", FcmHandler, []},
             {"/latency", LatencyHandler, []}
           ]}
        ])
       Logger.info "Starting server on port #{config[:port]}"
        {:ok, _} = :cowboy.start_tls(
          :http, 100,
          config,
          %{env: %{dispatch: dispatch}}
        )
  end

  def config do
    [port: Application.get_env(:mock_push_server, :port)    ||  8443,
     keyfile: Application.get_env(:mock_push_server, :keyfile) || "priv/key.pem",
     certfile: Application.get_env(:mock_push_server, :certfile) || "priv/cert.pem"]
  end

  def latency service, ms do
    :ets.insert(:latency, {service, ms})
    Logger.info "#{service}: Latency set to #{ms} ms"
    ms
  end

  def latency service do
    [{service, ms}] = :ets.lookup :latency, service
    Logger.debug "#{service}: Waiting for #{ms} ms"
    :timer.sleep ms
  end

end
