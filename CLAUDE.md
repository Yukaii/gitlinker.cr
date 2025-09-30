# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Gitlinker is a CLI tool written in Crystal that generates URLs for specific lines of code in Git repositories hosted on platforms like GitHub, GitLab, Bitbucket, and Codeberg. It's designed for Kakoune editor integration but can be used standalone.

**Current Status**: Work in progress - GitHub is partially working, other providers not fully tested.

## Development Commands

### Build
```bash
# Development build
shards build

# Production build (optimized)
shards build --production --release --no-debug
```

### Testing
```bash
# Run all tests
crystal spec

# Run specific test file
crystal spec spec/gitlinker_spec.cr
crystal spec spec/giturlparser_spec.cr
```

### Dependencies
```bash
# Install dependencies
shards install
```

### Running the CLI
```bash
# After building
./bin/gitlinker run -f path/to/file.cr -s 10
./bin/gitlinker run -f path/to/file.cr -s 10 -e 20
./bin/gitlinker init kakoune
```

## Architecture

### Core Components

**gitlinker.cr** (entry point)
- `CLI` class handles command-line argument parsing using `OptionParser`
- Supports commands: `run` (generate URLs), `init` (print editor configs)
- Entry point at bottom: `Gitlinker::CLI.new.run`

**src/linker.cr**
- `Linker` class is the main data structure holding all git/file metadata
- `Linker.make(file_path)` factory method orchestrates the entire URL generation pipeline:
  1. Resolves file path (relative to git root)
  2. Fetches git remote information via `Git` module
  3. Parses remote URL via `GitUrlParser`
  4. Determines appropriate git revision
  5. Returns populated `Linker` instance with all URL components
- Properties include: `remote_url`, `host`, `org`, `repo`, `rev`, `file`, `lstart`, `lend`, etc.

**src/routers.cr**
- `Routers.generate_url(linker, router_type)` generates final URLs by matching host patterns
- Template system with placeholders: `{org}`, `{repo}`, `{rev}`, `{file}`, `{lstart}`, `{lend}`
- Conditional expressions: `{lend > lstart ? "-L{lend}" : ""}` for line ranges
- Router types: `"browse"`, `"blame"`, `"default_branch"`, `"current_branch"`

**src/config.cr**
- `Configs` module stores `DEFAULT_ROUTERS` (hash of router_type => host_pattern => url_template)
- Supports custom router configuration via `Configs.setup(user_routers)`
- Merges user routers with defaults

**src/git.cr**
- `Git` module wraps git commands using `Process.new`
- Key methods:
  - `get_git_root`: Returns repository root
  - `get_branch_remote`: Determines correct remote (handles multiple remotes)
  - `get_closest_remote_compatible_rev`: Finds best commit SHA for URL (tries upstream, HEAD, then ancestors)
  - `is_file_in_rev`, `file_has_changed`: Validates file existence/state
  - `get_default_branch`, `get_current_branch`: Branch information

**src/giturlparser.cr**
- `GitUrlParser.parse(url)` parses various git URL formats (https, ssh, scp-like)
- Returns `GitUrlInfo` record with all URL components
- Handles: `https://github.com/org/repo.git`, `git@github.com:org/repo.git`, etc.

**src/kakoune.cr**
- Loads Kakoune editor configuration from `src/kakoune/rc.kak` at compile time via macro
- Used by `init kakoune` command

### URL Generation Flow

1. User invokes: `gitlinker run -f src/linker.cr -s 10 -e 20`
2. `CLI.run` calls `Linker.make(file)`
3. `Linker.make` gathers git metadata (remote, revision, file path)
4. `Routers.generate_url(linker)` matches host pattern and applies template
5. Final URL printed to stdout

### Router Template System

Templates use placeholder substitution with conditional logic:
- `{org}`, `{repo}`, `{rev}`, `{file}`: Direct substitution
- `{lstart}`: Start line number
- `{lend > lstart ? "-L{lend}" : ""}`: Conditional line range (ternary operator)
- Pattern matching: Host matched via regex (`^github.com`, `^gitlab.com`, etc.)

## Key Design Patterns

- **Factory Pattern**: `Linker.make` creates fully initialized instances
- **Module-based Organization**: Static modules (`Git`, `GitUrlParser`, `Routers`, `Configs`) for functional grouping
- **Template-driven URL Generation**: Separates URL structure from code logic
- **Crystal Records**: Immutable data structures (`GitUrlInfo`, `GitUrlPos`, etc.)