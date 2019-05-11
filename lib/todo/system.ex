defmodule Todo.System do
  use Supervisor

  # Client
  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  # Server
  def init(_) do
    Supervisor.init([Todo.ProcessRegistry, Todo.Cache, Todo.Database], strategy: :one_for_one)
  end
end
