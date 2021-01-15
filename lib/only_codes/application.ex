defmodule OnlyCodes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      OnlyCodes.Repo,
      # Start the Telemetry supervisor
      OnlyCodesWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: OnlyCodes.PubSub},
      # Start the Endpoint (http/https)
      OnlyCodesWeb.Endpoint,
      LiveMonitorSupervisor
      # Start a worker by calling: OnlyCodes.Worker.start_link(arg)
      # {OnlyCodes.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OnlyCodes.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OnlyCodesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
