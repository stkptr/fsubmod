# fsubmod

`fsubmod` is a little script for dealing with submodules in Fossil. It's very simple, with just a few commands.

## Commands

### `add ?OPTIONS? NAME URL`

Adds the repository at `URL` which can be later accessed with `NAME`. The `NAME` is also the directory for the submodule.

Options:
- `-c` clone the repository immediately
- `-i` add the directory to the ignore-glob

### `rm ?OPTIONS? NAME`

Removes the submodule named `NAME`.

Options:
- `-d` remove the directory as well
- `-i` remove the ignore-glob line

### `update`

Goes through all the repositories and performs a `fossil up`. If the repository is not initialized it will be with `fossil clone` and `fossil open`.

### `list`

List the currently added submodules, one per line, with the `NAME` and `URL` separated by a tab.

### `help`

Prints help information.


## Files involved

`fsubmod` will put a file in the current directory named `.submodules` containing the submodule data. The file is very simple, having one line per submodule. Each line starts with the name of the submodule, then a tab `\t`, and the URL last.

The actual Fossil repository files are put into a directory named `.subrepos`.
