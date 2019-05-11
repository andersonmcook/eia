defmodule Todo.DatabaseWorker do
  use GenServer

  # Client
  def start_link(db_folder) do
    IO.puts("Starting database worker.")
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
  end

  # Server
  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    key
    |> file_name(state)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    key
    |> file_name(state)
    |> File.read()
    |> case do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
    |> (&{:reply, &1, state}).()
  end

  defp file_name(key, db_folder) do
    key
    |> Kernel.to_string()
    |> (&Path.join(db_folder, &1)).()
  end
end
