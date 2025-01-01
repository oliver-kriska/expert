defmodule Engine.Api do
  alias Lexical.Ast.Analysis
  alias Lexical.Ast.Env
  alias Lexical.Document
  alias Lexical.Document.Position
  alias Lexical.Document.Range
  alias Lexical.Project

  alias Engine.CodeIntelligence

  require Logger

  def schedule_compile(%Project{} = project, force?) do
    Engine.call(project, Engine, :schedule_compile, [force?])
  end

  def compile_document(%Project{} = project, %Document{} = document) do
    Engine.call(project, Engine, :compile_document, [document])
  end

  def expand_alias(
        %Project{} = project,
        segments_or_module,
        %Analysis{} = analysis,
        %Position{} = position
      ) do
    Engine.call(project, Engine, :expand_alias, [
      segments_or_module,
      analysis,
      position
    ])
  end

  def list_modules(%Project{} = project) do
    Engine.call(project, Engine, :list_modules)
  end

  def format(%Project{} = project, %Document{} = document) do
    Engine.call(project, Engine, :format, [document])
  end

  def code_actions(
        %Project{} = project,
        %Document{} = document,
        %Range{} = range,
        diagnostics,
        kinds
      ) do
    Engine.call(project, Engine, :code_actions, [
      document,
      range,
      diagnostics,
      kinds
    ])
  end

  def complete(%Project{} = project, %Env{} = env) do
    Logger.info("Completion for #{inspect(env.position)}")
    Engine.call(project, Engine, :complete, [env])
  end

  def complete_struct_fields(%Project{} = project, %Analysis{} = analysis, %Position{} = position) do
    Engine.call(project, Engine, :complete_struct_fields, [
      analysis,
      position
    ])
  end

  def definition(%Project{} = project, %Document{} = document, %Position{} = position) do
    Engine.call(project, Engine, :definition, [document, position])
  end

  def references(
        %Project{} = project,
        %Analysis{} = analysis,
        %Position{} = position,
        include_definitions?
      ) do
    Engine.call(project, Engine, :references, [
      analysis,
      position,
      include_definitions?
    ])
  end

  def modules_with_prefix(%Project{} = project, prefix)
      when is_binary(prefix) or is_atom(prefix) do
    Engine.call(project, Engine, :modules_with_prefix, [prefix])
  end

  def modules_with_prefix(%Project{} = project, prefix, predicate)
      when is_binary(prefix) or is_atom(prefix) do
    Engine.call(project, Engine, :modules_with_prefix, [prefix, predicate])
  end

  @spec docs(Project.t(), module()) :: {:ok, CodeIntelligence.Docs.t()} | {:error, any()}
  def docs(%Project{} = project, module, opts \\ []) when is_atom(module) do
    Engine.call(project, Engine, :docs, [module, opts])
  end

  def register_listener(%Project{} = project, listener_pid, message_types)
      when is_pid(listener_pid) and is_list(message_types) do
    Engine.call(project, Engine, :register_listener, [
      listener_pid,
      message_types
    ])
  end

  def broadcast(%Project{} = project, message) do
    Engine.call(project, Engine, :broadcast, [message])
  end

  def reindex(%Project{} = project) do
    Engine.call(project, Engine, :reindex, [])
  end

  def index_running?(%Project{} = project) do
    Engine.call(project, Engine, :index_running?, [])
  end

  def resolve_entity(%Project{} = project, %Analysis{} = analysis, %Position{} = position) do
    Engine.call(project, Engine, :resolve_entity, [analysis, position])
  end

  def struct_definitions(%Project{} = project) do
    Engine.call(project, Engine, :struct_definitions, [])
  end

  def document_symbols(%Project{} = project, %Document{} = document) do
    Engine.call(project, Engine, :document_symbols, [document])
  end

  def workspace_symbols(%Project{} = project, query) do
    Engine.call(project, Engine, :workspace_symbols, [query])
  end
end
