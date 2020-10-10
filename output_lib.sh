#!/bin/sh

if [ -n "$nocolor" ] && [ "$nocolor" = "nocolor" ]; then
  bldred=''
  bldgrn=''
  bldblu=''
  bldylw=''
  txtrst=''
else
  bldred='\033[1;31m'
  bldgrn='\033[1;32m'
  bldblu='\033[1;34m'
  bldylw='\033[1;33m' # Yellow
  bld35='\033[1;35m' # Yellow
  txtrst='\033[0m'
fi

logit () {
  if [ $standout = 1 ]
  then
    printf "%b\n" "$1" | tee -a "$logger"
  else
    printf "%b\n" "$1"  >> "$logger"
  fi
}

info () {
  infoCount=`expr $infoCount + 1`
  if [ $standout = 1 ]
  then
    printf "%b\n" "${bldblu}[INFO]${txtrst} $1" | tee -a "$logger"
  else
    printf "%b\n" "${bldblu}[INFO]${txtrst} $1"  >> "$logger"
  fi
}

suggest (){
  if [ $standout = 1 ]
  then
    printf "%b\n" "${bld35}[INFO]${txtrst} $1" | tee -a "$logger"
  else
    printf "%b\n" "${bld35}[INFO]${txtrst} $1"  >> "$logger"
  fi
}

pass () {
  passCount=`expr $passCount + 1`
  if [ $standout = 1 ]
  then
    printf "%b\n" "${bldgrn}[PASS]${txtrst} $1" | tee -a "$logger"
  else
    printf "%b\n" "${bldgrn}[PASS]${txtrst} $1" >> "$logger"
  fi
}

warn () {
  warnCount=`expr $warnCount + 1`
  if [ $standout = 1 ]
  then
    printf "%b\n" "${bldred}[WARN]${txtrst} $1" | tee -a "$logger"
  else
    printf "%b\n" "$1"  >> "$logger"
  fi
}

note () {
  noteCouunt=`expr $noteCouunt+1`
  if [ $standout = 1 ]
  then
    printf "%b\n" "${bldylw}[NOTE]${txtrst} $1" | tee -a "$logger"
  else
    printf "%b\n" "${bldylw}[NOTE]${txtrst} $1" >> "$logger"
  fi
}

yell () {
  printf "%b\n" "${bldylw}$1${txtrst}\n"
}

beginjson () {
  printf "{\n  \"dockerbenchsecurity\": \"%s\",\n  \"start\": %s,\n  \"tests\": [" "$1" "$2" | tee "$logger.json" 2>/dev/null 1>&2
}

endjson (){
  printf "\n  ], \"checks\": %s, \"score\": %s, \"info\": %s, \"pass\": %s, \"warn\": %s, \"note\": %s, \"end\": %s \n}\n" "$1" "$2" "$3" "$4" "$5" "$6" "$7" | tee -a "$logger.json" 2>/dev/null 1>&2
}

logjson (){
  printf "\n  \"%s\": \"%s\"," "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
}

infojson (){
  printf "\n  \"%s\": \"%s\"," "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
}

SSEP=
SEP=
startsectionjson() {
  printf "%s\n    {\"id\": \"%s\", \"desc\": \"%s\",  \"results\": [" "$SSEP" "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
  SEP=
  SSEP=","
}

endsectionjson() {
  printf "\n    ]}" | tee -a "$logger.json" 2>/dev/null 1>&2
}

starttestjson() {
  printf "%s\n      {\"id\": \"%s\", \"desc\": \"%s\", " "$SEP" "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
  SEP=","
}

resulttestjson() {
  if [ $# -eq 1 ]; then
      printf "\"result\": \"%s\"}" "$1" | tee -a "$logger.json" 2>/dev/null 1>&2
  elif [ $# -eq 2 ]; then
      # Result also contains details
      printf "\"result\": \"%s\", \"details\": \"%s\"}" "$1" "$2" | tee -a "$logger.json" 2>/dev/null 1>&2
  else
      # Result also includes details and a list of items. Add that directly to details and to an array property "items"
      itemsJson=$(printf "["; ISEP=""; for item in $3; do printf "%s\"%s\"" "$ISEP" "$item"; ISEP=","; done; printf "]")
      printf "\"result\": \"%s\", \"details\": \"%s: %s\", \"items\": %s}" "$1" "$2" "$3" "$itemsJson" | tee -a "$logger.json" 2>/dev/null 1>&2
  fi
}
