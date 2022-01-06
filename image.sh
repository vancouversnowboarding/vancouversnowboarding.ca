#!/bin/bash -e
DATE=$1
if [ -z $DATE ]; then
  echo "USAGE\nimage.sh 2021-12-28"
  exit 1
fi

for FNAME in $(ls -c /tmp/*.jpg | tac); do
  NEW_FILENAME=`echo "${FNAME}" | sed -e "s|/tmp/|assets/images/${DATE}-|"`
  echo $NEW_FILENAME
  magick convert -scale '1600x1200' "${FNAME}" "${NEW_FILENAME}"
done
