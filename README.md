# Expert

Welcome to the monorepo for the official Elixir LSP implementation, Expert!

## Projects

- `expert` - the LSP server
- `engine` - the code intelligence engine injected into the user's project
- `namespace` - mix task to disguise the engine application to not clobber the user's code

## Getting Started

Expert uses the [just](https://just.systems) command runner system (similar to make). If you use [Nix](https://nixos.org/), you can jump in the dev shell `nix develop` and `just` and the rest of the dependencies will be installed for you.

Otherwise, please install the following dependencies with your choice of package manager or with asdf/mise.

- [just](https://just.systems)
- Erlang (version found in the .tool-versions file)
- Elixir (version found in the .tool-versions file)
- Zig (version found in the .tool-versions file)
- xz 
- 7zz (to create Windows builds) 

To quickly build a release you can run locally

```shell
# dev build
just release-local

# prod build
MIX_ENV=prod just release-local
```
Now a single file executable for your system will be available in `./expert/burrito_out/`, e.g., `./expert/burrito_out/expert_linux_amd64`

To start the local dev server in TCP mode.

```shell
just start --port 9000
```

The full set of recipes can be found by running `just --list`.

```
Available recipes:
    compile project             # Compile the given project.
    deps project                # Run mix deps.get for the given project
    mix cmd *project            # Run a mix command in one or all projects. Use `just test` to run tests.
    release-all                 # Build releases for all target platforms
    release-local               # Build a release for the local system
    release-plain               # Build a plain release without burrito
    run project +ARGS           # Run an arbitrary command inside the given project directory
    start *opts="--port 9000"   # Start the local development server
    test project="all" *args="" # Run tests in the given project
```
