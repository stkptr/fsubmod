# fsubmod

`fsubmod` is a little script for dealing with submodules in Fossil. It's very simple, with just a few commands.

## Commands

### `add [-i] <name> <url>`

Adds the repository at `<url>` which can be later accessed with `<name>`. The `<name>` is also the file path for the repository. Use `-i` to initialize it.

### `rm [-d] <name>`

Removes a submodule. Use `-d` to remove the directory as well.

### `update`

Goes through all the repositories and performs a `fossil pull`. If the repository is not initialized it will be.

### `help`

Prints help information.


## Files involved

`fsubmod` will put a file in the current directory named `.submodules` containing the submodule data. The file is very simple, having one line per submodule. Each line starts with the name of the submodule, then a tab `\t`, and the URL last.
