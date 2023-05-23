# ---------------------------------------------------------------------------------------------------------------------
#  IAM role: Glue Service
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "AWSGlueServiceRole" {
  name        = "AWSGlueServiceRole.SYD.DE-ers"
  description = "IAM Role for Glue Service"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "glue.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

# attach policies to IAM role
resource "aws_iam_role_policy_attachment" "AmazonRDSFullAccess" {
  role       = aws_iam_role.AWSGlueServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole" {
  role       = aws_iam_role.AWSGlueServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
resource "aws_iam_role_policy_attachment" "AWSGlueConsoleFullAccess" {
  role       = aws_iam_role.AWSGlueServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSGlueSchemaRegistryFullAccess" {
  role       = aws_iam_role.AWSGlueServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueSchemaRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSGlueSchemaRegistryReadonlyAccess" {
  role       = aws_iam_role.AWSGlueServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueSchemaRegistryReadonlyAccess"
}

# attach AmazonS3FullAccess policy
resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess_ForGlue" {
  role       = aws_iam_role.AWSGlueServiceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


# ---------------------------------------------------------------------------------------------------------------------
# IAM role: Sagemaker
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "SageMaker_IAM_Role" {
  name        = "AWSSagemakerRole.SYD.DE-ers"
  description = "IAM Role for SageMaker"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "sagemaker.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

# create custom policy named "SageMakertoS3"
resource "aws_iam_policy" "SageMakertoS3" {
  name        = "SageMakertoS3"
  description = "Custom SageMaker to S3 policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:AbortMultipartUpload",
            "s3:DeleteObject"
          ],
          "Resource" : [
            "arn:aws:s3:::de-ers.imba-glue-output/*",
            "arn:aws:s3:::de-ers.imba-sagemaker-output/*"
          ]
        },
        {
          "Sid" : "VisualEditor1",
          "Effect" : "Allow",
          "Action" : [
            "s3:ListAllMyBuckets",
            "s3:GetBucketCORS",
            "s3:CreateBucket",
            "s3:ListBucket",
            "s3:PutBucketCORS",
            "s3:GetBucketLocation"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "VisualEditor2",
          "Effect" : "Allow",
          "Action" : [
            "s3:GetBucketAcl",
            "s3:PutObjectAcl"
          ],
          "Resource" : [
            "arn:aws:s3:::de-ers.imba-glue-output/*",
            "arn:aws:s3:::de-ers.imba-glue-output",
            "arn:aws:s3:::de-ers.imba-sagemaker-output/*",
            "arn:aws:s3:::de-ers.imba-sagemaker-output"
          ]
        }
      ]
    }
  )
}

# attach policies to IAM role
resource "aws_iam_role_policy_attachment" "SageMakertoS3_attachment" {
  role       = aws_iam_role.SageMaker_IAM_Role.name
  policy_arn = aws_iam_policy.SageMakertoS3.arn
}

resource "aws_iam_role_policy_attachment" "AmazonSageMakerFullAccess" {
  role       = aws_iam_role.SageMaker_IAM_Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}


# ---------------------------------------------------------------------------------------------------------------------
# IAM role:lambda_s3tosagemaker
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_s3tosagemaker" {
  name        = "AWSLambdaS3toSagemakerRole.SYD.DE-ers"
  description = "IAM Role for lambda_s3tosagemaker"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

# create custom policy "AWSLambdaVPCAccessExecutionRole"
resource "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  name        = "AWSLambdaVPCAccessExecutionRole"
  description = "Custom AWSLambdaVPCAccessExecutionRole policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

# create custom policy "AWSLambdaBasicExecutionRole For lambda s3tosagemaker"
resource "aws_iam_policy" "AWSLambdaBasicExecutionRole_Forlambdas3tosagemaker" {
  name        = "AWSLambdaBasicExecutionRole-Forlambdas3tosagemaker"
  description = "Custom AWSLambdaBasicExecutionRole For lambda s3 to sagemaker"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "logs:CreateLogGroup",
          "Resource" : "arn:aws:logs:ap-southeast-2:778725022589:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            "arn:aws:logs:ap-southeast-2:778725022589:log-group:/aws/lambda/de-ers_s3tosagemaker:*"
          ]
        }
      ]
    }
  )
}

# attach custom policy "AWSLambdaVPCAccessExecutionRole" to IAM role
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole_Fors3tosagemaker" {
  role       = aws_iam_role.lambda_s3tosagemaker.name
  policy_arn = aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn
}

# attach custom policy "AWSLambdaBasicExecutionRole" to IAM role "lambda_s3tosagemaker"
resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_Forlambdas3tosagemaker" {
  role       = aws_iam_role.lambda_s3tosagemaker.name
  policy_arn = aws_iam_policy.AWSLambdaBasicExecutionRole_Forlambdas3tosagemaker.arn
}

# attach AmazonS3FullAccess policy
resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess_Forlambdas3tosagemaker" {
  role       = aws_iam_role.lambda_s3tosagemaker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# attach AmazonSageMakerFullAccess policy
resource "aws_iam_role_policy_attachment" "AmazonSageMakerFullAccess_Forlambdas3tosagemaker" {
  role       = aws_iam_role.lambda_s3tosagemaker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM role: lambda_api
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_api" {
  name        = "AWSLambdaAPIRole.SYD.DE-ers"
  description = "IAM Role for lambda_api"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

# create custom policy "AWSLambdaBasicExecutionRole For lambda api"
resource "aws_iam_policy" "AWSLambdaBasicExecutionRole_Forlambdaapi" {
  name        = "AWSLambdaBasicExecutionRole-Forlambdaapi"
  description = "Custom AWSLambdaBasicExecutionRole For lambda api"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "logs:CreateLogGroup",
          "Resource" : "arn:aws:logs:ap-southeast-2:778725022589:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            "arn:aws:logs:ap-southeast-2:778725022589:log-group:/aws/lambda/de-ers_API:*"
          ]
        }
      ]
    }
  )
}

# attach policiey S3 Full Access to IAM role "lambda_api"
resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess_Forlambdaapi" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# attach custom policy "AWSLambdaVPCAccessExecutionRole" to "api" and "lambda_api" IAM role 
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole_ForAPI" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn
}
# attach custom policy "AWSLambdaBasicExecutionRole" to IAM role "lambda_api"
resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole_Forlambdaapi" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = aws_iam_policy.AWSLambdaBasicExecutionRole_Forlambdaapi.arn
}

