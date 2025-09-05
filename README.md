# nvim

This configuration aims to be simple, straightforward, and maintainable in the
long-term. Being a great text editor first, and an average code editor second.

The version used as a base is 0.12(nigthly) because of the better treesitter
performance, some API changes to the LSP setup and also because of the new
`vim.pack` plugin manager. All of this new changes make my configuration pretty
simple, and it should be just enough to do some programming.

## File Structure

- `init.lua` has some general configurations, like:
  - look and feel
    - colorscheme
    - statusline
  - tab/space behavior and default length (4 spaces)
  - some autocmds
  - etc
- `plugin` files get sourced afterwards, this is inherited from vim, you just
  drop files in there and forget about `require` them, or the load order.
- filetype specific configs at `ftplugin`
- `lsp` has personal configs for a few LSP servers
- `plugin/lsp.lua` contains the setup for the LSP, and enables the
  configuration for all the servers I might use

## Why no LSP package manager like Mason?

I understand the idea of "portability", it's pretty convenient to have a neovim
config that handles the installation of the servers, but in my setup servers
are easily installed by standalone package managers like
[brew](https://docs.brew.sh/Homebrew-on-Linux) (`brew bundle`), and
[just](https://github.com/casey/just) scripts for `npm`, `cargo`, `dnf`, or
just building from source, for me this is easier to work around than messing
around Mason and the rest of the dependencies.

## Why not autostart the LSP?

I'm not a programmer really, just a Linux user. The LSP is not enabled on
startup, similar to the Fleet IDE, you need to enable it manually, in my case
with the command `:LspEnable`. Sometimes I just need to take a quick look
around, maybe make a small change, and don't really like the idea of being
bombarded by servers printing their status, reloading caches, and then get more
diagnostics printed.

## Why do you not like the statusline, tabline, winbar, etc?

Because the information that they hold are not that relevant or useful, might
add one if I see a use case in the future.
