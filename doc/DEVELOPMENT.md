# Package Info Development

- This doc provides useful information to help with the development of the plugin

## Commands

    make test                                                              # run the whole suite
    make test FILE=lua/package-info/tests/suites/actions/hide_spec.lua     # run a single file or folder
    make lint                                                              # stylua, luacheck and prettier
    make clean                                                             # remove .tests and temp

- Tests use [mini.test](https://github.com/echasnovski/mini.test). No manual setup is needed: `lua/package-info/tests/minimal_init.lua` clones `mini.test` and `nui.nvim` into the gitignored `.tests/` directory on first run, and your own Neovim config is not used.
- Run from the repository root. Test fixtures are written to `./temp/` using relative paths.
- Every spec file shares one Neovim process, so global state must be cleared in `tests/utils/reset.lua`. Cases run sequentially because they share `./temp`, one global state table and the current buffer.
- `tests/utils/spy.lua` stands in for the spy facility mini.test does not provide.

## Project Structure

    ├── actions                             # Contains all user runnable plugin actions
    ├── helpers                             # Plugin specific helper functions
    ├── tests                               # Project tests for all the functionality
    ├── ui                                  # User interface components
    ├── utils                               # Generic helper variables and functions
    ├── config.lua                          # Setup of user passed configuration options
    ├── core.lua                            # Responsible loading the plugin in the correct scenarios
    ├── init.lua                            # Exports all the user facing commands
    ├── parser.lua                          # Handles package.json parsing and installed dependency loading
    ├── state.lua                           # Global plugin state
    └── virtual_text.lua                    # Handles all virtual text related operations
