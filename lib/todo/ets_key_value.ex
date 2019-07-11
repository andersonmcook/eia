defmodule ETSKeyValue do
  use GenServer

  # Client
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def put(key, value) do
    :ets.insert(__MODULE__, {key, value})
  end

  def get(key) do
    __MODULE__
    |> :ets.lookup(key)
    |> case do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  # Server
  def init(_) do
    ref = :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true])
    {:ok, ref}
  end
end
