defmodule Todo.Server do
  use GenServer

  # Client
  def start(name) do
    GenServer.start(__MODULE__, name)
  end

  def add_entry(todo_server, %{date: _, title: _} = entry) do
    GenServer.cast(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  # Server
  @impl GenServer
  def init(name) do
    {:ok, name, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, name) do
    {:noreply, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {_, todo_list} = state) do
    {:reply, Todo.List.entries(todo_list, date), state}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    todo_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, todo_list)
    {:noreply, {name, todo_list}}
  end
end
