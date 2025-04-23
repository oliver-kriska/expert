defmodule Expert.Test.Expert.CompletionCase do
  alias Forge.Ast
  alias Forge.Document
  alias Forge.Project
  alias Expert.Protocol.Types.Completion.Context, as: CompletionContext
  alias Expert.Protocol.Types.Completion.Item, as: CompletionItem
  alias Expert.Protocol.Types.Completion.List, as: CompletionList
  alias Engine
  alias Expert
  alias Expert.CodeIntelligence.Completion
  alias Forge.Test.CodeSigil

  use ExUnit.CaseTemplate
  import Forge.Test.CursorSupport
  import Engine.Test.Fixtures
  import Engine.Api.Messages

  setup_all do
    project = project()

    start_supervised!({DynamicSupervisor, Expert.Project.Supervisor.options()})
    start_supervised!({Expert.Project.Supervisor, project})

    Engine.Api.register_listener(project, self(), [
      project_compiled(),
      project_index_ready()
    ])

    Engine.Api.schedule_compile(project, true)
    assert_receive project_compiled(), 5000
    assert_receive project_index_ready(), 5000
    {:ok, project: project}
  end

  using do
    quote do
      import unquote(__MODULE__)
      import unquote(CodeSigil), only: [sigil_q: 2]
    end
  end

  def apply_completion(%CompletionItem{text_edit: %Document.Changes{} = changes}) do
    edits = List.wrap(changes.edits)
    {:ok, edited_document} = Document.apply_content_changes(changes.document, 1, edits)
    Document.to_string(edited_document)
  end

  def complete(project, text, opts \\ []) do
    return_as_list? = Keyword.get(opts, :as_list, true)
    trigger_character = Keyword.get(opts, :trigger_character)
    root_path = Project.root_path(project)

    file_path =
      case Keyword.fetch(opts, :path) do
        {:ok, path} ->
          if Path.expand(path) == path do
            # it's absolute
            path
          else
            Path.join(root_path, path)
          end

        :error ->
          Path.join([root_path, "lib", "file.ex"])
      end

    {position, document} = pop_cursor(text, document: file_path)

    context =
      if is_binary(trigger_character) do
        CompletionContext.new(
          trigger_kind: :trigger_character,
          trigger_character: trigger_character
        )
      else
        CompletionContext.new(trigger_kind: :invoked)
      end

    analysis = Ast.analyze(document)
    result = Completion.complete(project, analysis, position, context)

    if return_as_list? do
      completion_items(result)
    else
      result
    end
  end

  def fetch_completion(completions, label_prefix) when is_binary(label_prefix) do
    matcher = &String.starts_with?(&1.label, label_prefix)

    case completions |> completion_items() |> Enum.filter(matcher) do
      [] -> {:error, :not_found}
      [found] -> {:ok, found}
      found when is_list(found) -> {:ok, found}
    end
  end

  def fetch_completion(completions, opts) when is_list(opts) do
    matcher = fn completion ->
      Enum.reduce_while(opts, false, fn {key, value}, _ ->
        if Map.get(completion, key) == value do
          {:cont, true}
        else
          {:halt, false}
        end
      end)
    end

    case completions |> completion_items() |> Enum.filter(matcher) do
      [] -> {:error, :not_found}
      [found] -> {:ok, found}
      found when is_list(found) -> {:ok, found}
    end
  end

  defp completion_items(%CompletionList{items: items}), do: items
  defp completion_items(items) when is_list(items), do: items
end
