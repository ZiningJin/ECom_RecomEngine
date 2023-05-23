# create rest api gateway
resource "aws_api_gateway_rest_api" "imba-API" {
  name = "de-ers.imba-API.test0523"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# create resource
resource "aws_api_gateway_resource" "imba-resource" {
  rest_api_id = aws_api_gateway_rest_api.imba-API.id
  parent_id   = aws_api_gateway_rest_api.imba-API.root_resource_id
  path_part   = "de-ers-imba-resource"
}

# create method
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.imba-API.id
  resource_id   = aws_api_gateway_resource.imba-resource.id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.user_id" = true
  }
}

# integration
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.imba-API.id
  resource_id             = aws_api_gateway_resource.imba-resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn

}

# method response
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.imba-API.id
  resource_id = aws_api_gateway_resource.imba-resource.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

#api stage
resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.imba-API.id
  stage_name    = "de-ers-imba-API-stage"
}

#api deployment
resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    aws_api_gateway_integration.integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.imba-API.id
}



# Set trigger
# Allowing API Gateway to Access Lambda
# Lambda permission
resource "aws_lambda_permission" "apigw_lambda" {
  depends_on = [
    aws_api_gateway_deployment.example,
  ]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.imba-API.execution_arn}/*/*"
}