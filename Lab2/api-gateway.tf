locals {
  api_gw_type = "REGIONAL"
}

resource "aws_api_gateway_rest_api" "sample" {
  name = "sample-api"
  description = "API Gateway used for terraform demo"

  endpoint_configuration {
    types = [ local.api_gw_type ]
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/apigwlogs/sample-api"
  retention_in_days = 14
}


resource "aws_api_gateway_stage" "api_stage" {
  depends_on = [ aws_api_gateway_deployment.api_deploy ]
  deployment_id = aws_api_gateway_deployment.api_deploy.id
  rest_api_id = aws_api_gateway_rest_api.sample.id
  stage_name = "default"

  cache_cluster_enabled = false
  
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = join(", ", [
        "requestId: $context.requestId",
        "ip: $context.identity.sourceIp",
        "caller: $context.identity.caller",
        "user: $context.identity.user",
        "requestTime: $context.requestTime",
        "httpMethod: $context.httpMethod",
        "resourcePath: $context.resourcePath",
        "status: $context.status",
        "protocol: $context.protocol",
        "responseLength: $context.responseLength",
    ])
  }
}


resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = [ 
    aws_api_gateway_integration.sample_integration,
    aws_api_gateway_method.sample_method
   ]

   rest_api_id = aws_api_gateway_rest_api.sample.id
   stage_description = "API Gateway Deployment for terraform demo"

   triggers = {
     redeployment = md5(file("api-gateway.tf"))
   }

   lifecycle {
     create_before_destroy = true
   }
   
}

resource "aws_api_gateway_method_settings" "api_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.sample.id
  stage_name = aws_api_gateway_stage.api_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level = "INFO"
  }
}

resource "aws_api_gateway_resource" "message" {
  rest_api_id = aws_api_gateway_rest_api.sample.id
  parent_id = aws_api_gateway_rest_api.sample.root_resource_id
  path_part = "message"
}

resource "aws_api_gateway_method" "sample_method" {
    rest_api_id = aws_api_gateway_rest_api.sample.id
    resource_id = aws_api_gateway_resource.message.id
    http_method = "GET"
    authorization = "NONE"
    authorization_scopes = []
    request_models = {}
}

resource "aws_api_gateway_integration" "sample_integration" {
    rest_api_id = aws_api_gateway_rest_api.sample.id
    resource_id = aws_api_gateway_method.sample_method.resource_id
    http_method = aws_api_gateway_method.sample_method.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.basic_terraform_demo.invoke_arn
  
}