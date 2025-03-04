defmodule ProcessarPixParticipantes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ProcessarPixParticipantesWeb.Telemetry,
      # Start the Ecto repository
      ProcessarPixParticipantes.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ProcessarPixParticipantes.PubSub},
      # Start Finch
      {Finch, name: ProcessarPixParticipantes.Finch},
      # Start the Endpoint (http/https)
      ProcessarPixParticipantesWeb.Endpoint,
      # Start a worker by calling: ProcessarPixParticipantes.Worker.start_link(arg)
      # {ProcessarPixParticipantes.Worker, arg}
      {ProcessarPixParticipantes.SendWorker, []},
      {ProcessarPixParticipantes.ReceiverWorker, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProcessarPixParticipantes.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProcessarPixParticipantesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
