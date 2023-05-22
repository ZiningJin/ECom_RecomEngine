# ---------------------------------------------------------------------------------------------------------------------
#  Lambdafunction: s3tosagemaker
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "s3tosagemaker" {
  function_name = "de-ers_s3tosagemaker"
  filename = "lambda_code_s3tosagemaker.zip"
  handler  = "de-ers_s3tosagemaker.lambda_handler"
  runtime = "python3.9"
  role    = aws_iam_role.lambda_s3tosagemaker.arn
  timeout = 60
  # vpc_config {
  #   security_group_ids = ["sg-2f193f67"]
  #   subnet_ids         = ["subnet-f79fe2af", "subnet-9cd614fa"]
  # }
}

# Add s3 as trigger to lambda 
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.imba-glue-output.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3tosagemaker.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
# Give permissions
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3tosagemaker.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.imba-glue-output.arn
}

# # ---------------------------------------------------------------------------------------------------------------------
# #  Lambdafunction: api
# # ---------------------------------------------------------------------------------------------------------------------
# resource "aws_lambda_function" "api" {
#   function_name = "de-ers_API"
#   runtime       = "python3.9"
#   filename      = "./lambda_function/lambda_function_get_recommendation.zip"
#   handler       = "get_recommendation.lambda_handler"
#   role          = aws_iam_role.lambda_api.arn
#   timeout       = 60
#   vpc_config {
#     security_group_ids = [aws_security_group.imba-sg.id]
#     subnet_ids         = [aws_subnet.DE-ers-private-subnet-1-ap-southeast-2a.id, aws_subnet.DE-ers-private-subnet-2-ap-southeast-2b.id]
#   }
# }