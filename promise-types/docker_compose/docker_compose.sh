#!/bin/bash
#
# docker_compose.sh @SURF
#
required_attributes="state"
optional_attributes="envfile"
all_attributes_are_valid="no"


LOG_PREFIX="${0##*/}"

declare -A DOCKER_STATES
DOCKER_STATES["start"]="running"
DOCKER_STATES["restart"]="running"
DOCKER_STATES["up"]="running"
DOCKER_STATES["stop"]="exited"
DOCKER_STATES["kill"]="exited"


do_validate() {
    response_result="valid"


    if [[ ! -v DOCKER_STATES[${request_attribute_state}] ]]
    then
        log error "${LOG_PREFIX}:Invalid state specified:'${request_attribute_state}'"
        response_result="invalid"
    fi
}

do_evaluate() {

    local docker_cmd
    local docker_query

    # Default the promise is alwasys 'kept'
    response_result="kept"

    if [[ -n ${request_attribute_envfile} ]]
    then
        docker_envfile="--env-file ${request_attribute_envfile}"
    else
        docker_envfile=""
    fi

    docker_compose_cmd="" # not found yet
    result=$(docker compose version)
    if [[ -n ${result} ]]
    then
      docker_compose_cmd="docker compose"
    elif command -v docker-compose >/dev/null 4>&1
    then
      docker_compose_cmd="docker-compose"
    else
      log error "${LOG_PREFIX}:Cannot find either 'docker compose' or 'docker-compose' commands."
      response_result="not_kept"
      return 1
    fi
    log debug "${LOG_PREFIX}:Found docker compose command: ${docker_compose_cmd}"
    docker_cmd="${docker_compose_cmd} --file=${request_promiser} ${docker_envfile}"
    docker_up="${docker_cmd} up --detach"

    log verbose "${LOG_PREFIX}:${request_promiser}"

    docker_ps_output=$(${docker_cmd} ps --format=json 2>&1)
    exit_code=$?
    oneline=$(echo ${docker_ps_output})
    log verbose "${LOG_PREFIX}:ps output: ${oneline}, exit_code=${exit_code}"
    if [[ "$exit_code" -ne 0 ]]
    then
        oneline=$(echo ${docker_ps_output})
        log error "${LOG_PREFIX}:${docker_cmd} ps failed. exit code: ${exit_code}, output: ${oneline}"
        response_result="not_kept"
        return 1
    fi
    if ! $(${docker_cmd} ps --help | grep -- --format >/dev/null)
    then
        log error "${LOG_PREFIX}:${docker_cmd} does not support --format=json. Please upgrade to a newer version, probably >= 2.0.0"
        response_result="not_kept"
        return 1
    fi

    # format has been changed since version 2.21.0
    docker_status=$(echo ${docker_ps_output} | jq -s '.[] | if type=="array" then . else [.] end' | jq -r '.[] | .Name + ":" + .State + ":" + .Health + ":" + .Service')
    if [[ $? -ne 0 ]]
    then
        log error "${LOG_PREFIX}:Could not parse json output of ${docker_cmd} ps"
        response_result="not_kept"
        return 1
    fi

    if [[ -z ${docker_ps_output} ]]
    then
        case "${DOCKER_STATES[${request_attribute_state}]}" in
            "running")
                result=$(${docker_up} 2>&1)
                if [[ $? -ne 0 ]]
                then
                    log error "${LOG_PREFIX}:'${docker_up}' failed with:'${result}'"
                    response_result="not_kept"
                    return 1
                else
                    log info "${LOG_PREFIX}:Started all containers with:'${docker_up}'"
                    response_result="repaired"
                fi
                ;;
            *)
                response_result="kept"
                ;;
        esac

    elif [[ ${request_attribute_state} == "up" ]]
    then
        log info "${LOG_PREFIX}:Recreate all containers with:'${docker_cmd} up'"
        result=$(${docker_up})
        if [[ $? -ne 0 ]]
        then
            log error "${LOG_PREFIX}:'${docker_up}' failed with:'${result}'"
            response_result="not_kept"
        else
            log info "${LOG_PREFIX}:Started all containers with:'${docker_up}'"
            response_result="repaired"
            return 0
        fi
    elif [[ ${request_attribute_state} == "restart" ]]
    then
        log info "${LOG_PREFIX}:Restarted all containers with:'${docker_cmd} restart'"
        result=$(${docker_cmd} restart 2>&1)
        if [[ $? -ne 0 ]]
        then
            log error "${LOG_PREFIX}:Restart failed with:'${result}'"
            response_classes="${request_promiser}_failed"
            return 1
        else
            response_classes="${request_promiser}_restarted"
        fi
    else
        for s in ${docker_status}
        do
            local name
            local service
            local health
            local state

            name=$(echo $s | awk -F: '{ print $1 }')
            state=$(echo $s | awk -F: '{ print $2 }')
            health=$(echo $s | awk -F: '{ print $3 }')
            service=$(echo $s | awk -F: '{ print $4 }')

            if [[ ${state} != ${DOCKER_STATES[${request_attribute_state}]} ]]
            then
                log info "${LOG_PREFIX}:service:'${service}' state:'${state}' is different then requested:'${DOCKER_STATES[${request_attribute_state}]}'"
                result=$(${docker_cmd} ${request_attribute_state} ${service} 2>&1)
                if [[ $? -ne 0 ]]
                then
                    response_result="not_kept"
                    return 1
                else
                    response_result="repaired"
#                    return 0 # although, do we have more work to do!?
                fi
            fi
        done
    fi
}

. "$(dirname "$0")/cfengine.sh"
module_main "docker_compose" "1.0"
