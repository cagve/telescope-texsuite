# TEXSUITE
Set of functions that implement telescope menus using treesitter.

## Prerequisites
1. Telescope
2. Treesitter and latex-treesitter

## Installation
To install it, follow the instruction of your favourite package manger.
```
use 'cagve/telescope-texsuite'
```
Load the extension in your config files
```
require("telescope").load_extension("texsuite")
```

## Usage
There are 3 different functions
1. `:Telescope texsuite newcommands` -> List user definition commands
2. `:Telescope texsuite labels` -> List labels
3. `:Telescope texsuite headings` -> List headings


## TODO (Roadmap)
* [ ] Headings function is slow.
* [ ] Check for included files.

