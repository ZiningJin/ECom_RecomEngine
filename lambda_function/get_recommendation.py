import json
import boto3

def lambda_handler(event, context):
    
    user_id = event['headers']['user_id'] # When using API gateway to test
    
    # user_id = json.loads(event['body'])['user_id'] # When using localhost to call this api
    
    s3_client = boto3.client('s3')
    bucket = 'jrde-recommendation-results'
    
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