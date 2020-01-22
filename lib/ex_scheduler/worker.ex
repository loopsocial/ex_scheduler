defmodule ExScheduler.Worker do
  use GenServer
  alias ExScheduler.Allocation

  @default_function :perform
  @default_args []

  def init(jobs) do
    validate_jobs!(jobs)
    {:ok, jobs |> new_state() |> schedule_next_job()}
  end

  defp new_state(jobs) do
    milliseconds_to_jobs = Enum.map(jobs, &next_run_in_milliseconds!(&1.cron))
    %{jobs: jobs, next_job_index: index_of_minimum(milliseconds_to_jobs)}
  end

  defp schedule_next_job(state) do
    next_job = Enum.at(state.jobs, state.next_job_index)
    next_run_ms = next_run_in_milliseconds!(next_job.cron)
    Process.send_after(self(), :work, next_run_ms)

    state
  end

  defp next_run_in_milliseconds!(cron) do
    is_extended_cron_syntax = cron |> String.split() |> length == 6

    seconds =
      cron
      |> Crontab.CronExpression.Parser.parse!(is_extended_cron_syntax)
      |> Crontab.Scheduler.get_next_run_date!()
      |> Timex.diff(DateTime.utc_now(), :seconds)

    # Add a second to prevent running same job multiple times
    (seconds + 1) * 1000
  end

  defp index_of_minimum(list) do
    list |> Enum.with_index() |> Enum.min_by(fn {elem, _} -> elem end) |> elem(1)
  end

  def handle_info(:work, state) do
    if Allocation.is_job_allocated_to_current_node(state.jobs, state.next_job_index) do
      job = Enum.at(state.jobs, state.next_job_index)
      module = Map.get(job, :module)
      function = Map.get(job, :function, @default_function)
      args = Map.get(job, :args, @default_args)

      Task.Supervisor.start_child(ExScheduler.TaskSupervisor, fn ->
        apply(module, function, args)
      end)
    end

    {:noreply, state.jobs |> new_state() |> schedule_next_job()}
  end

  defp validate_jobs!(config) when not is_list(config) do
    raise(ArgumentError, message: "ExScheduler config expects a list of jobs")
  end

  defp validate_jobs!([]) do
    raise(ArgumentError, message: "ExScheduler config expects a list of jobs")
  end

  defp validate_jobs!(config) do
    Enum.each(config, fn job ->
      unless Map.has_key?(job, :cron) do
        raise(ArgumentError, message: "ExScheduler config missing :cron attribute")
      end

      unless Map.has_key?(job, :module) do
        raise(ArgumentError, message: "ExScheduler config missing :module attribute")
      end
    end)
  end
end
