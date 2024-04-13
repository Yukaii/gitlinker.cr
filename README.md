Gitlinker CLI
=============

Gitlinker is a command-line tool that generates URLs for specific lines of code in a Git repository hosted on various platforms like GitHub, GitLab, Bitbucket, and more.

Installation
------------

To install Gitlinker, make sure you have Crystal installed on your system. Then, run the following command:

```
crystal build src/gitlinker.cr
```

This will compile the Gitlinker source code and generate an executable named `gitlinker`.

Usage
-----

To use Gitlinker, run the `gitlinker` executable followed by the desired options:

```
./gitlinker [options]
```

### Options

- `-v`, `--version`: Show the version of Gitlinker.
- `-h`, `--help`: Show the help information.
- `-f FILE`, `--file=FILE`: Specify the path to the file for which you want to generate the URL.
- `-s LINE`, `--start-line=LINE`: Specify the start line number.
- `-e LINE`, `--end-line=LINE`: Specify the end line number (optional).

### Examples

To generate a URL for a specific file and line number:

```
./gitlinker -f path/to/file.ext -s 10
```

To generate a URL for a specific file and line range:

```
./gitlinker -f path/to/file.ext -s 10 -e 20
```

Configuration
-------------

Gitlinker uses a set of predefined routes to generate URLs for different Git hosting platforms. The routes are defined in the `DEFAULT_ROUTERS` constant in the `Gitlinker::Configs` module.

You can customize the routes by modifying the `DEFAULT_ROUTERS` constant to add, remove, or update the routes for different platforms.

Contributing
------------

If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request on the [Gitlinker repository](https://github.com/your/repository).

License
-------

Gitlinker is open-source software licensed under the [MIT License](https://opensource.org/licenses/MIT).
