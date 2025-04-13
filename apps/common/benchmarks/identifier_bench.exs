Benchee.run(
  %{
    "next_id" => fn ->
      Lexical.Identifier.next_global!()
    end
  },
  profile_after: true
)
