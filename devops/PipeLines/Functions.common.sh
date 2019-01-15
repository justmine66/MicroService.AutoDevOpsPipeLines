#!/bin/bash

set -e

function ToLower()
{
   declare input=$1
   declare output=($(echo "${input}" | tr 'A-Z' 'a-z'))
   eval $2=${output}
}

function Replace()
{
  declare input=$1
  declare sourceExpr=$2
  declare targetExpr=$3
  declare output=${input//${sourceExpr}/${targetExpr}}
  eval $4=${output}
}

function DynamicVariableValueOf()
{
  declare prefix=$1
  declare suffix=$2
  eval "output=\$$prefix$suffix"
  eval $3=${output}
}

function FirstCharUpperCase()
{
    declare input=$1
	declare output=($(echo ${input} | sed -e "s/\b\(.\)/\u\1/g"))
    eval $2=${output}
}

function Substr()
{
    declare input=$1
	declare start=$2
	declare length=$3
	declare output=${input:start:length}
    eval $4=${output}
}