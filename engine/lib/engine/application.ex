defmodule Engine.Application do
  @moduledoc false

  alias Engine

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children =
      if RemoteControl.project_node?() do
        [
          RemoteControl.Api.Proxy,
          RemoteControl.Commands.Reindex,
          RemoteControl.Module.Loader,
          {RemoteControl.Dispatch, progress: true},
          RemoteControl.ModuleMappings,
          RemoteControl.Build,
          RemoteControl.Build.CaptureServer,
          RemoteControl.Plugin.Runner.Supervisor,
          RemoteControl.Plugin.Runner.Coordinator,
          RemoteControl.Search.Store.Backends.Ets,
          {RemoteControl.Search.Store,
           [
             &RemoteControl.Search.Indexer.create_index/1,
             &RemoteControl.Search.Indexer.update_index/2
           ]}
        ]
      else
        []
      end

    opts = [strategy: :one_for_one, name: Engine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
