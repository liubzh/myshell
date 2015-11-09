#!/bin/bash

# For shell scripts under ~/mysh args auto-completion.
# 为~/mysh目录下的命令实现参数自动补全功能

#!/bin/bash

#complete -W '-p --patch -h --help -b --branch -c --commit' merge

function _foo() {
    local cur prev opts

    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-h --help -f --file -o --output"

    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi

    # -f|--file enable auto complete filenames.
    case "${prev}" in
        -f|--file)
            complete -o filenames -f foo
            ;;
    esac

}
complete -F _foo foo
