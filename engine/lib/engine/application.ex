defmodule Engine.Application do
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children =
      if Forge.project_node?() do
        [
          Engine.Api.Proxy,
          Engine.Commands.Reindex,
          Forge.Module.Loader,
          {Forge.Dispatch, progress: true},
          Engine.ModuleMappings,
          Engine.Build,
          Engine.Build.CaptureServer,
          Forge.Search.Store.Backends.Ets,
          {Forge.Search.Store,
           [
             &Forge.Search.Indexer.create_index/1,
             &Forge.Search.Indexer.update_index/2
           ]}
        ]
      else
        []
      end

    opts = [strategy: :one_for_one, name: Engine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
