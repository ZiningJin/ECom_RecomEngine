import sagemaker
sess = sagemaker.Session()
bucket = sess.default_bucket()
prefix = "SageMaker-output"

# Define IAM role
import boto3
import re
from sagemaker import get_execution_role
role = get_execution_role()

conda install -c conda-forge pyarrow

import pandas as pd
import pyarrow.parquet as pq
import numpy as np

# Load final features as parquet from S3
s3 = boto3.client("s3")
s3_filepath = "s3://imba-glue-output/sprint3-final-features/part-00000-d5ec00e2-c09f-4454-b38f-2cb5bf05918b-c000.snappy.parquet"

feature_names = [
    "product_id",
    "user_id",
    "user_reorder_ratio",
]
data = pd.read_parquet(s3_filepath,columns=feature_names)

# SageMaker XGBoost has the convention of label in the first column
data["product_id"] = data["product_id"].astype("category").cat.codes
data["user_id"] = data["user_id"].astype("category").cat.codes

# Split the downloaded data into train/test dataframes
train, test = np.split(data.sample(frac=1), [int(0.8 * len(data))])

train.to_parquet("imba_train.parquet")
test.to_parquet("imba_test.parquet")

train['product_id'].dtype

%%time
sagemaker.Session().upload_data(
    "imba_train.parquet", bucket=bucket, key_prefix=prefix + "/" + "training"
)

sagemaker.Session().upload_data(
    "imba_test.parquet", bucket=bucket, key_prefix=prefix + "/" + "validation"
)

region = "ap-southeast-2"
container = sagemaker.image_uris.retrieve("xgboost", region, "1.7-1")

bucket_path = "s3://{}".format(bucket)

%%time
import time
from time import gmtime, strftime

client = boto3.client("sagemaker", region_name=region)
use_amt = True

training_job_name = "imba-xgboost-parquet-training-" + strftime("%Y-%m-%d-%H-%M-%S", gmtime())
print("Training job", training_job_name)

# Ensure that the training and validation data folders generated above are reflected in the "InputDataConfig" parameter below.

create_training_params = {
    "AlgorithmSpecification": {"TrainingImage": container, "TrainingInputMode": "Pipe"},
    "RoleArn": role,
    "OutputDataConfig": {"S3OutputPath": f"{bucket_path}/{prefix}/single-xgboost"},
    "ResourceConfig": {"InstanceCount": 1, "InstanceType": "ml.m5.2xlarge", "VolumeSizeInGB": 20},
    "TrainingJobName": training_job_name,
    "HyperParameters": {
        "max_depth": "5",
        "eta": "0.2",
        "gamma": "4",
        "min_child_weight": "6",
        "subsample": "0.7",
        "objective": "reg:linear",
        "num_round": "10",
        "verbosity": "2",
    },
    "StoppingCondition": {"MaxRuntimeInSeconds": 3600},
    "InputDataConfig": [
        {
            "ChannelName": "train",
            "DataSource": {
                "S3DataSource": {
                    "S3DataType": "S3Prefix",
                    "S3Uri": f"{bucket_path}/{prefix}/training",
                    "S3DataDistributionType": "FullyReplicated",
                }
            },
            "ContentType": "application/x-parquet",
            "CompressionType": "None",
        },
        {
            "ChannelName": "validation",
            "DataSource": {
                "S3DataSource": {
                    "S3DataType": "S3Prefix",
                    "S3Uri": f"{bucket_path}/{prefix}/validation",
                    "S3DataDistributionType": "FullyReplicated",
                }
            },
            "ContentType": "application/x-parquet",
            "CompressionType": "None",
        },
    ],
}

print(
    f"Creating a training job with name: {training_job_name}. It will take between 5 and 6 minutes to complete."
)
client.create_training_job(**create_training_params)

status = client.describe_training_job(TrainingJobName=training_job_name)["TrainingJobStatus"]
print(status)
while status != "Completed" and status != "Failed":
    time.sleep(60)
    status = client.describe_training_job(TrainingJobName=training_job_name)["TrainingJobStatus"]
    print(status)

%%time
from time import gmtime, strftime

model_name = f"{training_job_name}"
print(model_name)

training_name_of_model = training_job_name

info = client.describe_training_job(TrainingJobName=training_name_of_model)

model_data = info["ModelArtifacts"]["S3ModelArtifacts"]
print(model_data)

