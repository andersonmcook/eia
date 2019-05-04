defmodule Todo.Cache do
  use GenServer

  # Client
  def start do
    GenServer.start(__MODULE__, %{})
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  # Server
  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, state) do
    case Map.fetch(state, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, state}

      :error ->
        {:ok, todo_server} = Todo.Server.start()
        {:reply, todo_server, Map.put(state, todo_list_name, todo_server)}
    end
  end
end
