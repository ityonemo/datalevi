defmodule Datalevi.Application do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Datalevi.Repo,
      DataleviWeb.Telemetry,
      {Phoenix.PubSub, name: Datalevi.PubSub},
      DataleviWeb.Endpoint,
      startup_tasks(),
      Datalevi.FsSupervisor, # must come after startup tasks.
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Datalevi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    DataleviWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @tasks ~w(set_root_configured? set_directory)a

  def startup_tasks do
    tasks = Enum.map(@tasks, &%{id: &1,
      start: {Task, :start_link, [__MODULE__, &1, []]},
      restart: :transient
    })

    %{
      id: Datalevi.StartupTasks,
      start: {Supervisor, :start_link, [tasks, [strategy: :one_for_one]]},
      restart: :transient,
      type: :supervisor
    }
  end

  def set_root_configured? do
    configured? = Datalevi.Repo.aggregate(Datalevi.Accounts.User, :count) > 0
    unless configured?, do: Logger.warn("detected that root is not configured")
    Application.put_env(:datalevi, :root_configured?, configured?)
  end

  @directory Application.compile_env(:datalevi, :directory)
  def set_directory do
    directory = Path.absname(@directory ||
    Application.get_env(:datalevi, :directory) ||
    File.cwd!)

    Logger.info("root directory set to #{directory}")

    Application.put_env(:datalevi, :directory, directory)

    # kick over the fs supervisor and get it to rebind to the directory
    Process.sleep(200)

    Datalevi.FsSupervisor
    |> Process.whereis
    |> Process.exit(:kill)
  end
end
