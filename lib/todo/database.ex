defmodule Todo.Database do
  alias __MODULE__.Worker

  @db_folder "./persist"
  @pool_size 3

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Worker,
        size: @pool_size
      ],
      [@db_folder]
    )
  end

  def store(key, data) do
    :poolboy.transaction(__MODULE__, &Worker.store(&1, key, data))
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, &Worker.get(&1, key))
  end
end
