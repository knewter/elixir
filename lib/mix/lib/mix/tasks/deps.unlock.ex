defmodule Mix.Tasks.Deps.Unlock do
  use Mix.Task

  @shortdoc "Unlock the given dependencies"

  @moduledoc """
  Unlock the given dependencies.

  Since this is a destructive action, unlocking of dependencies
  can only happen by passing arguments/options:

    * `dep1 dep2` - the name of dependency to be unlocked
    * `--all` - unlcks all dependencies
    * `--unused` - unlocks only unused dependencies (no longer mentioned
      in the `mix.exs` file)

  """

  @switches [all: :boolean, unused: :boolean]

  def run(args) do
    Mix.Project.get!
    {opts, apps, _} = OptionParser.parse(args, switches: @switches)

    cond do
      opts[:all] ->
        Mix.Dep.Lock.write([])
      opts[:unused] ->
        apps = Mix.Dep.loaded([]) |> Enum.map(& &1.app)
        Mix.Dep.Lock.read() |> Map.take(apps) |> Mix.Dep.Lock.write()

      apps != [] ->
        lock =
          Enum.reduce apps, Mix.Dep.Lock.read, fn(app, lock) ->
            Map.delete(lock, String.to_atom(app))
          end
        Mix.Dep.Lock.write(lock)

      true ->
        Mix.raise "mix deps.unlock expects dependencies as arguments or " <>
                  "the --all option to unlock all dependencies"
    end
  end
end
