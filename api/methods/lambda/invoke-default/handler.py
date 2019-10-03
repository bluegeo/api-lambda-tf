

def handler(event, context):
    """
    An excellent handler

    :param event:
    :param context:
    :return:
    """
    # For example....
    result = event['param1'] + event['param2']

    response = {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": True
        },
        "body": {'result': result},
        "isBase64Encoded": False
    }

    return response
