# ExScheduler

Cron-like job scheduler in few lines of readable elixir code.

Inspired in [this answer by José Valim](https://stackoverflow.com/a/32097971).

Additions:
- Cron syntax with extended support for seconds
- Cluster support with each job running in only one node

## Installation

```elixir
def deps do
  [
    {:ex_scheduler, "~> 0.1.0"}
  ]
end
```

## Configuration

In application.ex, include Ex.Worker in your supervisiton tree
```elixir
  {ExScheduler.Worker, ex_scheduler_config()}
```

Write the configuration
```elixir
  defp ex_scheduler_config() do
    [
      # runs `Foo.Bar.perform/0` every second
      %{cron: "* * * * * *", module: Foo.Bar},
      # runs `Foo.Bar.custom/0` every 5 minutes
      %{cron: "* */5 * * * *", module: Foo.Bar, function: :custom},
      # runs `IO.puts/1` with "hello world" every day at 1:30
      %{cron: "0 30 1 * * *", module: IO, function: :puts, args: ["hello world"]},
    ]
  end
```

Cron expressions are evaluated over UTC time.

- When `function_name` is omitted, the `perform/0` function is called.
- When `args` are ommited, the function is called with no attributes.
- It uses a cron (extended syntax)[https://hexdocs.pm/crontab/Crontab.CronExpression.Parser.html#parse/2],
where the first `*` represents the seconds

## TODO
- Write documentation for Worker
- https://hex.pm/docs/publish
- Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
  and published on [HexDocs](https://hexdocs.pm)
