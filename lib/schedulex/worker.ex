defmodule Schedulex.Worker do
  use GenServer

  @default_function :perform
  @default_args []

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def init(config) do
    {:ok, get_state_and_schedule(config)}
  end

  def handle_info(:work, state) do
    job = Enum.at(state.jobs, state.next_job_index)
    module = Map.fetch!(job, :module)
    function = Map.get(job, :function, @default_function)
    args = Map.get(job, :args, @default_args)

    Task.Supervisor.start_child(Schedulex.TaskSupervisor, fn ->
      apply(module, function, args)
    end)

    {:noreply, get_state_and_schedule(state.jobs)}
  end

  defp get_state_and_schedule(jobs) do
    state = get_state(jobs)
    next_job = Enum.at(state.jobs, state.next_job_index)
    next_run_ms = next_run_in_milliseconds!(next_job.cron)
    Process.send_after(self(), :work, next_run_ms)

    state
  end

  defp next_run_in_milliseconds!(cron) do
    seconds =
      cron
      |> Crontab.CronExpression.Parser.parse!()
      |> Crontab.Scheduler.get_next_run_date!()
      |> Timex.diff(DateTime.utc_now(), :seconds)

    # Add a second to prevent running same job multiple times
    (seconds + 1) * 1000
  end

  defp get_state(jobs) do
    jobs_ms = Enum.map(jobs, fn %{cron: cron} -> next_run_in_milliseconds!(cron) end)
    min_ms = Enum.min(jobs_ms)
    next_job_index = Enum.find_index(jobs_ms, fn ms -> ms == min_ms end)

    %{jobs: jobs, next_job_index: next_job_index}
  end
end
