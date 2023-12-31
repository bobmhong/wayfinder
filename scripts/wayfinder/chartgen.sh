#!/usr/bin/env bash
set -Eeo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") --voyage <path/to/voyage>

Generates the chart.yaml for developing new voyages or wayfinder chart releases.

Available options:

-h, --help                Print this help and exit
-v, --verbose             Print script debug info
-y, --voyage              Path to your voyage directory
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

setup_colors

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
working_dir=$(pwd -P)

if [[ ${script_dir} == ${working_dir} ]]; then
  root="../../"
  mkdir -p ${root}${VOYAGE}/.wayfinder/generated/
else
  die "${RED}Please run this script from the scripts/wayfinder directory or use make from the root directory."
fi

source "${script_dir}/common.sh"
voyage=${VOYAGE:-$DEFAULT_VOYAGE}

parse_params() {

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
  
  [[ -z "${voyage}" ]] && die "${RED}Where to sailor? Please provide the '--voyage' parameter or set VOYAGE environment variable."

  return 0
}

parse_params "$@"

VOYAGE=$voyage

if [[ ${VOYAGE} == ${DEFAULT_VOYAGE} ]]; then
  msg "${BLUE}Welcome Greenbeard - You've chosen the default voyage on ${GREEN}$(basename ${VOYAGE}). ${BLUE}Good for trying out yer sea legs.${NOFORMAT}"
else
  msg "${YELLOW}Welcome aboard ${GREEN}$(basename ${VOYAGE})${BLUE}!${NOFORMAT}"
fi

valuesFile=${root}${VOYAGE}/values.yaml

if [[ ! -f $valuesFile ]]; then
  die "${RED}Sorry matey - I can't find yer belongins. Please ensure a values.yaml file exists in the voyage directory."
fi

msg "${YELLOW}Pack yer bags while we generate ol charty...${NOFORMAT}"

template=chart.tpl
# template=echo.tpl
gomplate -d values=${valuesFile} -f ${script_dir}/templates/${template} > ${root}${VOYAGE}/.wayfinder/generated/Chart.yaml

dyff yaml ${root}${VOYAGE}/.wayfinder/generated/Chart.yaml

msg "${GREEN}Chart plotted.${NOFORMAT}"

msg "${YELLOW}Linting..."
yamllint ${root}${VOYAGE}/.wayfinder/generated/Chart.yaml

diff_exit_code=0
# Compare existing chart to generated chart
dyff between ${root}chart/Chart.yaml ${root}${VOYAGE}/.wayfinder/generated/Chart.yaml --set-exit-code || diff_exit_code=$?

if [[ ${diff_exit_code} -ne 0 ]]; then

  msg "${BLUE}Avast, are ye sure o' yer course?${NOFORMAT}"
  # Copy the generated chart to the chart directory
  cp -i ${root}${VOYAGE}/.wayfinder/generated/Chart.yaml ${script_dir}/../../chart/Chart.yaml

  ${script_dir}/purgecache.sh

  ${script_dir}/update-dependencies.sh

else
  echo "✔ no changes detected in generated Chart.yaml"
fi
