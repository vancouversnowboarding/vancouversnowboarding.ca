#!/bin/bash -e
DATE=$1
if [ -z $DATE ]; then
  echo "USAGE\nimage.sh 2021-12-28"
  exit 1
fi

for FNAME in $(ls -c /tmp/*.{jpg,jpeg,JPG,png,PNG} | tac); do
  if [[ "${FNAME}" =~ /feature\. ]]; then
    NEW_FILENAME=`echo "${FNAME}" | sed -e "s|/tmp/|assets/images/${DATE}-|"`
    echo $NEW_FILENAME
    magick "${FNAME}" -scale '1200x900' "${NEW_FILENAME}"
    magick "${NEW_FILENAME}" -gravity center -crop '1200x628+0+0' "${NEW_FILENAME}"
  else
    NEW_FILENAME=`echo "${FNAME}" | sed -e "s|/tmp/|assets/images/${DATE}-|"`
    echo $NEW_FILENAME
    magick "${FNAME}" -scale '1200x900>' "${NEW_FILENAME}"
    # magick mogrify -resize '1600:1200^' "${NEW_FILENAME}"
  fi
done
