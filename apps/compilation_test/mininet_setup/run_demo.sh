#!/bin/bash

# Copyright 2013-present Barefoot Networks, Inc. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $THIS_DIR/env.sh

P4C_BM_SCRIPT=$P4C_BM_PATH/p4c_bm/__main__.py

SWITCH_PATH=$BMV2_PATH/targets/simple_switch/simple_switch

CLI_PATH=$BMV2_PATH/tools/runtime_CLI.py

# P4 target compilation
mkdir -p "$THIS_DIR/switch_jsons"
PREFIX="SUM"
NUM_SWITCHES=2
for ((i=1;i<=${NUM_SWITCHES};i++))
do
    $P4C_BM_SCRIPT "$THIS_DIR/../p4src/${PREFIX}_s${i}.p4" --json "$THIS_DIR/switch_jsons/${PREFIX}_s${i}.json"
done

SWITCHES_JSON=""
for ((i=1;i<=${NUM_SWITCHES};i++))
do
    SWITCHES_JSON="${SWITCHES_JSON} $THIS_DIR/switch_jsons/${PREFIX}_s${i}.json"
done


# This gives libtool the opportunity to "warm-up"
sudo $SWITCH_PATH >/dev/null 2>&1
sudo PYTHONPATH=$PYTHONPATH:$BMV2_PATH/mininet/ python topo.py \
    --behavioral-exe $SWITCH_PATH \
    --json ${SWITCHES_JSON} \
    --cli $CLI_PATH