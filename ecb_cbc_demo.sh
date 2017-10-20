#!/bin/sh

if ! (which identify && which convert) > /dev/null;
then
  echo "Cannot find ImageMagick." >&2
  exit 1
fi

if ! which openssl > /dev/null;
then
  echo "Cannot find OpenSSL." >&2
  exit 1
fi

if [ "$#" -ne 2 ];
then
  echo "Usage: $0 <filename> <password>" >&2
  exit 1
fi

DIMEN=`identify $1 2> /dev/null | head -1 | awk '{print $3}'`
BASE=`echo $1 | sed 's/\.[^.]*$//g'`
PASS=$2

if [ "$DIMEN" = "" ];
then
  echo "Cannot retrieve dimensions for $1. Not an image?" >&2
  exit 1
fi

convert $1 -depth 16 $BASE.rgb
openssl enc -aes-128-ecb -nosalt -pass pass:"$PASS" \
            -in $BASE.rgb -out ${BASE}_ecb.rgb
openssl enc -aes-128-cbc -nosalt -pass pass:"$PASS" \
            -in $BASE.rgb -out ${BASE}_cbc.rgb
convert -size $DIMEN -depth 16 ${BASE}_ecb.rgb ${BASE}_ecb.png
convert -size $DIMEN -depth 16 ${BASE}_cbc.rgb ${BASE}_cbc.png
rm $BASE.rgb ${BASE}_ecb.rgb ${BASE}_cbc.rgb


