locals {
  sample-package = "sample.zip"
}

data "archive_file" "sample_lambda" {
    type = "zip"
    source_file = "lambdas/sample/main.py"
    output_path = local.sample-package
}

resource "aws_iam_role" "sample_role" {
  name = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "sample_aws_managed_policy_attachment" {
    role = aws_iam_role.sample_role.name
    policy_arn = data.aws_iam_policy.lambda-basic-execution.arn
}

resource "aws_cloudwatch_log_group" "sample_log_group" {
    name = "/aws/lambda/basic-terraform-demo"
    retention_in_days = 14
}

resource "aws_lambda_function" "basic_terraform_demo" {
  filename      = local.sample-package
  function_name = "basic-terraform-demo"
  role          = aws_iam_role.sample_role.arn
  handler       = "main.lambda_handler"
  timeout = 60
  source_code_hash = data.archive_file.sample_lambda.output_base64sha256
  runtime = "python3.11"
  depends_on = [ aws_cloudwatch_log_group.sample_log_group ]
}

resource "aws_lambda_permission" "sample_permission" {
  statement_id = "Allow-APIGateway_Invoke-sample-Lambda"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.basic_terraform_demo.function_name
  principal = "apigateway.amazonaws.com"
}