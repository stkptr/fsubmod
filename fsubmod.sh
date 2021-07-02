#!/bin/sh

progname="$0"

subdir=".subrepos"
subfile=".submodules"

fossil_settings=".fossil-settings"
fossil_ignore="$fossil_settings/ignore-glob"

# POSIX
mktemp() {
    name="/tmp/$(basename "$progname").$$"
    touch "$name"
    echo "$name"
}

ignore() {
    if [ -d "$fossil_settings" ]; then
        echo "$1" >> "$fossil_ignore"
    fi
}

# Adds the .submodules and .subdir to the ignore
initial_ignore() {
    ignore "$subdir/"
    ignore "$subfile"
}


# Add command

# command_add <subfile> [<options>] <name> <url>
command_add() {
    subfile="$1"
    shift

    while getopts "ci" name; do
        case $name in
            c)
                clone=1
                ;;
            i)
                ignore=1
                ;;
        esac
    done

    shift $(( $OPTIND - 1 ))

    # Perform first-time initialization
    if [ ! -e "$1" ]; then
        initial_ignore
        mkdir -p "$subdir"
    fi

    # Add the line to the .submodules
    printf "%s\t%s\n" "$1" "$2" >> "$subfile"

    if [ $clone ]; then
        init "$1" "$2"
    fi

    if [ $ignore ]; then
        ignore "$1"
    fi
}


# Remove command

# command_remove <subfile> <name>
command_remove() {
    subfile="$1"
    shift

    while getopts "di" name; do
        case $name in
            d)
                delete=1
                ;;
            i)
                ignore=1
                ;;
        esac
    done

    shift $(( $OPTIND - 1 ))

    temp="$(mktemp)"

    # Remove tabs from name
    name="$(echo "$1" | tr -d '\t')"

    # Perform the removal
    sed -e "/$name\t.*/d" "$subfile" > "$temp"

    mv -f "$temp" "$subfile"

    if [ $delete ]; then
        rm -rf "$1"
    fi

    if [ "$ignore" = 1 -a -d "$fossil_settings" ]; then
        temp2="$(mktemp)"
        sed -e "/$name/d" "$fossil_ignore" > "$temp2"
        mv -f "$temp2" "$fossil_ignore"
    fi
}


# Update command

# init <name> <url>
init() {
    dir="$1"
    url="$2"
    name=$(basename "$dir") # this could cause conflicts

    fossil clone "$url" "$subdir/$name.fossil"
    mkdir -p "$dir"
    cd "$dir"
    fossil open "$subdir/$name.fossil"
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


# List command

# command_list <subfile>
command_list() {
    cat "$1"
}


# Help command

# command_help <program_name>
command_help() {
    cat << EOF
Usage: $1 add/rm/update/list/help ?OPTIONS?

Manage submodules for Fossil

add ?OPTIONS? NAME URL
    Add the repository at URL under the directory NAME
    Options:
       -c   Perform the initial clone
       -i   Add the submodule to the ignore-glob
rm ?OPTIONS? NAME
    Remove the repository under the directory <name> from the update list
    Options:
       -d   Delete submodule directory
       -i   Remove corresponding lines in the ignore-glob
update
    Update/initialize all repositories
list
    List currently added submodules
help
    Print this screen
EOF
}


case "$1" in
    "add")
        shift
        command_add "$subfile" $*
        ;;
    "rm")
        shift
        command_remove "$subfile" $*
        ;;
    "update")
        command_update "$subfile"
        ;;
    "list")
        command_list "$subfile"
        ;;
    "help")
        command_help "$0"
        ;;
    "")
        echo "$0: no command provided"
        command_help "$0"
        exit 1
        ;;
    *)
        echo "$0: command '$1' not supported"
        command_help "$0"
        exit 1
        ;;
esac
