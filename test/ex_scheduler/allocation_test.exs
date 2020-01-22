defmodule ExScheduler.AllocationTest do
  use ExUnit.Case
  alias ExScheduler.Allocation

  test "more nodes than jobs" do
    jobs = [
      %{cron: "1 * * * *", module: Foo1},
      %{cron: "2 * * * *", module: Foo2}
    ]

    nodes = [
      Node.self(),
      :x@localhost,
      :y@localhost
    ]

    assert Allocation.is_job_allocated_to_current_node(jobs, 0, nodes)
    refute Allocation.is_job_allocated_to_current_node(jobs, 1, nodes)
  end

  test "more jobs than nodes" do
    jobs = [
      %{cron: "1 * * * *", module: Foo1},
      %{cron: "2 * * * *", module: Foo2},
      %{cron: "3 * * * *", module: Foo3},
      %{cron: "4 * * * *", module: Foo4},
      %{cron: "5 * * * *", module: Foo5}
    ]

    nodes = [
      Node.self(),
      :x@localhost,
      :y@localhost
    ]

    assert Allocation.is_job_allocated_to_current_node(jobs, 0, nodes)
    refute Allocation.is_job_allocated_to_current_node(jobs, 1, nodes)
    refute Allocation.is_job_allocated_to_current_node(jobs, 2, nodes)
    assert Allocation.is_job_allocated_to_current_node(jobs, 3, nodes)
    refute Allocation.is_job_allocated_to_current_node(jobs, 4, nodes)
  end
end
