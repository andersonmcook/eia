defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    bob = Todo.Cache.server_process("bob")

    refute bob == Todo.Cache.server_process("alice")
    assert bob == Todo.Cache.server_process("bob")
  end

  test "todo operations" do
    alice = Todo.Cache.server_process("alice")
    Todo.Server.add_entry(alice, %{date: ~D[2019-05-04], title: "Dentist"})
    entries = Todo.Server.entries(alice, ~D[2019-05-04])

    assert [%{date: ~D[2019-05-04], title: "Dentist"}] = entries
  end

  test "persistence" do
    john = Todo.Cache.server_process("john")
    Todo.Server.add_entry(john, %{date: ~D[2018-12-20], title: "Shopping"})
    assert 1 == length(Todo.Server.entries(john, ~D[2018-12-20]))

    entries =
      "john"
      |> Todo.Cache.server_process()
      |> Todo.Server.entries(~D[2018-12-20])

    assert [%{date: ~D[2018-12-20], title: "Shopping"}] = entries
  end
end
