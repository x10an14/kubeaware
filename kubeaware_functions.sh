#!/bin/bash

[[ -n $DEBUG ]] && set -x

KUBECTL=kubectl
KUBE_SYMBOL='⎈'
DEFAULT_NAMESPACE_ALIAS="~"
KUBEDIR="${HOME}/.kube"
KUBEAWARE_GLOBAL_ENABLED_FILE="${KUBEDIR}/.kubeaware_enabled"

kubeaware_prompt() {
  if [[ ( -f "${KUBEAWARE_GLOBAL_ENABLED_FILE}" || -n ${KUBEAWARE} ) && -z "${KUBEUNAWARE}" ]]; then
    echo -e "[${PRE_SYMBOL}${KUBE_SYMBOL}${POST_SYMBOL}${CURRENT_CTX}:${CURRENT_NS}]"
  fi
}

kubeaware() {
  if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
    print_help
    return
  fi

  if [[ "${1}" == "-g" || "${1}" == "--global" ]]; then
    touch "${KUBEAWARE_GLOBAL_ENABLED_FILE}"
  else
    export KUBEAWARE="true"
    unset KUBEUNAWARE
  fi
}

kubeunaware() {
  if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
    print_help
    return
  fi

  if [[ "${1}" == "-g" || "${1}" == "--global" ]]; then
    rm -f "${KUBEAWARE_GLOBAL_ENABLED_FILE}"
  fi

  export KUBEUNAWARE="true"
}

sync_kubeaware() {
  # only update context if it's changed
  KUBECONFIG_FILES=${KUBECONFIG:-"${KUBEDIR}/config"}

  # check for changes in all kubeconfig files
  local IFS="$(':' read -ra CONFIG <<< "$KUBECONFIG_FILES")"
  KUBECONFIG_CONTENT="$(for element in "${CONFIG[@]}"; do cat "$element"; done)"
  
  local CURR_HASH=$(echo ${KUBECONFIG_CONTENT} | shasum | cut -d" " -f1)

  if [[ ${CURR_HASH} != ${LAST_HASH} ]]; then
    get_current_namespace
    get_current_context
    export LAST_HASH=${CURR_HASH}
  fi
}

get_current_namespace() {
  CURRENT_NS="$(${KUBECTL} config view --minify --output 'jsonpath={..namespace}' 2> /dev/null)"

  if [[ ${CURRENT_NS} == "default" ]]; then
    unset CURRENT_NS
  fi

  CURRENT_NS="${CURRENT_NS:-${DEFAULT_NAMESPACE_ALIAS}}"
}

get_current_context() {
  CURRENT_CTX="$(${KUBECTL} config current-context 2>/dev/null)"
  CURRENT_CTX="${CURRENT_CTX:-n/a}"
}

