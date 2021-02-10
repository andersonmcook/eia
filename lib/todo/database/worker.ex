defmodule Todo.Database.Worker do
  use GenServer

  # Client
  def start_link(db_folder: db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
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
    value =
      key
      |> file_name(state)
      |> File.read()
      |> case do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, value, state}
  end

  defp file_name(key, db_folder) do
    Path.join([db_folder, to_string(key)])
  end
end
