##
 # Copyright 2008 Alexander Sorokin, University of Illinois at Urbana-Champaign.
 # Copyright 2007-2008 Amazon Technologies, Inc.
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at:
 #
 # http://aws.amazon.com/apache2.0
 #
 # This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
 # OR CONDITIONS OF ANY KIND, either express or implied. See the
 # License for the specific language governing permissions and
 # limitations under the License.
 ##

#!/usr/bin/env bash

LBL=workload
DIR=`pwd`

cd ${MTURK_CMD_HOME}/bin/

./deleteHITs.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 -successfile $DIR/$LBL.success -approve -expire 

cd $DIR
