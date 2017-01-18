defmodule MockPushServer.Mixfile do
  use Mix.Project

  def project do
    [app: :mock_push_server,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end


  def application do
    [mod: {MockPushServer, []},
     applications: [:logger, :cowboy, :cowlib, :ranch] ++ env_mods(Mix)]
  end

  def env_mods :dev do
    [:exsync]
  end

  def env_mods _ do
    []
  end

  defp deps do
    [
     {:cowboy, github: "ninenines/cowboy", tag: "2.0.0-pre.4"},
     {:poison, "~> 2.0 or ~> 3.0"},
     {:kadabra,  github: "cstar/kadabra", override: true},
     {:exsync, "~> 0.1", only: :dev},
     {:uuid, "~> 1.1"}
    ]
  end
end
