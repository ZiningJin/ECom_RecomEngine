#!/bin/bash

set -e
ENVIRONMENT=python3
NOTEBOOK=/home/ec2-user/SageMaker/imba-prediction.ipynb

echo "Activating conda environment"
source /home/ec2-user/anaconda3/bin/activate "$ENVIRONMENT"

echo "Starting notebook"
nohup jupyter nbconvert --ExecutePreprocessor.timeout=-1 --ExecutePreprocessor.kernel_name=python3 --to notebook --execute "$NOTEBOOK" --inplace &

echo "Deactivating conda environment"
conda deactivate

IDLE_TIME=300 # 5 minute

echo "Fetching the autostop script"
wget https://raw.githubusercontent.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/master/scripts/auto-stop-idle/autostop.py

echo "Starting the SageMaker autostop script in cron"
(crontab -l 2>/dev/null; echo "*/1 * * * * /usr/bin/python $PWD/autostop.py --time $IDLE_TIME --ignore-connections") | crontab -