#!/usr/bin/env bash

set -Eeo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -r v2.1.0

Generates the K8s YAML files for configuring your voyage via GitOps.

Available options:

-h, --help                Print this help and exit
-v, --verbose             Print script debug info
--voyage                  Path to your voyage directory
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1}
  msg "$msg"
  exit "$code"
}

parse_params() {
  force=0
  releaseVersion=''

  # Default to VOYAGE environment variable of set
  if [[ -n ${VOYAGE:-} ]]; then
      voyage=${VOYAGE%/}
  fi

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    --voyage)
      voyage="${2-}"      
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")
  [[ -z "${voyage}" ]] && die "Where to sailor? Please provide the '--voyage' parameter or set VOYAGE environment variable."

  return 0
}

parse_params "$@"
setup_colors

VOYAGE=$voyage
valuesFile=$VOYAGE/values.yaml
relaseName=$(basename $VOYAGE)

msg "${YELLOW}We be packin' ol $relaseName to plunder and glory, yarr!"

mkdir -p $VOYAGE/.wayfinder/generated/gitops/helm

outFile=$VOYAGE/.wayfinder/generated/gitops/helm/wayfinder.yaml

# Create an empty output file if it doesn't exist
if [[ ! -f $outFile ]]
then
  touch $outFile
fi

# Backup last generated resources
mv $outFile $outFile.bak || true

helm template $releaseName ../../chart --namespace wayfinder --values=$valuesFile --set GitOps.Flux.enabled=true --set render-subcharts=false --set komodorAgent.apiKey=$KOMOKW_API_KEY --set komodorAgent.clusterName=wayfinder-demo  > $outFile

# Show the new resources in a nice output
dyff yaml $outFile

msg "${YELLOW}Linting..."
yamllint $outFile

# Compare what changed
dyff between $outFile.bak $outFile

msg "${GREEN}Me duffle be full, we be sailin' soon.${NOFORMAT}"
