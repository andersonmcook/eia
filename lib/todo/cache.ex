defmodule Todo.Cache do
  use GenServer

  # Client
  def start_link(_) do
    IO.puts("Starting to-do cache.")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  # Server
  @impl GenServer
  def init(state) do
    case Todo.Database.start_link(nil) do
      {:ok, _} -> {:ok, state}
      {:error, {:already_started, _}} -> {:ok, state}
      error -> error
    end
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, state) do
    case Map.fetch(state, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, state}

      :error ->
        {:ok, todo_server} = Todo.Server.start_link(todo_list_name)
        {:reply, todo_server, Map.put(state, todo_list_name, todo_server)}
    end
  end
end
