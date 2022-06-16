defmodule Frontline.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Frontline.Repo,
      # Start the Telemetry supervisor
      FrontlineWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Frontline.PubSub},
      # Start the Endpoint (http/https)
      FrontlineWeb.Endpoint,
      # Start a worker by calling: Frontline.Worker.start_link(arg)
      # {Frontline.Worker, arg}
      Frontline.Query
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Frontline.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FrontlineWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
