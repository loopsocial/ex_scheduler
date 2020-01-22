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

Cron expressions are evaluated over UTC time.
WORK IN PROGRESS.

- When `function_name` is omitted, the `perform/0` function is called.
- When `args` are ommited, the function is called with no attributes.

## TODO
- Rewrite README configuration section with Application configuration
- Write documentation for Worker
- https://hex.pm/docs/publish
- Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
  and published on [HexDocs](https://hexdocs.pm)
