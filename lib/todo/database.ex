defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  # Client
  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  # Server
  @impl GenServer
  def init(state) do
    @db_folder
    |> File.mkdir()
    |> case do
      :ok -> {:ok, state}
      {:error, :eexist} -> {:ok, state}
      error -> error
    end
  end

  @impl GenServer
  def handle_cast({:store, key, data}, state) do
    key
    |> file_name()
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    key
    |> file_name()
    |> File.read()
    |> case do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
    |> (&{:reply, &1, state}).()
  end

  defp file_name(key) do
    key
    |> Kernel.to_string()
    |> (&Path.join(@db_folder, &1)).()
  end
end
