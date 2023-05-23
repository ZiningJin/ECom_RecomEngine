# create glue database
resource "aws_glue_catalog_database" "imba-gluedb" {
  name = "de-ers.imba-gluedb"
}

# create glue connection
resource "aws_glue_connection" "imba_glue_connection" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://imba-rdsinstance-instance-1-ap-southeast-2b.cy4i5jen2oog.ap-southeast-2.rds.amazonaws.com:5432/postgres"
    USERNAME            = "postgres"
    PASSWORD            = "A159357abc$!"
  }

  name = "de-ers.imba-glueconnector"

  physical_connection_requirements {
    availability_zone      = "ap-southeast-2b"
    security_group_id_list = ["sg-09f32fa88564eb94e"]
    subnet_id              = "subnet-001f36eda5f93e1cf"
  }
}

# create glue crawler
resource "aws_glue_crawler" "example" {
  # Name of the crawler
  name         = "de-ers.imba-gluecrawler"
  role         = aws_iam_role.AWSGlueServiceRole.arn
  table_prefix = "imba-crawler-output-"

  jdbc_target {
    connection_name = aws_glue_connection.imba_glue_connection.name
    path            = "postgres/public/%"
  }

  # Glue database where results are written.
  database_name = aws_glue_catalog_database.imba-gluedb.name

  # must create IAM role first
  depends_on = [
    aws_iam_role.AWSGlueServiceRole,
    aws_glue_catalog_database.imba-gluedb,
    aws_glue_connection.imba_glue_connection
  ]
}

# create glue job
resource "aws_glue_job" "imba-glue-job" {
  name              = "de-ers.imba-glue-ETL-spark"
  role_arn          = aws_iam_role.AWSGlueServiceRole.arn
  worker_type       = "G.1X"
  number_of_workers = "20"
  glue_version      = "3.0"
  # The script "de-ers-imba-glue-ETL-spark.py" has been uploaded to s3 bucket
  command {
    script_location = "s3://${aws_s3_bucket.imba-bucket.bucket}/glue_job_script/de-ers-imba-glue-ETL-spark.py"
  }
}