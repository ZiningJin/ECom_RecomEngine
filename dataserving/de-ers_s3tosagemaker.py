'''
Lambda Function
DataFlow: S3 Glue Output Bucket as trigger, after S3 create object event start SageMaker instance
'''
import json
import boto3

def lambda_handler(event, context):
    
    try:
       notebook_instance = 'de-ers-imba-modelling'
       sm = boto3.client('sagemaker')
    
       sm.start_notebook_instance(NotebookInstanceName=notebook_instance)
       print('Starting SageMaker notebook instance.')
    except Exception as err:
        print(f"error: {err}")
