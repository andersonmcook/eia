defmodule Todo.List do
  defstruct auto_id: 1,
            entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %__MODULE__{}, &add_entry(&2, &1))
  end

  def add_entry(tl, entry) do
    %__MODULE__{
      tl
      | auto_id: tl.auto_id + 1,
        entries: Map.put(tl.entries, tl.auto_id, Map.put(entry, :id, tl.auto_id))
    }
  end

  def entries(%{entries: entries}, date) do
    entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(&elem(&1, 1))
  end

  def update_entry(tl, id, f) do
    case Map.fetch(tl.entries, id) do
      :error ->
        tl

      {:ok, entry} ->
        %{id: ^id} = new_entry = f.(entry)
        %__MODULE__{tl | entries: Map.put(tl.entries, id, new_entry)}
    end
  end
end

defimpl String.Chars, for: Todo.List do
  def to_string(_), do: "#Todo.List"
end

defimpl Collectable, for: Todo.List do
  def into(original), do: {original, &cb/2}

  defp cb(tl, {:cont, entry}), do: Todo.List.add_entry(tl, entry)
  defp cb(tl, :done), do: tl
  defp cb(_, :halt), do: :ok
end
