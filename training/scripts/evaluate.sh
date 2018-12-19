#!/bin/sh
# Distributed under MIT license

# this script evaluates the best model (according to BLEU early stopping)
# on newstest2017, using detokenized BLEU (equivalent to evaluation with
# mteval-v13a.pl)

script_dir=`dirname $0`
main_dir=$script_dir/../
data_dir=$main_dir/data
working_dir=$main_dir/model

# variables (toolkits; source and target language)
. $main_dir/vars

# TensorFlow devices; change this to control the GPUs used by Nematus.
# It should be a list of GPU identifiers. For example, '1' or '0,1,3'
# Currently translate.py only uses a single GPU so there is no point
# assigning more than one.
devices=0

test_prefix=newstest2017
test=$test_prefix.bpe.$src
ref=$test_prefix.$trg
model=$working_dir/model.best-valid-script

# decode
CUDA_VISIBLE_DEVICES=$devices python $nematus_home/nematus/translate.py \
     -m $model \
     -i $data_dir/$test \
     -o $working_dir/$test.output.dev \
     -k 12 \
     -n

# postprocess
$script_dir/postprocess.sh < $working_dir/$test.output.dev > $working_dir/$test.output.postprocessed.dev

# evaluate with detokenized BLEU (same as mteval-v13a.pl)
$nematus_home/data/multi-bleu-detok.perl $data_dir/$ref < $working_dir/$test.output.postprocessed.dev
