import boto3
import json
import os

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    filename = event.get('queryStringParameters', {}).get('filename', 'upload.txt')
    
    bucket = os.environ['INPUT_BUCKET']
    
    presigned_url = s3_client.generate_presigned_url(
        'put_object',
        Params={
            'Bucket': bucket,
            'Key': filename,
            'ContentType': 'text/plain'
        },
        ExpiresIn=300
    )
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'uploadUrl': presigned_url,
            'filename': filename
        })
    }