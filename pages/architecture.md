# Architecture

When Expert starts, it boots an erlang virtual machine that runs the language server and its code (AKA the "manager" node). It then boots a separate virtual machine that builds your project code (AKA the "project" or "remote" node) and connects the two via distribution. This provides the following benefits:

  * None of Expert's dependencies will conflict with your project. This means that Expert can make use of dependencies to make developing in it easier without having to "vendor" them. It also means that you can use Expert to work on your project, *even if Expert depends on your project*.
  * Your project can depend on a different version of Elixir and Erlang than Expert itself. This means that Expert can make use of the latest versions of Elixir and Erlang while still supporting projects that run on older versions.
  * The build environment for your project is only aware of your project, which enables as-you-type compilation and error reporting.
  * In the future, there is a possibility of having the Expert vm instance control multiple projects. *For now, a manager and project node will start for each editor that starts a language server.* 

## Project Structure

Expert is designed to keep your application isolated from Expert's code. Because of this, Expert is structured a set of independent mix applications residing under the `apps` directory:

  * `server` - The language server itself.
  * `remote_control` - The application that's injected into a project's code, which
  * `protocol` - Code related to speaking the language server protocol.
  * `proto` - Used by `protocol` to generate the Elixir representation of LSP data structures. Gives Expert an API to do things in the context of a project.
  * `common` - Contains all code common to the other applications.

By separating Expert into sub-applications, each is built as a separate archive, and we can pick and choose which of these applications (and their dependencies) are injected into the project's VM, thus reducing how much contamination the project sees. If Expert was a standard application, adding dependencies to Expert would cause those dependencies to appear in the project's VM, which might cause build issues, version conflicts in mix or other inconsistencies.

Since the `remote_control` app only depends on `common`, `path_glob` and `elixir_sense`, only those applications pollute the project's vm. Keeping `remote_control`'s dependencies to a minimum is a design goal of this architecture.

## 10,000ft View

![A simplified diagram of Expert](/assets/expert_10k_view.svg)

* [Language server](#language-server)
  * [Task queue](#task-queue)
  * [Document store](#document-store)
  * [Configured options + capabilities](#configured-options)
* [Project node](#project-node)
  * [Indexer](#indexer)
  * [Code intelligence + completions](#code-intelligence--completions)

## Language Server

The language server (the `server` app) is the entry point to Expert. When started by the `start_lexical.sh` command, it sets up a [transport](https://github.com/elixir-lang/expert/blob/main/apps/server/lib/lexical/server/transport.ex) that [reads and writes JsonRPC from stdio](https://github.com/elixir-lang/expert/blob/main/apps/server/lib/lexical/server/transport/std_io.ex). When a message is received, it is parsed into either a [LSP Request](https://github.com/elixir-lang/expert/blob/main/apps/protocol/lib/lexical/protocol/requests.ex) or a [LSP Notification](https://github.com/elixir-lang/expert/blob/main/apps/protocol/lib/Expert/protocol/notifications.ex) and subsequently processed.

The only messages the [Expert server node](https://github.com/elixir-lang/expert/blob/main/apps/server/lib/lexical/server.ex) handles directly are those related to the lifecycle of the language server itself:

- Performing initialization and shutdown
- Synchronizing document states
- Processing configuration changes

All other messages are delegated to a _Provider Handler_. This delegation is accomplished by the server process adding the request to the [provider queue](https://github.com/elixir-lang/expert/blob/main/apps/server/lib/lexical/server/provider/queue.ex). The provider queue asks the `Lexical.Server.Provider.Handlers.for_request/1` function which handler is configured to handle the request, creates a task for the handler and starts it.

A _Provider Handler_ is just a module that defines a function of arity 2 that takes the request to handle and a `%Lexical.Server.Configuration{}`. These functions can reply to the request, ignore it, or do some other action.

### Task Queue
All requests made to Expert are placed into *the* task queue and processed concurrently. Tasks are cancellable.

### Document Store
[Documents](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocuments) are the formal structure LSP uses to handle files of source code. Documents (and edits to them) are transmitted to the language server from the language client, after which language servers are responsible for persisting them.

**Expert's server process is responsible for storing documents and synchronizing them when edits are made.**

It's important to note that documents are located at **URIs**, and not strictly files on a system. For example, Visual Studio Code uses URIs with the `untitled://` scheme to represent unsaved files.

### Configured Options + Capabilities
The LSP specification defines an expansive set of features that not all editors or language servers may support. The protocol therefore defines 'Capabilities' to allow language servers and language clients to inform each other of their capabilities. These capabilities are always exchanged upon initialization of the language server.

Language servers also have options which users may switch at runtime, which Expert retains in-memory. *Editors are responsible for persisting options between sessions.*

## Project Node

### Indexer
Indexes a project's source code and stores it in a manner that's useful for lookup and analysis. Powers features such as code completions, go-to-definition, outlines, and symbol navigation. *ETS is tentatively used as the backing store for the indexer, but this may be subject to change.*

### Code Intelligence + Completions
Processing for code intelligence and completions are performed on the project node.
