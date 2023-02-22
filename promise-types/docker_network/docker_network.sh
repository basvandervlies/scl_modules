#!/bin/bash
#
# docker_network.sh @SURF
#
required_attributes="state"
optional_attributes=""
all_attributes_are_valid="no"


LOG_PREFIX="${0##*/}"

do_validate() {
    response_result="valid"
}

do_evaluate() {

    local result

    # 0 does not exist, if >0 it exists
    result=$(docker network inspect ${request_promiser} 2>/dev/null | jq '. | length')

    # Default the promise is alwasys 'kept'
    response_result="kept"


    log debug "${LOG_PREFIX}:${request_promiser}"

    case "${request_attribute_state}" in
        absent)
            if [[ ${result} -ne 0 ]]
            then
                log info "${LOG_PREFIX}: docker network ${request_promiser} present so remove"
                result=$(docker network rm ${request_promiser})
                response_result="repaired"
            fi
        ;;
        present)
            if [[ ${result} -eq 0 ]]
            then
                log info "${LOG_PREFIX}: docker network ${request_promiser} absent so add"
                result=$(docker network create ${request_promiser})
                response_result="repaired"
            fi
        ;;
    esac

}

. "$(dirname "$0")/cfengine.sh"
module_main "docker_network" "1.0"
