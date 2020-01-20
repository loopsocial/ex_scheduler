# ex_scheduler

Cron-like job scheduler in less then 100 lines of readable elixir code.

Inspired in https://stackoverflow.com/a/32097971, but with cron syntax support.

## Installation

```elixir
def deps do
  [
    {:ex_scheduler, "~> 0.1.0"}
  ]
end
```

## Configuration

Cron expressions are evaluated over UTC time.

```elixir
  config :ex_scheduler, [
    %{
      # Every 5 minutes
      cron: "*/5 * * * *",
      module: Context.ModuleName,
      function: :function_name, # optional
      args: [1, 2, 3]           # optional
    },
    %{
      # Every hour
      cron: "0 * * * *",
      module: "Context.ModuleName2",
      function: :function_name, # optional
      args: [:foo, :bar]        # optional
    }
  ]
```

- When `function_name` is omitted, the `perform/0` function is called.
- When `args` are ommited, the function is called with no attributes.

## TODO
- get index of min value in one line (Worker.get_state/1)
- single scheduler per cluster of nodes
- https://hex.pm/docs/publish
- Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
  and published on [HexDocs](https://hexdocs.pm)
