defmodule ExScheduler.WorkerTest do
  use ExUnit.Case
  alias ExScheduler.Worker

  defmodule Hello do
    def send(pid), do: send(pid, :hello)
    def perform(), do: :ets.insert(:table, {:foo, :bar})
    def add(), do: :ets.insert(:table, {:foo, :bar})
  end

  test "run every second" do
    config = [%{cron: "* * * * * *", module: Hello, function: :send, args: [self()]}]
    GenServer.start_link(Worker, config)
    assert_receive :hello, 1_100
  end

  test "run perform/0 function by default" do
    :ets.new(:table, [:named_table, :duplicate_bag, :public])
    config = [%{cron: "* * * * * *", module: Hello}]

    GenServer.start_link(Worker, config)
    Process.sleep(1_100)
    list = :ets.lookup(:table, :foo)
    assert length(list) == 1
  end

  test "run function with 0 arity by default" do
    :ets.new(:table, [:named_table, :duplicate_bag, :public])
    config = [%{cron: "* * * * * *", module: Hello, function: :add}]

    GenServer.start_link(Worker, config)
    Process.sleep(1_100)
    list = :ets.lookup(:table, :foo)
    assert length(list) == 1
  end

  test "run every second for 5 times" do
    :ets.new(:table, [:named_table, :duplicate_bag, :public])
    config = [%{cron: "* * * * * *", module: Hello}]

    GenServer.start_link(Worker, config)
    Process.sleep(5_100)
    list = :ets.lookup(:table, :foo)
    assert length(list) == 5
  end

  test "run every 2 seconds" do
    config = [%{cron: "*/2 * * * * *", module: Hello, function: :send, args: [self()]}]
    GenServer.start_link(Worker, config)
    assert_receive :hello, 2_100
  end

  test "run every 5 seconds" do
    config = [%{cron: "*/5 * * * * *", module: Hello, function: :send, args: [self()]}]
    GenServer.start_link(Worker, config)
    assert_receive :hello, 5_100
  end
end
