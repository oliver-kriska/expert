defmodule ExpertTest do
  use ExUnit.Case
  import GenLSP.Test
  import Expert.Support.Utils

  @moduletag :tmp_dir

  @moduletag root_paths: ["my_proj"]
  setup %{tmp_dir: tmp_dir} do
    File.mkdir_p!(Path.join(tmp_dir, "my_proj/lib"))
    File.write!(Path.join(tmp_dir, "my_proj/mix.exs"), mix_exs())
    [cwd: tmp_dir]
  end

  setup %{tmp_dir: tmp_dir} do
    File.write!(Path.join(tmp_dir, "my_proj/lib/bar.ex"), """
    defmodule Bar do
      defstruct [:foo]

      def foo(arg1) do
      end
    end
    """)

    File.write!(Path.join(tmp_dir, "my_proj/lib/code_action.ex"), """
    defmodule Foo.CodeAction do
      # some comment

      defmodule NestedMod do
        def foo do
          :ok
        end
      end
    end
    """)

    File.write!(Path.join(tmp_dir, "my_proj/lib/foo.ex"), """
    defmodule Foo do
    end
    """)

    File.write!(Path.join(tmp_dir, "my_proj/lib/project.ex"), """
    defmodule Project do
      def hello do
        :world
      end
    end
    """)

    File.rm_rf!(Path.join(tmp_dir, ".elixir-tools"))

    :ok
  end

  setup :with_lsp

  test "responds correctly to a shutdown request", %{client: client} do
    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})

    assert :ok ==
             request(client, %{
               method: "shutdown",
               id: 2,
               jsonrpc: "2.0"
             })

    assert_result(2, nil)
  end

  test "document symbols", %{client: client} = context do
    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})

    assert_notification(
      "window/logMessage",
      %{
        "message" => "[Expert] Runtime is ready",
        "type" => 4
      }
    )

    assert :ok ==
             request(client, %{
               method: "textDocument/documentSymbol",
               id: 2,
               jsonrpc: "2.0",
               params: %{
                 textDocument: %{
                   uri: "file://#{Path.join(context.tmp_dir, "my_proj/lib/code_action.ex")}"
                 }
               }
             })

    assert_result(2, [
      %{
        "children" => [
          %{
            "children" => [
              %{
                "children" => [],
                "kind" => 12,
                "name" => "def foo",
                "range" => %{
                  "end" => %{"character" => 4, "line" => 6},
                  "start" => %{"character" => 4, "line" => 4}
                },
                "selectionRange" => %{
                  "end" => %{"character" => 4, "line" => 4},
                  "start" => %{"character" => 4, "line" => 4}
                }
              }
            ],
            "kind" => 2,
            "name" => "NestedMod",
            "range" => %{
              "end" => %{"character" => 2, "line" => 7},
              "start" => %{"character" => 2, "line" => 3}
            },
            "selectionRange" => %{
              "end" => %{"character" => 2, "line" => 3},
              "start" => %{"character" => 2, "line" => 3}
            }
          }
        ],
        "kind" => 2,
        "name" => "Foo.CodeAction",
        "range" => %{
          "end" => %{"character" => 0, "line" => 8},
          "start" => %{"character" => 0, "line" => 0}
        },
        "selectionRange" => %{
          "end" => %{"character" => 0, "line" => 0},
          "start" => %{"character" => 0, "line" => 0}
        }
      }
    ])
  end

  test "returns method not found for unimplemented requests", %{client: client} do
    id = System.unique_integer([:positive])

    assert :ok == notify(client, %{method: "initialized", jsonrpc: "2.0", params: %{}})

    assert :ok ==
             request(client, %{
               method: "textDocument/signatureHelp",
               id: id,
               jsonrpc: "2.0",
               params: %{position: %{line: 0, character: 0}, textDocument: %{uri: ""}}
             })

    assert_error(^id, %{
      "code" => -32_601,
      "message" => "Method Not Found: textDocument/signatureHelp"
    })
  end

  test "can initialize the server" do
    assert_result(1, %{
      "capabilities" => %{
        "textDocumentSync" => %{
          "openClose" => true,
          "save" => %{
            "includeText" => true
          },
          "change" => 2
        }
      },
      "serverInfo" => %{"name" => "Expert"}
    })
  end
end
