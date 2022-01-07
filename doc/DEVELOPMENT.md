# Package Info Development

## Project Structure

    ├── actions                             # Contains all user runnable plugin actions
    ├── libs                                # External libs like json parser
    ├── tests                               # Project tests for all the functionality
    ├── ui                                  # User interface components
    ├── utils                               # Generic helper variables and functions
    ├── config.lua                          # Setup of user passed configuration options
    ├── core.lua                            # Responsible for parsing package.json file
    ├── init.lua                            # Exports all the user facing commands
    └── state.lua                           # Global plugin state
