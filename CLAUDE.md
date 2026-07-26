# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Neovim plugin that shows npm/yarn/pnpm/bun dependency versions as virtual text in `package.json`, and wraps install/delete/update/change-version commands. Runtime deps: `nui.nvim` (all UI), plus `yq` on `$PATH` for pnpm workspace catalog support.

## Commands

```sh
make test                       # full suite (plenary, sequential); creates and removes ./temp
```

A subset — scope `test_directory` to a suite folder (verified working):

```sh
mkdir -p temp
nvim --headless -c "lua require('plenary.test_harness').test_directory('lua/package-info/tests/suites/helpers', { minimal_init='./lua/package-info/tests/minimal.vim', sequential = true })"
```

Do **not** use `nvim -u lua/package-info/tests/minimal.vim -c "PlenaryBustedFile <spec>"` — it hangs, because `minimal.vim` is the child init only and does not put plenary on the runtimepath outside CI's layout.

Notes:

- Tests write fixtures to `./temp/<uuid>/`; the directory must exist before the run and `make test` removes it afterwards.
- The outer nvim runs with your normal config, so plenary.nvim and nui.nvim must be installed there. CI instead clones both into `~/.local/share/nvim/site/pack/vendor/start` and symlinks the repo next to them, which is what `minimal.vim`'s `rtp+=../plenary.nvim` is for.
- Tests are `sequential = true` for a reason: they share `./temp`, one global state table, and the current buffer. Do not parallelise them, and don't run two suites at once.

Lint has no make target — it only exists in `.github/workflows/default.yml`:

```sh
stylua --check .                # pinned to 0.17.0 in CI
luacheck .
prettier --check '**/*.md'
```

## Architecture

Entry flow, spread over several files:

1. `config.setup()` registers everything: the plugin namespace, a clean `PackageInfoAutogroup`, and BufEnter autocmds. `utils/register-autocmd.lua` filters every autocmd to the `package.json` pattern.
2. On BufEnter: `config.__register_package_manager()` detects the manager, `core.load_plugin()` validates the buffer (name ends in `package.json`, non-empty, JSON decodes) and sets `state.is_loaded`, then `parser.parse_buffer()` fills `state.dependencies.installed` / `.invalid`.
3. `actions/show.lua` runs `npm outdated --json` (or `pnpm outdated --json`) via `utils/job.lua` and writes `state.dependencies.outdated`.
4. `virtual_text.display()` walks `state.buffer.lines`, resolves a dependency name per line, and sets an extmark.

Things that are non-obvious:

- **Everything routes through one global mutable `state.lua`.** `state.buffer.id` is the single buffer the plugin operates on. Every action early-returns on `not state.is_loaded`.
- **`init.lua` requires modules inside function bodies**, and `utils/logger.lua` `pcall`-requires config, both to break circular dependencies. Keep that pattern when adding modules.
- **Results are cached for one hour** via `state.last_run.should_skip()`. Bypass with `show({ force = true })` or `:PackageInfoShowForce`.
- **Package manager detection mutates `config.options.package_manager` at runtime**, overriding whatever the user configured. It checks the package.json's own directory for a lock file, then falls back to the git root (monorepo support). Yarn v1 is detected separately via `yarn -v` into `state.has_old_yarn`.
- **`utils/job.lua` derives cwd from the open package.json's directory**, falling back to `getcwd()`. `ignore_error` exists because `npm outdated` exits 1 when it finds outdated packages.
- **`virtual_text.__display_on_line` applies its branches in order: up_to_date → outdated → invalid → pnpm catalog**, each overwriting the previous whole table. The catalog branch wins over an invalid diagnostic. It returns the table only so tests can assert on content the nvim API can't read back.
- **pnpm workspace support is decided at module load time**: `show.lua` evaluates `pnpm.is_workspace()` at file scope, so it is not re-checked per buffer, and `pnpm.workspace_path()` uses `getcwd()` rather than the package.json directory.
- **Statusline integration**: `get_status()` returns the current spinner message; `ui/generic/loading-status.lua` fires `User PackageInfoStatusUpdate` so statuslines can redraw. It supports plain `nvim_echo`, nvim-notify, and snacks.notifier, chosen by `pcall(require, ...)`.
- **Telescope extension lives in `lua/telescope/_extensions/`** — a separate runtimepath namespace from `lua/package-info/`, loaded by `require("telescope").load_extension("package_info")`.

Directory layout is documented in `doc/DEVELOPMENT.md`.

## Conventions

- Exported functions carry a `---` doc block with `@param` / `@return` lines. Private module functions are prefixed `__` (e.g. `config.__register_user_options`), and tests call them directly.
- Tests call `reset.all()` in both `before_each` and `after_each`; `tests/utils/file.lua` builds package.json fixtures.
- The README highlight-group table sits between `<!-- hl_start -->` / `<!-- hl_end -->` markers — update it when `constants.HIGHLIGHT_GROUPS` or the default highlights change.
- `.luacheckrc` uses an explicit `std.globals` allowlist; new globals used in Lua must be added there or luacheck fails.
