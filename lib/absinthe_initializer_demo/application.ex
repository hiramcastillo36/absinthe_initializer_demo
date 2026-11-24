defmodule AbsintheInitializerDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AbsintheInitializerDemo.Auth.SessionCache.ETS,
      AbsintheInitializerDemo.Auth.RateLimiter,
      AbsintheInitializerDemoWeb.Telemetry,
      AbsintheInitializerDemo.Repo,
      {DNSCluster, query: Application.get_env(:absinthe_initializer_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AbsintheInitializerDemo.PubSub},
      # Start a worker by calling: AbsintheInitializerDemo.Worker.start_link(arg)
      # {AbsintheInitializerDemo.Worker, arg},
      # Start to serve requests, typically the last entry
      AbsintheInitializerDemoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AbsintheInitializerDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AbsintheInitializerDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
