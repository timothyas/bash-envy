#! /bin/bash

dirIn=../era-interim-long/diags
files="${dirIn}/*"
dirOut=diags

for f in $files
do
        num=$( echo "${f}" | grep -o -E '[0-9]+' )
        if [ "${num}" -ge "114636" ] ; then
                cp "${f}" "${dirOut}"
        fi
done
