defmodule ExScheduler.Allocation do
  @doc """
  Check if current node is assigned to next job.
  """
  def is_job_allocated_to_current_node(jobs, job_index, nodes \\ [Node.self() | Node.list()]) do
    nodes = Enum.sort(nodes)
    current_node_index = Enum.find_index(nodes, &(&1 == Node.self()))
    jobs_to_nodes = allocate_jobs_to_nodes(jobs, nodes)
    jobs_to_nodes[job_index] == current_node_index
  end

  # Example with 5 jobs for 3 nodes:
  # jobs_indexes == [0, 1, 2, 3, 4]
  # assigned_nodes == [0, 1, 2, 0, 1]
  # return %{0 => 0, 1 => 1, 2 => 2, 3 => 0, 4 => 1}
  defp allocate_jobs_to_nodes(jobs, nodes) do
    nodes_length = length(nodes)

    assigned_nodes =
      jobs
      |> Enum.with_index()
      |> Enum.map(fn {_, i} -> rem(i, nodes_length) end)

    jobs_indexes = 0..(length(jobs) - 1)

    jobs_indexes
    |> Enum.zip(assigned_nodes)
    |> Map.new()
  end
end