primary_container = {"Image": container, "ModelDataUrl": model_data}

create_model_response = client.create_model(
    ModelName=model_name, ExecutionRoleArn=role, PrimaryContainer=primary_container
)

print(create_model_response["ModelArn"])

# Create Endpoint & Endpoint config
from time import gmtime, strftime

endpoint_config_name = f'imba-XGBoostEndpointConfig2-{strftime("%Y-%m-%d-%H-%M-%S", gmtime())}'
print(endpoint_config_name)
create_endpoint_config_response = client.create_endpoint_config(
    EndpointConfigName=endpoint_config_name,
    ProductionVariants=[
        {
            "InstanceType": "ml.m4.xlarge",
            "InitialVariantWeight": 1,
            "InitialInstanceCount": 1,
            "ModelName": model_name,
            "VariantName": "AllTraffic",
        }
    ],
)

print(f'Endpoint Config Arn: {create_endpoint_config_response["EndpointConfigArn"]}')

%%time
import time

endpoint_name = f'imba-XGBoostEndpoint2-{strftime("%Y-%m-%d-%H-%M-%S", gmtime())}'
print(endpoint_name)
create_endpoint_response = client.create_endpoint(
    EndpointName=endpoint_name, EndpointConfigName=endpoint_config_name
)
print(create_endpoint_response["EndpointArn"])

resp = client.describe_endpoint(EndpointName=endpoint_name)
status = resp["EndpointStatus"]
print(f"Status: {status}")

while status == "Creating":
    time.sleep(60)
    resp = client.describe_endpoint(EndpointName=endpoint_name)
    status = resp["EndpointStatus"]
    print(f"Status: {status}")

print(f'Arn: {resp["EndpointArn"]}')
print(f"Status: {status}")

# load model for prediction
runtime_client = boto3.client("runtime.sagemaker", region_name=region)

import sys

def do_predict(data, endpoint_name, content_type):
    payload = "\n".join(data)
    response = runtime_client.invoke_endpoint(
        EndpointName=endpoint_name, ContentType=content_type, Body=payload
    )
    result = response["Body"].read().decode("ascii")
    preds = [float(num) for num in result.split("\n")[:-1]]
    return preds

def batch_predict(data, batch_size, endpoint_name, content_type):
    items = len(data)
    arrs = []
    for offset in range(0, items, batch_size):
        arrs.extend(
            do_predict(data[offset : min(offset + batch_size, items)], endpoint_name, content_type)
        )
        sys.stdout.write(".")
    return arrs

# Load test data as libsvm format
from sklearn.datasets import dump_svmlight_file

test_label = test['product_id']
test_value = test[test.columns.difference(['product_id'])]
dump_svmlight_file(test_value,test_label,'./test_svm_file')

%%time
import json

file_name = "test_svm_file"
with open(file_name, "r") as f:
    payload = f.read().strip()

labels = [line.split(" ")[0] for line in payload.split("\n")]
print(labels[0:5])
test_data = payload.split("\n")
preds = batch_predict(test_data, 100, endpoint_name, "text/x-libsvm")

print(
    "\nerror rate=%f"
    % (sum(1 for i in range(len(preds)) if preds[i] != labels[i]) / float(len(preds)))
)

def error_rate(predictions, labels):
    """Return the error rate and confusions."""
    correct = np.sum(predictions == labels)
    total = predictions.shape[0]

    error = 100.0 - (100 * float(correct) / float(total))

    confusions = np.zeros([10, 10], np.int32)
    bundled = zip(predictions, labels)
    for predicted, actual in bundled:
        confusions[int(predicted), int(actual)] += 1

    return error, confusions

import matplotlib.pyplot as plt

%matplotlib inline

NUM_LABELS = 10  # change it according to num_class in your dataset
test_error, confusions = error_rate(np.asarray(preds), np.asarray(labels))
print("Test error: %.1f%%" % test_error)

plt.xlabel("Actual")
plt.ylabel("Predicted")
plt.grid(False)
plt.xticks(np.arange(NUM_LABELS))
plt.yticks(np.arange(NUM_LABELS))
plt.imshow(confusions, cmap=plt.cm.jet, interpolation="nearest")

for i, cas in enumerate(confusions):
    for j, count in enumerate(cas):
        if count > 0:
            xoff = 0.07 * len(str(count))
            plt.text(j - xoff, i + 0.2, int(count), fontsize=9, color="white")