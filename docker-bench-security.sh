#!/bin/sh
# ------------------------------------------------------------------------------
# Docker Bench for Security
#
# Docker, Inc. (c) 2015-
#
# Checks for dozens of common best-practices around deploying Docker containers in production.
# ------------------------------------------------------------------------------

version='1.3.5'

# Load dependencies
. ./functions_lib.sh
. ./helper_lib.sh

# Setup the paths
this_path=$(abspath "$0")       ## Path of this file including filename
myname=$(basename "${this_path}")     ## file name of this script.
myname=/tmp/docker-bench-security

readonly version
readonly this_path
readonly myname

export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/local/bin:/usr/sbin/"

# Check for required program(s)
req_progs='awk docker grep ss stat'
for p in $req_progs; do
  command -v "$p" >/dev/null 2>&1 || { printf "%s command not found.\n" "$p"; exit 1; }
done

# Ensure we can connect to docker daemon
if ! docker ps -q >/dev/null 2>&1; then
  printf "Error connecting to docker daemon (does docker ps work?)\n"
  exit 1
fi

usage () {
  cat <<EOF
  usage: ${myname} [options]

  -b           optional  Do not print colors
  -h           optional  Print this help message
  -o FMT       optional  Output json format
  -t LANG      optional  Translate to language
  -l FILE      optional  Log output in FILE
  -c CHECK     optional  Comma delimited list of specific check(s)
  -e CHECK     optional  Comma delimited list of specific check(s) to exclude
  -i INCLUDE   optional  Comma delimited list of patterns within a container or image name to check
  -x EXCLUDE   optional  Comma delimited list of patterns within a container or image name to exclude from check
EOF
}

# Get the flags
# If you add an option here, please
# remember to update usage() above.
while getopts bhl:c:o:e:i:x:t: args
do
  case $args in
  b) nocolor="nocolor";;
  h) usage; exit 0 ;;
  o) output="$OPTARG";;
  t) lang="$OPTARG";;
  l) logger="$OPTARG" ;;
  c) check="$OPTARG" ;;
  e) checkexclude="$OPTARG" ;;
  i) include="$OPTARG" ;;
  x) exclude="$OPTARG" ;;
  *) usage; exit 1 ;;
  esac
done


if [ -z "$logger" ]; then
  logger="${myname}.log"
fi

# Load output formating
. ./output_lib.sh

standout=1
if [ "$output" = "json" ] || [ "$output" = "JSON" ]
then
  standout=0
fi

# shellcheck disable=SC1020
if [ $standout = 1 ]
then
  yell_info
fi

# Warn if not root
ID=$(id -u)
if [ "x$ID" != "x0" ]; then
  warn "Some tests might require root to run"
  sleep 3
fi

# Total Score
# Warn Scored -1, Pass Scored +1, Not Score -0

totalChecks=0
currentScore=0
infoCount=0
passCount=0
warnCount=0
noteCount=0

logit "Initializing $(date)\n"
beginjson "$version" "$(date +%s)"

# Load all the tests from tests/ and run them
main () {
  # Get configuration location
  get_docker_configuration_file

  # If there is a container with label docker_bench_security, memorize it:
  benchcont="nil"
  for c in $(docker ps | sed '1d' | awk '{print $NF}'); do
    if docker inspect --format '{{ .Config.Labels }}' "$c" | \
     grep -e 'docker.bench.security' >/dev/null 2>&1; then
      benchcont="$c"
    fi
  done

  # Get the image id of the docker_bench_security_image, memorize it:
  benchimagecont="nil"
  for c in $(docker images | sed '1d' | awk '{print $3}'); do
    if docker inspect --format '{{ .Config.Labels }}' "$c" | \
     grep -e 'docker.bench.security' >/dev/null 2>&1; then
      benchimagecont="$c"
    fi
  done

  if [ -n "$include" ]; then
    pattern=$(echo "$include" | sed 's/,/|/g')
    containers=$(docker ps | sed '1d' | awk '{print $NF}' | grep -v "$benchcont" | grep -E "$pattern")
    images=$(docker images | sed '1d' | grep -E "$pattern" | awk '{print $3}' | grep -v "$benchimagecont")
  elif [ -n "$exclude" ]; then
    pattern=$(echo "$exclude" | sed 's/,/|/g')
    containers=$(docker ps | sed '1d' | awk '{print $NF}' | grep -v "$benchcont" | grep -Ev "$pattern")
    images=$(docker images | sed '1d' | grep -Ev "$pattern" | awk '{print $3}' | grep -v "$benchimagecont")
  else
    containers=$(docker ps | sed '1d' | awk '{print $NF}' | grep -v "$benchcont")
    images=$(docker images -q | grep -v "$benchcont")
  fi

  if [ -z "$containers" ]; then
    running_containers=0
  else
    running_containers=1
  fi


  langprefix='trans/dockerbench-trans-'
  testpath="tests"
  if [ -n "$lang" ]
  then
   testpath="$langprefix$lang"
  fi

  if [ -d $testpath ]
  then
    for test in $testpath/*.sh; do
      . ./"$test"
    done
  else
    echo "testpath specific error"
  fi

  if [ -z "$check" ] && [ ! "$checkexclude" ]; then
    # No options just run
    cis
  elif [ -z "$check" ]; then
    # No check defined but excludes defined set to calls in cis() function
    check=$(sed -ne "/cis() {/,/}/{/{/d; /}/d; p}" functions_lib.sh)
  fi

  for c in $(echo "$check" | sed "s/,/ /g"); do
    if ! command -v "$c" 2>/dev/null 1>&2; then
      [ $standout = 0 ] && echo "Check \"$c\" doesn't seem to exist."
      continue
    fi
    if [ -z "$checkexclude" ]; then
      # No excludes just run the checks specified
      "$c"
    else
      # Exludes specified and check exists
      checkexcluded="$(echo ",$checkexclude" | sed -e 's/^/\^/g' -e 's/,/\$|/g' -e 's/$/\$/g')"

      if echo "$c" | grep -E "$checkexcluded" 2>/dev/null 1>&2; then
        # Excluded
        continue
      elif echo "$c" | grep -vE 'check_[0-9]|check_[a-z]' 2>/dev/null 1>&2; then
        # Function not a check, fill loop_checks with all check from function
        loop_checks="$(sed -ne "/$c() {/,/}/{/{/d; /}/d; p}" functions_lib.sh)"
      else
        # Just one check
        loop_checks="$c"
      fi

      for lc in $loop_checks; do
        if echo "$lc" | grep -vE "$checkexcluded" 2>/dev/null 1>&2; then
          # Not excluded
          "$lc"
        fi
      done
    fi
  done

  [ $standout = 1 ] && printf "\n"
  info "Checks: $totalChecks"
  info "Score: $currentScore"
  info "Info: $infoCount ,  Pass: $passCount,   Warn: $warnCount  , Note: $noteCount  "

  endjson "$totalChecks" "$currentScore" "$infoCount" "$passCount" "$warnCount" "$noteCount" "$(date +%s)"

  [ $standout = 0 ] && cat "${myname}.log.json"
}

main "$@"
