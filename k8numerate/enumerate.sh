#!/usr/bin/env bash
# set -o nounset
set -o errexit
# set -o errtrace
set -o pipefail


_ME=$(basename "${0}")
_VERBOSE=0
_ARGS=()

_QUERY_COMMAND="getent hosts"

verbose() {
    if [[ "${_VERBOSE:-"0"}" -eq 1 ]]
    then
        # Prefix debug message with "bug (U+1F41B)"
        echo -n "🐛  "
        "${@}"
    fi
}

die(){
    # Prefix die message with "cross mark (U+274C)", often displayed as a red x.
    echo -n "❌  "
    "${@}" 1>&2
    exit 1
}

usage() {
    echo -n  "${_ME} [-h|--help] [-v|--verbose] dictionary...

k8numerate - enumerate kubernetes services

Usage:
  ${_ME} [options] services.txt

Options:
  -v --verbose  verbose output
  -h --help show this screen
    "
}


check_dns_commands() {
    if command -v nslookup >/dev/null 2>&1; then
        verbose echo "nslookup available"
        _QUERY_COMMAND="nslookup"
        _QUERY_A_POST="| awk '/^Address: / { print \$2 }'"
        _QUERY_SRV_ARG="-q=SRV"
        _QUERY_SRV_POST="| awk '/service/ { print \$6,\$7 }'"
        return 0
    fi
    
    die echo "no dns utils available"
}

query(){
    eval "$_QUERY_COMMAND $1 $_QUERY_A_POST"
}

query_srv(){
    eval "$_QUERY_COMMAND $_QUERY_SRV_ARG $1 $_QUERY_SRV_POST"
}

main(){
    check_dns_commands
    
    # TODO: fix exit on first error code
    input=$_ARGS
    while IFS= read -r line
    do
        verbose echo "$line"
        ! query "$line"
        ! query_srv "$line"
    done < "$input"
    
}

# Print help if no arguments were passed.
[[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
    case $1 in
        -h|--help) usage >&2; exit ;;
        -v|--verbose) _VERBOSE=1 ;;
        --endopts) shift; break ;;
        *) die echo "invalid option: '$1'." ;;
    esac
    shift
done

# Store the remaining part as arguments.
_ARGS+=("$@")

# Check if dictionary provided
if [[ -z "${_ARGS}" ]]
then
    die echo "dictionary not provided"
fi

main "$@"
