defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  # Client
  def start_link(name) do
    IO.puts("Starting to-do server for #{name}.")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
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
    {:ok, state, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, state) do
    {:noreply, {state, Todo.Database.get(state) || Todo.List.new()}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {_, todo_list} = state) do
    {:reply, Todo.List.entries(todo_list, date), state, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    todo_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, todo_list)
    {:noreply, {name, todo_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
