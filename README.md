# Swift.vim

Syntax and indent files for [Swift](https://developer.apple.com/swift/)

## Features

- Syntax highlighting for modern Swift
- Filetype detection
- Smart indentation
- Compiler usage (`:compiler swiftc` → `:make`)

## Examples

![](https://raw.githubusercontent.com/keith/swift.vim/master/screenshots/screen.png)
![](https://raw.githubusercontent.com/keith/swift.vim/master/screenshots/screen2.png)

## Installation

### [LazyVim](https://www.lazyvim.org/)

> For [neovim](https://github.com/neovim/neovim) only

1. Locate your [plugins folder](https://www.lazyvim.org/configuration/plugins#-adding-plugins), make a new `.lua` file and name it `swift.lua`

2. add the following:

```lua
return {
  "keith/swift.vim",
  ft = "swift",  -- filetype
}
```

The plugin should be automatically installed next time you start nvim!

> [!TIP]
> usual location for the plugins is `~/.config/nvim/lua/plugins/`)

### [Plug](https://github.com/junegunn/vim-plug)

1. Add the folowing to your vim-plug block:

```vim
Plug 'keith/swift.vim', { 'for': 'swift' }
```

2. Run `:PlugInstall`:

### [Packer](https://github.com/wbthomason/packer.nvim)

1. Add the following to your packer config:

```lua
require('packer').startup(function(use)
  use { 'keith/swift.vim', ft = 'swift' }
end)
```

## Usage

Opening any `.swift` file should automatically enable the plugin.

##### Commands

- Run `:compiler swiftc` then `:make` to build current file.
