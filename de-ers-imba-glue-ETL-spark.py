'''
Lang: PySpark
Data Flow: From Glue DB to S3 Glue Output Bucket
'''
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
job.commit()

# Define parameters
from datetime import datetime
now = datetime.now().strftime('%Y-%m-%d-%H:%M:%S')
bucket = 'de-ers.imba-glue-output'
folder = now

db = 'de-ers.imba-gluedb'
aisles_table = 'imba-crawler-output-postgres_public_aisles'
departments_table = 'imba-crawler-output-postgres_public_departments'
orders_table = 'imba-crawler-output-postgres_public_orders'
products_table = 'imba-crawler-output-postgres_public_products'
order_product_table = 'imba-crawler-output-postgres_public_order_product'

aisles_df = glueContext.create_dynamic_frame.from_catalog(database=db, table_name=aisles_table).toDF()
departments_df = glueContext.create_dynamic_frame.from_catalog(database=db, table_name=departments_table).toDF()
orders_df = glueContext.create_dynamic_frame.from_catalog(database=db, table_name=orders_table).toDF()
products_df = glueContext.create_dynamic_frame.from_catalog(database=db, table_name=products_table).toDF()
order_product_df = glueContext.create_dynamic_frame.from_catalog(database=db, table_name=order_product_table).toDF()
orders_df.show()

orders_prior_df = orders_df.filter(orders_df['eval_set']=='prior')
joined_order_product = orders_prior_df.join(order_product_df, 'order_id', 'left')

joined_order_product.createOrReplaceTempView('order_products_prior')
orders_df.createOrReplaceTempView('orders_view')

# create user_features_1
user_features_1 = spark.sql(
    'select user_id, \n'
    'max(order_number) max_order_number, \n'
    'sum(days_since_prior_order) sum_days_since_prior_order, \n'
    'avg(days_since_prior_order) avg_days_since_prior_order \n'
    'from orders_view \n'
    'group by user_id;'
)
# create user_features_2
user_features_2 = spark.sql(
    'select user_id, \n'
    'count(product_id) total_products_by_userid, \n'
    'count(distinct(product_id)) total_distinct_products_by_userid, \n'
    'sum(reordered) / count(case when order_number > 1 then 1 else 0 end) user_reorder_ratio \n'
    'from order_products_prior \n'
    'group by user_id;'
)

# write up_features
up_features = spark.sql(
    'select user_id, product_id, \n'
    'count(order_id) total_orders_by_userprod, \n'
    'min(order_number) min_ordernumber_byuserprod, \n'
    'max(order_number) max_ordernumber_byuserprod, \n'
    'avg(add_to_cart_order) avg_addtocart_byuserprod \n'
    'from order_products_prior \n'
    'group by user_id, product_id;'
)

# create prd_features 
prd_features = spark.sql(
    'with temp as ( \n'
    'select user_id, \n'
    'order_number, \n'
    'product_id, \n'
    'reordered, \n'
    'rank() over(partition by user_id, product_id order by order_number) product_seq_time \n'
     'from order_products_prior \n'
     ') \n'
     'select product_id, \n'
     'count(product_id) total_products_by_productid, \n'
     'sum(reordered) total_reordered, \n'
     'sum(case when product_seq_time = 1 then 1 else 0 end) product_seq_time_1, \n'
     'sum(case when product_seq_time = 2 then 1 else 0 end) product_seq_time_2 \n'
     'from temp \n'
     'group by product_id;')

user_features = user_features_1.join(user_features_2, 'user_id', 'left')
user_up_features = user_features.join(up_features, 'user_id', 'left')
final_features = user_up_features.join(prd_features, 'product_id', 'left')

# creates final_features
final_features.coalesce(1).write.option('header', 'true').mode('overwrite').csv(f's3://{bucket}/{folder}/')
job.commit()