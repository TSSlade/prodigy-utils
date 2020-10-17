#!/bin/bash
# Run this from within the home folder of the root (ubuntu) user

VERBOSE=false
DB="prodigy.db"
DSLIST="dataset-names.txt"
EXPORT=false


print_usage() {
  printf "Usage: ..."
}

while getopts 'd:l:e:s:c:' flag; do
  case "${flag}" in
    d) d_flag='true';
            DB="${OPTARG}"; echo ">> Database: [${DB}]" ;;
    l) l_flag='true';
            DSLIST="${OPTARG}"; echo ">> List file: [${DSLIST}]" ;;
    e) e_flag='true';
            EXPORT=true; echo ">> Exporting datasets?: [${EXPORT}]" ;;
    s) s_flag='true';
            SUBSET="${OPTARG}"; echo ">> Subsetting: [${SUBSET}] datasets" ;;
    c) c_flag='true';
            CONS="${OPTARG}"; echo ">> Consolidating datasets into file [${CONS}]" ;;
    *) print_usage
       exit 1 ;;
  esac
done

# if [[ ${s_flag} == false ]]; then
#   SUBSET=${cat}
# fi

# https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable

if [[ $s_flag == 'true' ]];
  then SUBSET_CLAUSE="ORDER BY name DESC LIMIT ${SUBSET};"
  else SUBSET_CLAUSE=";"
fi

QUERY=$(echo "SELECT DISTINCT name FROM dataset $SUBSET_CLAUSE")
echo $QUERY

echo "sqlite3 ${DB} \"${QUERY}\" >> ${DSLIST}"
sqlite3 ${DB} "${QUERY}" >> ${DSLIST}

# if [[ $EXPORT == true ]];
#   then cat ${DSLIST} | xargs dataset prodigy db-out dataset > dataset.json
# fi