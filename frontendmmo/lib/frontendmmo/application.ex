defmodule Frontendmmo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FrontendmmoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Frontendmmo.PubSub},
      # Start the Endpoint (http/https)
      FrontendmmoWeb.Endpoint,
      # Start a worker by calling: Frontendmmo.Worker.start_link(arg)
      # {Frontendmmo.Worker, arg}
      Frontendmmo.PlayerPublisher,
      Frontendmmo.LogDb,
      Frontendmmo.WebserverConsumer,
      Frontendmmo.MovementPublisher,
      Frontendmmo.AttackPublisher
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Frontendmmo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FrontendmmoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
