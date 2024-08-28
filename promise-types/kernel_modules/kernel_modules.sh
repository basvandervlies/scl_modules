#!/bin/bash
#
# kernel_modules.sh @SURF
#
#set -x
required_attributes="policy"
optional_attributes=""
all_attributes_are_valid="no"

KERNEL_MODULES_LOADED="/proc/modules"


LOG_PREFIX="${0##*/}"

do_validate() {
    response_result="valid"
}

do_evaluate() {

    local result

    # 0 does not exist, if >0 it exists
    result=$(grep --count --regexp="^${request_promiser} " ${KERNEL_MODULES_LOADED} 2>/dev/null)

    # Default the promise is alwasys 'kept'
    response_result="kept"


    log debug "${LOG_PREFIX}:${request_promiser}:${result}"

    case "${request_attribute_policy}" in
        absent)
            if [[ ${result} -eq 1 ]]
            then
                log info "${LOG_PREFIX}:${request_promiser}:present so remove"
                result=$(modprobe --remove --quiet ${request_promiser})
                if [[ $? -eq 0 ]]
                then
                    response_result="repaired"
                else
                    log error "${LOG_PREFIX}:${request_promiser} failed to remove"
                    response_result="not_kept"
                fi
            fi
        ;;
        present)
            if [[ ${result} -eq 0 ]]
            then
                log info "${LOG_PREFIX}:${request_promiser}:absent so add"
                result=$(modprobe --quiet ${request_promiser})
                if [[ $? -eq 0 ]]
                then
                    response_result="repaired"
                else
                    log error "${LOG_PREFIX}:${request_promiser} not found"
                    response_result="not_kept"
                fi
            fi
        ;;
    esac

}

. "$(dirname "$0")/cfengine.sh"
module_main "kmod" "1.0"
