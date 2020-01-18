defmodule Schedulex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    config = Application.get_env(:schedulex, :jobs)

    children = [
      # Starts a worker by calling: Schedulex.Worker.start_link(config)
      {Schedulex.Worker, config},
      {Task.Supervisor, name: Schedulex.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Schedulex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
