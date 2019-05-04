defmodule Todo.Server do
  use GenServer

  # Client
  def start do
    GenServer.start(__MODULE__, Todo.List.new())
  end

  def add_entry(todo_server, %{date: _, title: _} = entry) do
    GenServer.cast(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  # Server
  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, state) do
    {:noreply, Todo.List.add_entry(state, entry)}
  end
end
