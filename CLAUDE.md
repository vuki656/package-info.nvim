# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Neovim plugin that shows npm/yarn/pnpm/bun dependency versions as virtual text in `package.json`, and wraps install/delete/update/change-version commands. Runtime deps: `nui.nvim` (all UI), plus `yq` on `$PATH` for pnpm workspace catalog support.

## Commands

```sh
make test                                                       # full suite
make test FILE=lua/package-info/tests/suites/actions            # one folder
make test FILE=lua/package-info/tests/suites/actions/hide_spec.lua  # one file
make lint                                                       # stylua + luacheck + prettier
make clean                                                      # drop .tests and temp
```

Notes:

- The runner is **mini.test**, not plenary — plenary was archived, with critical-bug support ending 2026-06-30.
- `lua/package-info/tests/minimal_init.lua` is the only entry point. It wipes the runtimepath down to `$VIMRUNTIME`, git-clones mini.test and nui.nvim into `.tests/site/pack/deps/start/` if missing, redirects the XDG dirs into `.tests/`, and calls `MiniTest.setup()` with a `find_files` that reads `$PI_TEST_PATH` (a directory is globbed for `**/*_spec.lua`, a file is used as-is). Your own nvim config is never involved and there is nothing to install by hand. `make clean` refreshes the deps.
- CI runs the exact same `make test`, only with `NVIM=` pointed at a downloaded appimage. Do not re-type the nvim invocation anywhere.
- `$PI_TEST_PATH` defaults to `lua/package-info/tests/suites`, never `.`, so the cloned dependencies' own spec files are not collected.
- Spec files keep the `*_spec.lua` name but use mini.test structure: build a set with `MiniTest.new_set({ hooks = { pre_case = reset.all, post_case = reset.all } })`, assign cases as `T["name"] = function() ... end`, `return T`. Assertions are `MiniTest.expect.equality` / `no_equality` / `no_error`.
- **All 29 files share one Neovim process.** mini.test has no per-file isolation, so anything global leaks between files unless `tests/utils/reset.lua` clears it — that is why it resets highlight groups and deep-copies `config.__DEFAULT_OPTIONS` rather than aliasing it.
- mini.test has no spy facility. `tests/utils/spy.lua` provides `spy.on(module, key)` returning `{ count, calls }`, plus `was_called_with`. `reset.all()` calls `spy.revert_all()`, so spies never need manual teardown.
- Tests write fixtures to `./temp/<uuid>/`, created on demand by `tests/utils/file.lua`; `make test` removes `./temp` afterwards, pass or fail. All fixture paths are relative, so nvim must run from the repo root.
- Cases run sequentially and must stay that way: they share `./temp`, one global state table, and the current buffer.
- A failing case makes `make test` exit non-zero and the remaining cases still run; failures are listed under `Fails` at the end. An error at spec **load** time would otherwise leave headless nvim hanging forever, which is why the Makefile wraps `MiniTest.run` in a `pcall` that falls back to `1cquit`.
- `make lint` mirrors `.github/workflows/default.yml`. CI pins stylua to 0.17.0. `.tests/` is excluded from luacheck via `.luacheckrc` `exclude_files`; stylua skips dot-directories on its own, and prettier is fed the git-tracked markdown files so it never walks `.tests/` or untracked scratch directories.

## Architecture

Entry flow, spread over several files:

1. `config.setup()` registers everything: the plugin namespace, a clean `PackageInfoAutogroup`, and BufEnter autocmds. `utils/register-autocmd.lua` filters every autocmd to the `package.json` pattern.
2. On BufEnter: `config.__register_package_manager()` detects the manager, `core.load_plugin()` validates the buffer (name ends in `package.json`, non-empty, JSON decodes) and sets `state.is_loaded`, then `parser.parse_buffer()` fills `state.dependencies.installed` / `.invalid`.
3. `actions/show.lua` runs `npm outdated --json` (or `pnpm outdated --json`) via `utils/job.lua` and writes `state.dependencies.outdated`.
4. `virtual_text.display()` walks `state.buffer.lines`, resolves a dependency name per line, and sets an extmark.

Things that are non-obvious:

- **Everything routes through one global mutable `state.lua`.** `state.buffer.id` is the single buffer the plugin operates on. Every action early-returns on `not state.is_loaded`.
- **`init.lua` requires modules inside function bodies**, and `utils/logger.lua` `pcall`-requires config, both to break circular dependencies. Keep that pattern when adding modules.
- **Results are cached for one hour** via `state.last_run.should_skip()`. Bypass with `show({ force = true })` or `:PackageInfoShowForce`. The cache is global, not per-buffer, so `core.load_plugin` drops `state.dependencies.outdated` and resets `last_run` whenever it loads a package.json at a different path — switching between two package.json files refetches each time. `helpers/refresh.lua` invalidates it after install/delete/update/change-version and re-runs `show` forced when the virtual text is currently displayed; without that a newly installed old version renders as up to date.
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
