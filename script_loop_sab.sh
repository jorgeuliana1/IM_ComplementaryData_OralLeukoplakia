#!/bin/bash

# #Param<30M

#pit_s_distilled_224
#coat_lite_small
#swsl_resnext50_32x4d
#resnetv2_50x1_bit_distilled
#tf_efficientnetv2_s_in21ft1k


#models="pit_s_distilled_224 coat_lite_small swsl_resnext50_32x4d resnetv2_50x1_bit_distilled tf_efficientnetv2_s_in21ft1k"
models="resnetv2_50x1_bit_distilled pit_s_distilled_224 coat_lite_small vit_small_patch16_384 regnety_032"
#models="mobilenetv2_120d"

echo $models

# Defaults
method="concat"
config=23
epochs=150
batch_size=30
nfold=5
use_metadata=True
task="TaskIV"
save=/tmp

sched_patience=10
task_base_dir=/tmp/data

# Arguments
while getopts m:c:e:b:f:u:t:p:s:d: flag
do
    case "${flag}" in
        m) method=${OPTARG};;
        c) config=${OPTARG};;
        e) epochs=${OPTARG};;
        b) batch_size=${OPTARG};;
        f) nfold=${OPTARG};;
        u) use_metadata=${OPTARG};;
        t) task=${OPTARG};;
        p) sched_patience=${OPTARG};;
        d) task_base_dir=${OPTARG};;
        s) save=${OPTARG};;



    esac
done

#Main loop
nfold=5
for (( fold = 1; fold <= $nfold; fold++ ))
do
    echo "------------- Fold: $fold -------------"

    for model in $models
    do
        echo "------------- $model -------------"
        echo "------------- $method: $config -------------"


        ## Concatenação
        set -x
        python src/benchmarks/sab/sab.py with _folder=$fold _model_name=$model _use_meta_data=$use_metadata _neurons_reducer_block=90 _comb_method=$method _comb_config=$config _batch_size=$batch_size _epochs=$epochs _task=$task _save_path=$save _task_base_path=$task_base_dir _sched_patience=$sched_patience
        set +x
    done
done
