#!/bin/bash
# Run this from within the home folder of the root (ubuntu) user

verbose=false
SRC="output.json"
JQARG="[ . | { wav: .meta.file, start: .audio_spans[].start, end: .audio_spans[].end, label: .audio_spans[].label } ] | unique | .[] | [.wav, .start, .end, .label] | @csv"
TARG="filtered.csv"

print_usage() {
  printf "Usage: ..."
}

while getopts 's:t:j:' flag; do
  case "${flag}" in
    s) s_flag='true';
            SRC="${OPTARG}"; echo ">> Source file: [${SRC}]" ;;
    t) t_flag='true';
            TARG="${OPTARG}"; echo ">> Target file: [${TARG}]" ;;
    j) j_flag='true';
            JQARG="${OPTARG}"; echo ">> Alternative JQ pipeline: [${JQARG}]" ;;
    *) print_usage
       exit 1 ;;
  esac
done

echo `cat "${SRC}" | jq "${JQARG}" > "${TARG}"`
cat "${SRC}" | jq "${JQARG}" > "${TARG}"