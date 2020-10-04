defmodule Datalevi.FsSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    dirs = Datalevi.directory
    children = [%{
      id: FileSystem,
      start: {FileSystem, :start_link, [[dirs: [dirs], name: Datalevi.FileSystem]]},
      restart: :permanent}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
