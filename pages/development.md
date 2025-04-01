# Development
You'll need a local instance in order to develop Expert, so follow the [Installation guide](pages/installation.md) first.

Then, install the git hooks with:
```sh
mix hooks
```

These are pre-commit hooks that will check for correct formatting and run credo for you.

After this, you're ready to put together a pull request for Expert!

### Logging

When lexical starts up, it creates a `.lexical` directory in the root directory of a project. Inside that directory are two log files, `lexical.log` and `project.log`. The `.lexical.log` log file contains logging and OTP messages from the language server, while the `project.log` file contains logging and OTP messages from the project's node.  While developing lexical, it's helpful to open up a terminal and tail both of these log files so you can see any errors and messages that lexical emits. To do that, run the following in a terminal while in the project's root directory:

```shell
tail -f .lexical/*.log
```

Note: These log files roll over when they reach 1 megabyte, so after a time, it will be necessary to re-run the above command.

### Debugging

Lexical supports a debug shell, which will connect a remote shell to a currently-running language server process. To use it, `cd` into your lexical installation directory and run

```sh
./bin/server_shell.sh <name of project>
```

For example, if I would like to run the debug server for a server running in your `lexical` project, run:

```
./bin/server_shell.sh lexical
```

...and you will be connected to a remote IEx session _inside_ my language server. This allows you to investigate processes, make changes to the running code, or run `:observer`.

While in the debugging shell, all the functions in `Lexical.Server.IEx.Helpers` are imported for you, and some common modules, like `Lexical.Project` and `Lexical.Document` are aliased.

You can also start the lexical server in interactive mode via `./bin/start_lexical.sh iex`. Combining this with the helpers that are imported will allow you to run projects and do completions entirely in the shell.

  *Note*: The helpers assume that all of your projects are in folders that are siblings with your lexical project.

Consider the example shell session:

```
./bin/start_lexical.sh iex
iex(1)> start_project :other
# the project in the ../other directory is started
compile_project(:other)
# the other project is compiled
iex(2)> complete :other, "defmo|"
[
  #Protocol.Types.Completion.Item<[
    detail: "",
    insert_text: "defmacro ${1:name}($2) do\n  $0\nend\n",
    insert_text_format: :snippet,
    kind: :class,
    label: "defmacro (Define a macro)",
    sort_text: "093_defmacro (Define a macro)"
  ]>,
  #Protocol.Types.Completion.Item<[
    detail: "",
    insert_text: "defmacrop ${1:name}($2) do\n  $0\nend\n",
    insert_text_format: :snippet,
    kind: :class,
    label: "defmacrop (Define a private macro)",
    sort_text: "094_defmacrop (Define a private macro)"
  ]>,
  #Protocol.Types.Completion.Item<[
    detail: "",
    insert_text: "defmodule ${1:module name} do\n  $0\nend\n",
    insert_text_format: :snippet,
    kind: :class,
    label: "defmodule (Define a module)",
    sort_text: "092_defmodule (Define a module)"
  ]>
]
```

The same kind of support is available when you run `iex -S mix` in the lexical directory, and is helpful for narrowing down issues without disturbing your editor flow.

*You can also connect to the project's vm using `./bin/project_shell.sh` sans the above helpers.*

### Benchmarks

The `remote_control` project has a set of benchmarks that measure the speed of various internal functions and data structures. In order to use them, you first need to install [git large file storage](https://docs.github.com/en/repositories/working-with-files/managing-large-files/installing-git-large-file-storage), and then run `git pull`. Benchmarks are stored in the `benchmarks` subdirectory, and can be run via

```sh
mix benchmark /benchmarks/<benchmark_file>.exs
```
