defmodule KeyValue do
  use GenServer

  # Client
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  # Server
  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl true
  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end
end
