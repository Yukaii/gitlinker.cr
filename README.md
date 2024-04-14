# Gitlinker CLI (WIP)

Gitlinker is a command-line tool that generates URLs for specific lines of code in a Git repository hosted on various platforms like GitHub, GitLab, Bitbucket, and more.

> [!WARNING]
> only GitHub is partially working now. I ask Claude 3 Opus to rewrite the lua code from [linrongbin16](https://github.com/linrongbin16/gitlinker.nvim)'s gitlinker.nvim. Not all the provider were ported and tested.

## Installation

To install Gitlinker, make sure you have Crystal installed on your system. Then, run the following command:

```bash
shards build --production --release --no-debug
```

This will compile the Gitlinker source code and generate an executable named `gitlinker`.

## Usage

To use Gitlinker, run the `gitlinker` executable followed by the desired command and options:

```
gitlinker command [options]
```

For kakoune user, add this to your config

```
evaluate-commands %sh{
  gitlinker init kakoune
}
```

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

To print Kakoune definitions:

```
gitlinker init kakoune
```

## Configuration

Gitlinker uses a set of predefined routes to generate URLs for different Git hosting platforms. The routes are defined in the `DEFAULT_ROUTERS` constant in the `Gitlinker::Configs` module.

You can customize the routes by modifying the `DEFAULT_ROUTERS` constant to add, remove, or update the routes for different platforms.

## Contributing

If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request on the [Gitlinker repository](https://github.com/your/repository).

## License

Gitlinker is open-source software licensed under the [MIT License](https://opensource.org/licenses/MIT).
