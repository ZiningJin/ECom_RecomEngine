## DE-ers Resource Naming Rules:

### 1. RDS:

- DB Name: `imba-rdsinstance`

    schema1：`public`

    schema2：`recommendation`


### 2. Glue:

- Glue Database name: `de-ers.imba-gluedb`

- Glue Tables prefix: `imba-crawler-output-` 

- Glue Connection name: `de-ers.imba-glueconnector`

- Glue Crawler name: `de-ers.imba-gluecrawler`

- Glue Job name: `de-ers.imba-glue-ETL-spark`

- S3 bucket for glue output: `de-ers.imba-glue-output`

- CSV output: `now()`

### 3. Lambda Function:

- s3tosagemaker: `de-ers.s3-to-sagemaker`

- API Gateway: `de-ers_API`

### 4. Sagemaker:
- Sagemaker Notebook instance name: `de-ers-imba-modelling`
- lifecycle configuration name: `de-ers-imba-sagemaker-lifecycle-config`
- S3 bucket for Sagemaker output: `de-ers.imba-sagemaker-output`
- JSON output: `recommendations-+now()`

### 5. API Gateway:
- REST API name: `de-ers.imba-API`

	Resource name: `de-ers-imba-resource`

    Deploy API Stage name: `de-ers-imba-stage`


## IAM roles:

-  AWSGlueServiceRole Name: `AWSGlueServiceRole.SYD.DE-ers`

-  SageMaker IAM Role Name: `AWSSagemakerRole.SYD.DE-ers`

-  LambdaFunction S3 to Sagemaker Role Name: `AWSLambdaS3toSagemakerRole.SYD.DE-ers`

-  LambdaFunction API IAM Role Name: `AWSLambdaAPIRole.SYD.DE-ers`
