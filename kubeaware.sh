#!/bin/bash

[[ -n $DEBUG ]] && set -x

source "$(git rev-parse --show-toplevel)/kube_functions.sh"
[[ -d "${KUBEDIR}" ]] || mkdir -p "${KUBEDIR}"

print_help() {
  cat <<EOF
kube[un]aware

Usage: kubeaware [-g | --global] [-h | --help]

With no arguments, turn on/off kubeaware for this shell instance instance (default).

  -g --global  turn on kubeawareness globally
  -h --help    print this message

EOF
}

main() {
  get_current_context
  get_current_namespace
  if [ "${ZSH_VERSION}" ]; then
    PRE_SYMBOL="%{$fg[blue]%}"
    POST_SYMBOL="%{$fg[white]%} "
    setopt PROMPT_SUBST
    autoload -U add-zsh-hook
    add-zsh-hook precmd sync_kubeaware
  elif [ "${BASH_VERSION}" ]; then
    PRE_SYMBOL='\001\033[34m\002'
    POST_SYMBOL='\001\033[39m\002 '
    PROMPT_COMMAND="sync_kubeaware;${PROMPT_COMMAND}"
  fi
}

main "$@"
