#!/bin/bash 

#vim: ts=8 sw=2 si expandtab

set -o errexit
set -o nounset
set -o pipefail

MODE=docker
IMAGE=alex-kea
CONF=

function help {
  echo "$1 [options]"
  cat <<EOT
    Starts kea-dhcp6 server 
    -l, --local    Run locally instead of in docker 
    -i, --image    Docker image to invoke (default $IMAGE)
    -c, --config   yml config file for kea server (default none)
    -h, --help
EOT
exit 1
}

OPTARG=

function arg_forbidden { if [[ -n "${OPTARG:-}" ]]; then echo "Argument forbidden for --$OPT" >&2; exit 2; fi }
function arg_required { if [[ -z "${OPTARG:-}" ]]; then echo "Argument required for --$OPT" >&2; exit 2; fi }
while getopts hli:c:-: OPT; do
  if [[ "$OPT" = "-" ]]; then
    OPT="${OPTARG%%=*}"
    OPTARG="${OPTARG#$OPT}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    l | local)    arg_forbidden; MODE=local;;
    i | image)    arg_required; IMAGE=$OPTARG;;
    c | config)    arg_required; CONF=$OPTARG;;
    h | help)    arg_forbidden; help $0;;
    ??* ) echo "Illegal option --$OPT"; exit 2 ;;
    ? ) echo "Illegal option -$OPT"; exit 2 ;;
  esac
done

shift $((OPTIND-1))

# Starts kea docker. Will assume kea docker is already built

# first argument is docker image 

if [[ "${MODE}" == "docker" ]]; then
    DOCKER_OPTS=
    if [[ -n "$CONF" ]]; then
        DOCKER_OPTS="-v $(realpath $CONF):/app/kea-conf.yml $DOCKER_OPTS"
    fi
    docker run --rm --net=host $DOCKER_OPTS "${IMAGE}"
else
    KEA_OPTS=
    if [[ -n "$CONF" ]]; then
        yq . < $CONF > kea-conf.json
        KEA_OPTS="-c kea-conf.json" 
    fi
    sudo /usr/sbin/kea-dhcp6 ${KEA_OPTS}
fi
