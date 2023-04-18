import json
import boto3

def lambda_handler(event, context):
    
    notebook_instance = 'imba-predict'
    sm = boto3.client('sagemaker')
    
    sm.start_notebook_instance(NotebookInstanceName=notebook_instance)
    
    print('Starting SageMaker notebook instance.')
