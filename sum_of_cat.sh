#!/bin/bash

# Ensure file name is provided
if [ "x$1" == "x" ]; then
  echo "Error! No file name provided."
  echo "USAGE: $0 FILENAME"
  exit 1
fi


# Primary sizes only
PGB=$(cat $1 | awk '{print $10}' | grep gb | tr -d 'gb' | paste -sd+ - | bc)
PMB=$(cat $1 | awk '{print $10}' | grep mb | tr -d 'mb' | paste -sd+ - | bc)
PKB=$(cat $1 | awk '{print $10}' | grep kb | tr -d 'kb' | paste -sd+ - | bc)

if [ "x$PGB" == "x" ]; then PGB=1; fi
if [ "x$PMB" == "x" ]; then PMB=1; fi
if [ "x$PKB" == "x" ]; then PKB=1; fi

# All storage (include primary and all replicas)
ALLGB=$(cat $1 | awk '{print $9}' | grep gb | tr -d 'gb' | paste -sd+ - | bc)
ALLMB=$(cat $1 | awk '{print $9}' | grep mb | tr -d 'mb' | paste -sd+ - | bc)
ALLKB=$(cat $1 | awk '{print $9}' | grep kb | tr -d 'kb' | paste -sd+ - | bc)

if [ "x$ALLGB" == "x" ]; then ALLGB=1; fi
if [ "x$ALLMB" == "x" ]; then ALLMB=1; fi
if [ "x$ALLKB" == "x" ]; then ALLKB=1; fi

# Do the math
PRIMARY_EXPR="${PGB}+(${PMB}/1024)+(${PKB}/1024/1024)"
PRIMARY=$(echo ${PRIMARY_EXPR} | bc)
TOTAL_EXPR="${ALLGB}+(${ALLMB}/1024)+(${ALLKB}/1024/1024)"
TOTAL=$(echo ${TOTAL_EXPR} | bc)

# Output
echo "Primary-only: ${PRIMARY} GB --- Total Storage: ${TOTAL} GB"
