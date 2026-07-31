# Task 6 starter — the /products route, reading the list from S3 instead of a
# hard-coded array.
#
# What you must set up for this to work:
#   1. Upload products.json to a bucket.
#   2. Set an environment variable on the Lambda:  PRODUCTS_BUCKET = your-bucket
#   3. Give the Lambda's EXECUTION ROLE s3:GetObject on that object.
#
# boto3 (the AWS SDK for Python) ships in the Lambda runtime — nothing to install.

import json
import os

import boto3

s3 = boto3.client("s3")
BUCKET = os.environ["PRODUCTS_BUCKET"]  # set as a Lambda env var
KEY = "products.json"


def response(status, data):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(data),
    }


def lambda_handler(event, context):
    route = event.get("routeKey")

    if route == "GET /products":
        # Read the list from S3 on every request. Edit the file in S3 and the
        # API changes with no redeploy — that is the whole point of this task.
        obj = s3.get_object(Bucket=BUCKET, Key=KEY)
        products = json.loads(obj["Body"].read())
        return response(200, {"products": products})

    return response(404, {"error": "wire the other routes back in from handler.py"})
