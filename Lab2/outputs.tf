output "endpoint" {
  value = "${aws_api_gateway_deployment.api_deploy.invoke_url}${aws_api_gateway_stage.api_stage.stage_name}/${aws_api_gateway_resource.message.path_part}"
}