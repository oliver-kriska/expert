defmodule Namespace.Abstract do
  @moduledoc """
  Transformations from erlang abstract syntax

  The abstract syntax is rather tersely defined here:
  https://www.erlang.org/doc/apps/erts/absform.html
  """

  def code_from(path) do
    with {:ok, {_orig_module, code_parts}} <- :beam_lib.chunks(path, [:abstract_code]),
         {:ok, {:raw_abstract_v1, forms}} <- Keyword.fetch(code_parts, :abstract_code) do
      {:ok, forms}
    else
      _ ->
        {:error, :not_found}
    end
  end

  def run(abstract_format, opts) when is_list(abstract_format) do
    Task.async(fn ->
      Process.put(:abstract_code_opts, opts)
      Enum.map(abstract_format, fn af -> rewrite(af) end)
    end)
    |> Task.await()
  end

  defp rewrite(forms) when is_list(forms) do
    Enum.map(forms, fn af -> rewrite(af) end)
  end

  defp rewrite({:attribute, anno, :export, exported_functions}) do
    {:attribute, anno, :export, exported_functions}
  end

  defp rewrite({:attribute, anno, :behaviour, module}) do
    {:attribute, anno, :behaviour, rewrite_module(module)}
  end

  defp rewrite({:attribute, anno, :import, {module, funs}}) do
    {:attribute, anno, :import, {rewrite_module(module), rewrite(funs)}}
  end

  defp rewrite({:attribute, anno, :module, mod}) do
    {:attribute, anno, :module, rewrite_module(mod)}
  end

  defp rewrite({:attribute, anno, :__impl__, attrs}) do
    {:attribute, anno, :__impl__, rewrite(attrs)}
  end

  defp rewrite({:function, anno, name, arity, clauses}) do
    {:function, anno, name, arity, rewrite(clauses)}
  end

  defp rewrite({:attribute, anno, spec, {{name, arity}, spec_clauses}}) do
    {:attribute, anno, rewrite(spec), {{name, arity}, rewrite(spec_clauses)}}
  end

  defp rewrite({:attribute, anno, :spec, {{mod, name, arity}, clauses}}) do
    {:attribute, anno, :spec, {{rewrite(mod), name, arity}, rewrite(clauses)}}
  end

  defp rewrite({:attribute, anno, :record, {name, fields}}) do
    {:attribute, anno, :record, {rewrite_module(name), rewrite(fields)}}
  end

  defp rewrite({:attribute, anno, type, {name, type_rep, clauses}}) do
    {:attribute, anno, type, {name, rewrite(type_rep), rewrite(clauses)}}
  end

  defp rewrite({:for, target}) do
    # Protocol implementation
    {:for, rewrite_module(target)}
  end

  defp rewrite({:protocol, protocol}) do
    {:protocol, rewrite_module(protocol)}
  end

  # Record Fields

  defp rewrite({:record_field, anno, repr}) do
    {:record_field, anno, rewrite(repr)}
  end

  defp rewrite({:record_field, anno, repr_1, repr_2}) do
    {:record_field, anno, rewrite(repr_1), rewrite(repr_2)}
  end

  defp rewrite({:typed_record_field, {:record_field, anno, repr_1}, repr_2}) do
    {:typed_record_field, {:record_field, anno, rewrite(repr_1)}, rewrite(repr_2)}
  end

  defp rewrite({:typed_record_field, {:record_field, anno, repr_a, repr_e}, repr_t}) do
    {:typed_record_field, {:record_field, anno, rewrite(repr_a), rewrite(repr_e)},
     rewrite(repr_t)}
  end

  # Representation of Parse Errors and End-of-File Omitted; not necessary
  # 8.2  Atomic Literals

  # only rewrite atoms, since they might be modules
  defp rewrite({:atom, anno, literal}) do
    {:atom, anno, rewrite_module(literal)}
  end

  # 8.3  Patterns
  # ignore bitstraings, they can't contain modules

  defp rewrite({:match, anno, lhs, rhs}) do
    {:match, anno, rewrite(lhs), rewrite(rhs)}
  end

  defp rewrite({:cons, anno, head, tail}) do
    {:cons, anno, rewrite(head), rewrite(tail)}
  end

  defp rewrite({:map, anno, matches}) do
    {:map, anno, rewrite(matches)}
  end

  defp rewrite({:op, anno, op, lhs, rhs}) do
    {:op, anno, op, rewrite(lhs), rewrite(rhs)}
  end

  defp rewrite({:op, anno, op, pattern}) do
    {:op, anno, op, rewrite(pattern)}
  end

  defp rewrite({:tuple, anno, patterns}) do
    {:tuple, anno, rewrite(patterns)}
  end

  defp rewrite({:var, anno, atom}) do
    {:var, anno, rewrite_module(atom)}
  end

  # 8.4  Expressions

  defp rewrite({:bc, anno, rep_e0, qualifiers}) do
    {:bc, anno, rewrite(rep_e0), rewrite(qualifiers)}
  end

  defp rewrite({:bin, anno, bin_elements}) do
    {:bin, anno, rewrite(bin_elements)}
  end

  defp rewrite({:bin_element, anno, elem, size, type}) do
    {:bin_element, anno, rewrite(elem), size, type}
  end

  defp rewrite({:block, anno, body}) do
    {:block, anno, rewrite(body)}
  end

  defp rewrite({:case, anno, expression, clauses}) do
    {:case, anno, rewrite(expression), rewrite(clauses)}
  end

  defp rewrite({:catch, anno, expression}) do
    {:catch, anno, rewrite(expression)}
  end

  defp rewrite({:fun, anno, {:function, name, arity}}) do
    {:fun, anno, {:function, rewrite(name), arity}}
  end

  defp rewrite({:fun, anno, {:function, module, name, arity}}) do
    {:fun, anno, {:function, rewrite(module), rewrite(name), arity}}
  end

  defp rewrite({:fun, anno, {:clauses, clauses}}) do
    {:fun, anno, {:clauses, rewrite(clauses)}}
  end

  defp rewrite({:named_fun, anno, name, clauses}) do
    {:named_fun, anno, rewrite(name), rewrite(clauses)}
  end

  defp rewrite({:call, anno, {:remote, remote_anno, module, fn_name}, args}) do
    {:call, anno, {:remote, remote_anno, rewrite(module), fn_name}, rewrite(args)}
  end

  defp rewrite({:call, anno, name, args}) do
    {:call, anno, rewrite(name), rewrite(args)}
  end

  defp rewrite({:if, anno, clauses}) do
    {:if, anno, rewrite(clauses)}
  end

  defp rewrite({:lc, anno, expression, qualifiers}) do
    {:lc, anno, rewrite(expression), rewrite(qualifiers)}
  end

  defp rewrite({:map, anno, expression, clauses}) do
    {:map, anno, rewrite(expression), rewrite(clauses)}
  end

  defp rewrite({:maybe_match, anno, lhs, rhs}) do
    {:maybe_match, anno, rewrite(lhs), rewrite(rhs)}
  end

  defp rewrite({:maybe, anno, body}) do
    {:maybe, anno, rewrite(body)}
  end

  defp rewrite({:maybe, anno, maybe_body, {:else, anno, else_clauses}}) do
    {:maybe, anno, rewrite(maybe_body), {:else, anno, rewrite(else_clauses)}}
  end

  defp rewrite({:receive, anno, clauses}) do
    {:receive, anno, rewrite(clauses)}
  end

  defp rewrite({:receive, anno, cases, expression, body}) do
    {:receive, anno, rewrite(cases), rewrite(expression), rewrite(body)}
  end

  defp rewrite({:record, anno, name, fields}) do
    {:record, anno, rewrite_module(name), rewrite(fields)}
  end

  defp rewrite({:record_field, anno, record_name, field_name, record_field}) do
    {:record_field, anno, rewrite_module(record_name), field_name, record_field}
  end

  defp rewrite({:try, anno, body, case_clauses, catch_clauses}) do
    {:try, anno, rewrite(body), rewrite(case_clauses), rewrite(catch_clauses)}
  end

  defp rewrite({:try, anno, body, case_clauses, catch_clauses, after_clauses}) do
    {:try, anno, rewrite(body), rewrite(case_clauses), rewrite(catch_clauses),
     rewrite(after_clauses)}
  end

  # Qualifiers

  defp rewrite({:generate, anno, lhs, rhs}) do
    {:generate, anno, rewrite(lhs), rewrite(rhs)}
  end

  defp rewrite({:b_generate, anno, lhs, rhs}) do
    {:b_generate, anno, rewrite(lhs), rewrite(rhs)}
  end

  # Associations

  defp rewrite({:map_field_assoc, anno, key, value}) do
    {:map_field_assoc, anno, rewrite(key), rewrite(value)}
  end

  defp rewrite({:map_field_exact, anno, key, value}) do
    {:map_field_exact, anno, rewrite(key), rewrite(value)}
  end

  # 8.5  Clauses

  defp rewrite({:clause, anno, lhs, guards, rhs}) do
    {:clause, anno, rewrite(lhs), rewrite(guards), rewrite(rhs)}
  end

  # 8.6  Guards
  # Guards seem covered by above clauses

  # 8.7  Types
  defp rewrite({:ann_type, anno, clauses}) do
    {:ann_type, anno, rewrite(clauses)}
  end

  defp rewrite({:type, anno, :fun, [{:type, type_anno, :any}, type]}) do
    {:type, anno, :fun, [{:type, type_anno, :any}, rewrite(type)]}
  end

  defp rewrite({:type, anno, :map, key_values}) do
    {:type, anno, :map, rewrite(key_values)}
  end

  defp rewrite({:type, anno, predefined_type, expressions}) do
    {:type, anno, rewrite(predefined_type), rewrite(expressions)}
  end

  defp rewrite({:remote_type, anno, [module, name, expressions]}) do
    {:remote_type, anno, [rewrite_module(module), name, rewrite(expressions)]}
  end

  defp rewrite({:user_type, anno, name, types}) do
    {:user_type, anno, rewrite_module(name), rewrite(types)}
  end

  # Catch all
  defp rewrite(other) do
    other
  end

  defp rewrite_module({:atom, sequence, literal}) do
    {:atom, sequence, rewrite_module(literal)}
  end

  defp rewrite_module({:var, anno, name}) do
    {:var, anno, rewrite_module(name)}
  end

  defp rewrite_module(module) do
    opts = Process.get(:abstract_code_opts)
    Namespace.Module.run(module, opts)
  end
end
