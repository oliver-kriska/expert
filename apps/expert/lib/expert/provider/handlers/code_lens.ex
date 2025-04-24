defmodule Expert.Provider.Handlers.CodeLens do
  alias Expert.Configuration
  alias Expert.Protocol.Requests
  alias Expert.Protocol.Responses
  alias Expert.Protocol.Types.CodeLens
  alias Expert.Provider.Handlers
  alias Forge.Document
  alias Forge.Document.Position
  alias Forge.Document.Range
  alias Forge.Project

  import Document.Line
  require Logger

  def handle(%Requests.CodeLens{} = request, %Configuration{} = config) do
    lenses =
      case reindex_lens(config.project, request.document) do
        nil -> []
        lens -> List.wrap(lens)
      end

    response = Responses.CodeLens.new(request.id, lenses)
    {:reply, response}
  end

  defp reindex_lens(%Project{} = project, %Document{} = document) do
    if show_reindex_lens?(project, document) do
      range = def_project_range(document)
      command = Handlers.Commands.reindex_command(project)

      CodeLens.new(command: command, range: range)
    end
  end

  @project_regex ~r/def\s+project\s/
  defp def_project_range(%Document{} = document) do
    # returns the line in mix.exs where `def project` occurs
    Enum.reduce_while(document.lines, nil, fn
      line(text: line_text, line_number: line_number), _ ->
        if String.match?(line_text, @project_regex) do
          start_pos = Position.new(document, line_number, 1)
          end_pos = Position.new(document, line_number, String.length(line_text))
          range = Range.new(start_pos, end_pos)
          {:halt, range}
        else
          {:cont, nil}
        end
    end)
  end

  defp show_reindex_lens?(%Project{} = project, %Document{} = document) do
    document_path = Path.expand(document.path)

    document_path == Project.mix_exs_path(project) and
      not Engine.Api.index_running?(project)
  end
end
