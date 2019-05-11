defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"
  @worker_length 3

  # Client
  def start do
    IO.puts("Starting database server.")
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  # Server
  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)

    [@db_folder]
    |> Stream.cycle()
    |> Stream.take(@worker_length)
    |> Stream.with_index()
    |> Stream.map(fn {folder, index} ->
      {:ok, pid} = Todo.DatabaseWorker.start(folder)
      {index, pid}
    end)
    |> Map.new()
    |> (&{:ok, &1}).()
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, state) do
    worker =
      key
      |> :erlang.phash2(@worker_length)
      |> (&Map.get(state, &1)).()

    {:reply, worker, state}
  end
end
