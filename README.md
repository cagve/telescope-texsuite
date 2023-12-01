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

|Command | Mapping | Explication |
|--------|---------|-------------|
|`:Telescope texsuite newcommands` | leader+lc | List user definition commands |
|`:Telescope texsuite labels` |leader+ll |List labels |
|`:Telescope texsuite headings` | leader+lh |List headings |
|`:Telescope texsuite frames` | leader+lf |List of frames  |



## TODO (Roadmap)
* [ ] Headings function is slow.
* [ ] Check for included files.

