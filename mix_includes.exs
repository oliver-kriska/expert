for filename <- ~w(mix_dialyzer.exs mix_credo.exs) do
  full_path = Path.join(__DIR__, filename)

  Code.require_file(full_path)
end
