defmodule TodoServer do
  def start do
    spawn(fn -> loop(TodoList.new()) end)
  end

  def add_entry(server, entry) do
    send(server, {:add_entry, entry})
  end

  def entries(server, date) do
    send(server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
      _ -> []
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(state) do
    receive do
      {:add_entry, entry} ->
        TodoList.add_entry(state, entry)

      {:entries, caller, date} ->
        send(caller, {:todo_entries, TodoList.entries(state, date)})
        state

      _ ->
        state
    end
    |> loop()
  end
end
