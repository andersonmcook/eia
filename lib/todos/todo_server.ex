defmodule TodoServer do
  use GenServer

  # Client
  def start_link do
    GenServer.start_link(__MODULE__, TodoList.new(), name: __MODULE__)
  end

  def add_entry(%{date: _, title: _} = entry) do
    GenServer.cast(__MODULE__, {:add_entry, entry})
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  # Server
  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state) do
    {:reply, TodoList.entries(state, date), state}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, state) do
    {:noreply, TodoList.add_entry(state, entry)}
  end
end
