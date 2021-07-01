#!/bin/sh

# Add command

# command_add <subfile> <name> <url>
command_add() {
    printf "%s\t%s\n" "$2" "$3" >> "$1"
}


# Remove command

# cat <subfile> | remove <name>
remove() {
    IFS=$(printf "\t")
    while read name url; do
        if [ "$1" != "$name" ]; then
            echo "$line"
        fi
    done
}

# command_remove <subfile> <name>
command_remove() {
    temp="$1-temp"

    cat "$1" | remove "$2" > "$temp"

    mv -f "$temp" "$1"
}


# Update command

# init <name> <url>
init() {
    dir="$1"
    url="$2"
    name=$(basename "$dir") # this could cause conflicts

    fossil clone "$url" ".fossil/$name.fossil"
    mkdir -p "$dir"
    cd "$dir"
    fossil open ".fossil/$name.fossil"
}

# up <name>
up() {
    cd "$1"
    fossil up
}

# update_single <name> <url>
update_single() {
    if [ -e "$1" ]; then
        up "$1"
    else
        init "$1" "$2"
    fi
}

# command_update <subfile>
command_update() {
    IFS=$(printf "\t")
    while read name url; do
        d="$PWD"
        update_single "$name" "$url"
        cd "$d"
    done < "$1"
}


# Help command

# command_help <program_name>
command_help() {
    cat << EOF
Usage: $1 add/rm/update/help [options...]

Manage submodules for Fossil

add [-i] <name> <url>
    Add the repository at the URL under the directory <name>
    -i performs initialization
rm [-d] <name>
    Remove the repository under the directory <name> from the update list
    -d also deletes the associated files
update
    Update/initialize all repositories
help
    Print this screen
EOF
}


subfile=".submodules"


case "$1" in
    "add")
        command_add "$subfile" "$2" "$3"
        ;;
    "rm")
        command_remove "$subfile" "$2"
        ;;
    "update")
        command_update "$subfile"
        ;;
    "help")
        command_help
        ;;
    *)
        echo "$0: Command $1 not supported."
        command_help
        ;;
esac
