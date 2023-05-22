# create s3 bucket: de-ers.imba-glue-output 
resource "aws_s3_bucket" "imba-glue-output" {
  bucket = "de-ers.imba-glue-output"
}

# create s3 bucket: de-ers.sagemaker-output
resource "aws_s3_bucket" "sagemaker-output" {
  bucket = "de-ers.imba-sagemaker-output"
}

# create s3 bucket: de-ers.imba-bucket for Glue ETL job script
resource "aws_s3_bucket" "imba-bucket" {
  bucket = "de-ers.imba-bucket"
}

#upload script to s3
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.imba-bucket.id
  key    = "/glue_job_script/de-ers-imba-glue-ETL-spark.py"
  source = "../glue/de-ers-imba-glue-ETL-spark.py"
}