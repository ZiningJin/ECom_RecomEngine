'''
Lambda Function
DataFlow: API Gateway as trigger, get user_id from CloudWatch and recommendations from S3 SageMaker output Bucket 
'''
import json
import boto3

def lambda_handler(event, context):
    
    # user_id as query header
    user_id = event['headers']['user_id']
    
    s3_client = boto3.client('s3')
    bucket = 'de-ers.imba-sagemaker-output'
   
    # Get latest uploaded recommendation.json file
    response = s3_client.list_objects(Bucket=bucket)
    sorted_obj = sorted(response['Contents'], key=lambda obj: obj['LastModified'], reverse=True)
    
    filename = sorted_obj[0]['Key']
    
    s3_resource = boto3.resource('s3')
    content = s3_resource.Object(bucket, filename).get()['Body'].read().decode('utf-8')
    json_data = json.loads(content)

    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'products': json_data.get(str(user_id))
        })
    }