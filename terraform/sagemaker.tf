# create sagemaker notebook instance
resource "aws_sagemaker_notebook_instance" "de-ers-imba-modelling" {
  name          = "de-ers-imba-modelling"
  role_arn      = aws_iam_role.SageMaker_IAM_Role.arn
  instance_type = "ml.m5.xlarge"
  lifecycle_config_name  =aws_sagemaker_notebook_instance_lifecycle_configuration.notebook_config.name
}

# create sagemaker lifecycle configurations
resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "notebook_config" {
  name = "de-ers-imba-sagemaker-lifecycle-config"
  #   on_create = filebase64("../Sagemaker/imba_lifecycle_config.bash")
  on_start = filebase64("../sagemaker/de-ers-imba-sagemaker-lifecycle-config.bash")
}