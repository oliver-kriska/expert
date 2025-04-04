# Embedded Language Support

## Problem
Code for other languages is frequently inlined in Elixir code, namely within sigils. Examples include:
* Phoenix's Heex templating or ~H"" (can embed HTML, CSS, and JS within itself)
* Zigler which allows for zig source code to be embedded via ~Z""
* LiveView Native's ~LVN""

Currently this inline code receives no code intelligence support b/c it's Elixir source code at the top-level. Therefore we need "embedded language support".

## Complications
The Language Server Protocol has no provisions for embedded language support, see [this comment](https://github.com/microsoft/language-server-protocol/issues/1252#issuecomment-953748832). The LSP maintainers are open to the idea, but no one's pursued it so far. Doing so would be time consuming and likely require consensus.

Consequently, every editor ecosystem currently handles this differently.

* VSCode provisions this via [request forwarding](https://code.visualstudio.com/api/language-extensions/embedded-languages#request-forwarding).
* The Neovim issue for embedded language support [is locked](https://github.com/neovim/neovim/issues/26783#issuecomment-2249643254). [otter.nvim](https://github.com/jmbuhr/otter.nvim) appears to be a next-best solution.

I can't find any issues or discussions regarding other editors.

## Solution
VSCode's request forwarding is currently the most viable solution, and in addition it's the most popular editor for Elixir. I would opt to start with this as a first step, for lack of a better one.

The primary issue with VSCode's request forwarding is that it depends on the *language service client* to intercept and "hijack" requests. This is undesirable as all our code analysis is performed on the language server.

There is also the matter of knowing which language service we should forward requests to for given sigils. Ideally this information can be associated with each sigil's source code.

In short, we have the following problems:
1. Assocating language services with a sigil definition.
2. Detecting sigils with an associated language service.
3. Have the language service initiate a redirect.

Point 3 has actually been demonstrated in [Shopify's Ruby Language Server](https://github.com/Shopify/ruby-lsp/blob/main/lib/ruby_lsp/utils.rb#L34).

## My goal with this branch
I aim to prove that this approach is possible with Expert and spur further conversation.
