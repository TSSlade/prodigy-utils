#!/bin/bash
# Run this from within the home folder of the root (ubuntu) user

VERBOSE=false
DB="prodigy.db"
DSLIST="dataset-names.txt"
EXPORT=false

delimit(){
  printf "=%.0s" {1..30}
  echo ""
}

print_usage(){
  HELPFMT="  %-6s %-20s %-15s %s\n"
  printf "%b" 'Usage:\n\n'
  printf "${HELPFMT}" "flag" "argument" "type" "explanation"
  printf "${HELPFMT}" "----" "--------" "----" "-----------"
  printf "${HELPFMT}" "-d "  "DATABASE" "filepath" "Database file to process"
  printf "${HELPFMT}" "-l" "LISTFILE" "filepath" "File in which to save the list of datasets"
  printf "${HELPFMT}" "-e" "EXPORT" "<none>" "Export the datasets to JSON files"
  printf "${HELPFMT}" "-s" "SUBSET" "int" "# of datasets to return (rather than all available)"
  printf "${HELPFMT}" "-c" "CONSOLIDATIONFILE" "filepath" "File in which to dump consolidated dataset exports [not yet implemented]"
  printf "${HELPFMT}" "-h"  "<none>" "<none>" "Display help"
  printf "${HELPFMT}" "-r"  "<none>" "<none>" "Print references used in developing this script"
  delimit
  exit 1
}

delimit

while getopts 'hrd:l:es:c:' flag; do
  case "${flag}" in
    h) h_flag='true';
            HELP=1 ;;
    r) r_flag='true';
            REFERENCES=1 ;;
    d) d_flag='true';
            DB="${OPTARG}"; printf " >> %-20s %s\n" "Database:" "[${DB}]" ;;
    l) l_flag='true';
            DSLIST="${OPTARG}"; printf " >> %-20s %s\n" "List file:" "[${DSLIST}]" ;;
    e) e_flag='true';
            EXPORT=true; printf " >> %-20s %s\n" "Exporting datasets?" "[${EXPORT}]" ;;
    s) s_flag='true';
            SUBSET="${OPTARG}"; printf " >> %-20s %s\n" "Subsetting:" "[${SUBSET}] dataset(s)" ;;
    c) c_flag='true';
            CONS="${OPTARG}"; printf " >> %-20s %s\n" "Consolidating datasets into file:" "[${CONS}]" ;;
    *) print_usage ;;
  esac
done

[ $HELP ] && print_usage

if [[ $s_flag == 'true' ]];
  then SUBSET_CLAUSE="ORDER BY name DESC LIMIT ${SUBSET};"
  else SUBSET_CLAUSE=";"
fi

delimit
QUERY="SELECT DISTINCT name FROM dataset $SUBSET_CLAUSE"
TASKFMT=" >> %-20s %s\n"
printf "${TASKFMT}" "Executing query:" "[${QUERY}]"
printf "${TASKFMT}" "...on database:" "[${DB}]"
printf "${TASKFMT}" "...exporting to:" "[${DSLIST}]"

delimit
# echo "sqlite3 ${DB} \"${QUERY}\" >> ${DSLIST}"
sqlite3 ${DB} "${QUERY}" > ${DSLIST}

if [[ $EXPORT == true ]];
  then
    [ -f "./prodigy.json" ] && echo "Existing prodigy.json file getting backed up..." && mv prodigy.json prodigy.json.bak
    cat << EOF > prodigy.json
{
"db": "sqlite",
"db_settings": {
  "sqlite": {
    "name": "$(basename $DB)",
    "path": "$(dirname $DB)"
    }
  }
}
EOF
[ ! -d "./exports" ] && echo "./exports dir being created..." && mkdir ./exports
cat ${DSLIST} | xargs -I {} prodigy db-out {} ./exports
fi

if [ $REFERENCES ]; then
delimit
printf "%b\n" \
  "This script was made possible by the many authors" \
  "who contributed to developing and improving the following resources:" \
  "  -  https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable" \
  "  -  https://jeredsutton.com/post/bash-bestish-practices-part-4/" \
  "  -  https://dev.to/rpalo/advanced-argument-handling-in-bash-377b" \
  "  -  https://stackoverflow.com/a/10973280" \
  "  -  https://unix.stackexchange.com/questions/396223/bash-shell-script-output-alignment" \
  "  -  https://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash" \
  "  -  https://www.shellcheck.net" \
  "  -  https://cameronnokes.com/blog/working-with-json-in-bash-using-jq" \
  "  -  https://stackoverflow.com/questions/2664740/extract-file-basename-without-path-and-extension-in-bash" \
  "  -  https://stackoverflow.com/a/22698106" \
  "  -  https://stackoverflow.com/questions/6121091/get-file-directory-path-from-file-path" \
  "And of course, the good folks at Explosion.ai (makers of Prodigy):" \
  "  -  https://support.prodi.gy/t/specify-database-to-use-with-db-out/3427"
delimit
fi

# TODO: Implement CONSOLIDATION functions
# TODO: Implement check for prodigy executable in local env
# TODO: Implement check for local prodigy.json; if not present, warn user (when verbose)
# TODO: Implement dry-run equivalent for whole script
# TODO: Make -r flag enabled on high-verbosity output
# TODO: Wrap output section above in verbosity catcher and also make each line conditional on the flag being triggered
