# fsubmod

`fsubmod` is a little script for dealing with submodules in Fossil. It's very simple, with just a few commands.

## Commands

### `add [-c -i] <name> <url>`

Adds the repository at `<url>` which can be later accessed with `<name>`. The `<name>` is also the directory for the submodule. Use `-c` to clone it immediately. `-i` adds the directory to the ignore-glob.

### `rm [-d -i] <name>`

Removes a submodule. Use `-d` to remove the directory as well. Use `-i` to also remove the ignore-glob line.

### `update`

Goes through all the repositories and performs a `fossil up`. If the repository is not initialized it will be with `fossil clone`.

### `list`

List the currently added submodules.

### `help`

Prints help information.


## Files involved

`fsubmod` will put a file in the current directory named `.submodules` containing the submodule data. The file is very simple, having one line per submodule. Each line starts with the name of the submodule, then a tab `\t`, and the URL last.

The actual Fossil repository files are put into a directory named `.subrepos`.
