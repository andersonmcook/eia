defmodule SimpleRegistry do
  use GenServer

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(name) do
    __MODULE__
    |> GenServer.whereis()
    |> Process.link()

    :ets.insert_new(__MODULE__, {name, self()})
    :ok
  end

  def whereis(name) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
      [{^name, pid}] -> pid
      _ -> nil
    end
  end

  # Server
  def init(_) do
    Process.flag(:trap_exit, true)
    ref = :ets.new(__MODULE__, [:named_table, :public])
    {:ok, ref}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    IO.inspect(pid, label: "Deleting")
    :ets.match_delete(__MODULE__, {:_, pid})
    {:noreply, state}
  end
end
