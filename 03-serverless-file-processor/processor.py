import boto3
import json
import os
import urllib.parse

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Get the file that was just uploaded to the input bucket
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    
    # Read the uploaded file
    response = s3_client.get_object(Bucket=bucket, Key=key)
    content = response['Body'].read().decode('utf-8')
    
    # Process the content
    word_count = len(content.split())
    processed_content = f"WORD COUNT: {word_count} words\n\n{content.upper()}"
    
    # Save the result to the output bucket
    output_bucket = os.environ['OUTPUT_BUCKET']
    output_key = f"processed-{key}"
    
    s3_client.put_object(
        Bucket=output_bucket,
        Key=output_key,
        Body=processed_content,
        ContentType='text/plain'
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': f'Processed {key} successfully'})
    }