# Gitlinker CLI

Gitlinker is a command-line tool that generates URLs for specific lines of code in a Git repository hosted on various platforms like GitHub, GitLab, Bitbucket, and Codeberg.

## Installation

To install Gitlinker, make sure you have Crystal installed on your system. Then, run the following command:

```bash
shards build --production --release --no-debug
```

This will compile the Gitlinker source code and generate an executable named `gitlinker`.

### Homebrew

For Homebrew users, you can tap the repository and install the latest head version:

```bash
brew tap Yukaii/tap
brew install --head gitlinker
```

## Usage

To use Gitlinker, run the `gitlinker` executable followed by the desired command and options:

```
gitlinker command [options]
```

### Editor Integration

#### Kakoune

Add this to your kakrc:

```kak
evaluate-commands %sh{
  gitlinker init kakoune
}
```

Then use:
- `:gitlinker` - Copy permalink to clipboard
- `:gitlinker-open` - Open permalink in browser

#### Neovim

Add the Lua plugin to your config:

```lua
-- Load gitlinker.cr plugin dynamically
_G.gitlinker = loadstring(vim.fn.system("gitlinker init neovim"))()
if _G.gitlinker then
  _G.gitlinker.setup()
end

-- Optional: Add keybindings
vim.keymap.set({ "n", "v" }, "<leader>gy", function() _G.gitlinker.copy() end, { desc = "Copy git permalink" })
vim.keymap.set({ "n", "v" }, "<leader>go", function() _G.gitlinker.open() end, { desc = "Open git permalink" })
```

Or with which-key:

```lua
require("which-key").add({
  { "<leader>gy", function() _G.gitlinker.copy() end, desc = "Copy Git Permalink", mode = { "n", "v", "x" } },
  { "<leader>go", function() _G.gitlinker.open() end, desc = "Open Git Permalink", mode = { "n", "v", "x" } },
})
```

Then use:
- `:Gitlinker` - Copy permalink to clipboard
- `:GitlinkerOpen` - Open permalink in browser
- Or use the configured keymaps in normal/visual mode

### Commands

- `run`: Run gitlinker to generate URLs for specific lines of code.
- `init`: Print initialization configurations.

### Options

- `-v`, `--version`: Show the version of Gitlinker.
- `-h`, `--help`: Show the help information.
- `-f FILE`, `--file=FILE`: Specify the path to the file for which you want to generate the URL.
- `-s LINE`, `--start-line=LINE`: Specify the start line number.
- `-e LINE`, `--end-line=LINE`: Specify the end line number (optional).

### Examples

To generate a URL for a specific file and line number:

```
gitlinker run -f path/to/file.ext -s 10
```

To generate a URL for a specific file and line range:

```
gitlinker run -f path/to/file.ext -s 10 -e 20
```

To print editor integration code:

```bash
gitlinker init kakoune  # For Kakoune
gitlinker init neovim   # For Neovim
```

## Configuration

Gitlinker uses a set of predefined routes to generate URLs for different Git hosting platforms. The routes are defined in the `DEFAULT_ROUTERS` constant in the `Gitlinker::Configs` module.

You can customize the routes by modifying the `DEFAULT_ROUTERS` constant to add, remove, or update the routes for different platforms.

## Contributing

If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request on the [Gitlinker repository](https://github.com/your/repository).

## License

Gitlinker is open-source software licensed under the [MIT License](https://opensource.org/licenses/MIT).

