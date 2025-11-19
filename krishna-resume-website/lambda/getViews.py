import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-2')
table = dynamodb.Table('cloud-resume-table')

def lambda_handler(event, context):
    response = table.get_item(Key={
        'Id': '0'
    })
    views = response['Item']['views']
    views = int(views) + 1
    print(views)
    response = table.put_item(Item={
        'Id': '0',
        'views': views
    })
    return {
        'statusCode': 200,  
        'headers': {
            'Access-Control-Allow-Origin': '*' 
        },
        'body': json.dumps(views)
    }

