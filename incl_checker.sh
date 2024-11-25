#!/bin/bash

NOW_DIR=$(pwd)
FILE_PATH=$1
DIR_PATH="${NOW_DIR}/${FILE_PATH}"
FILE_NAME_LIST=()
NG_FILE_LIST=()
echo ${DIR_PATH}

cd ${DIR_PATH}

for f in *.h ; do 
    FILE_NAME_LIST+=($(echo $f | sed 's/\.[^\.]*$//'))
done

echo ${FILE_NAME_LIST[1]}

for i in ${FILE_NAME_LIST[@]}; do
    FILE_NAME_UPPER=$(echo  ${i} | awk '{print toupper($0)}')
    INCL_GUARD="_${FILE_NAME_UPPER}_H_"
    echo "INCL_GUARD: ${INCL_GUARD}"
    IFNDEF_CHECK="grep -x \"#ifndef\s${INCL_GUARD}\" ${i}.h"
    DEF_CHECK="grep -x \"#define\s${INCL_GUARD}\" ${i}.h"
    ENDDEF_CHECK="grep -x \"#endif\s/\*\s${INCL_GUARD}\s\*/\" ${i}.h"
    echo "${IFNDEF_CHECK}"
    echo "${DEF_CHECK}"
    echo "${ENDDEF_CHECK}"
    ${IFNDEF_CHECK}
    if grep -q -x "#ifndef\s${INCL_GUARD}" "${i}.h" && \
        grep -x "#define\s${INCL_GUARD}" "${i}.h" && \
        grep -x "#endif\s/\*\s${INCL_GUARD}\s\*/" "${i}.h"; then
        echo "${DIR_PATH}${i}.h IFNDEF check OK"
    else
        echo "${DIR_PATH}${i}.h include check NG"
        NG_FILE_LIST+=(${DIR_PATH}${i}.h)
    fi
    if (${DEF_CHECK}); then
        echo "${DIR_PATH}${i}.h DEFINE check OK"
    fi
    if (${ENDDEF_CHECK}); then
        echo "${DIR_PATH}${i}.h ENDDEF check OK"
    fi
done
echo "NG FILE LIST"
for i in ${NG_FILE_LIST[@]}; do
    echo "${i}"
done

cd ${NOW_DIR}

