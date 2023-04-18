import json
import boto3

'''
1. create lambda function 'imbafunction', do not choose trigger, remember IAM role modification
2. create new REST API, choose 'imbafunction', create resource 'imbaResource', within resource create method POST
3. In POST method, headers add user_id as required
4. write python code to get user_id from cloudwatch which is generated based on your API Gateway call activities, and then get product_id from json based on
your user_id
5. In API Gateway, write user_id:2717 and test
'''

def lambda_handler(event, context):
    
    print(event)
    user_id = event['headers']['user_id']
    print(user_id)
    
    s3_client = boto3.client('s3')
    bucket = 'charlie-jrdataeng'
    
    # Get latest uploaded recommendation.json file
    response = s3_client.list_objects(Bucket=bucket)
    sorted_obj = sorted(response['Contents'], key=lambda obj: obj['LastModified'], reverse=True)
    
    filename = sorted_obj[0]['Key']
    
    s3_resource = boto3.resource('s3')
    content = s3_resource.Object(bucket, filename).get()['Body'].read().decode('utf-8')
    json_data = json.loads(content)
    print(json.dumps({'products': json_data.get(str(user_id))}))
    
    return {
        'statusCode': 200,
        'body': json.dumps({'products': json_data.get(str(user_id))})
    }