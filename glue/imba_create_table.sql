create table aisles (
   aisle_id BIGINT,
   aisle VARCHAR(100),
   primary key (aisle_id)
);


create table departments (
   department_id BIGINT,
   department VARCHAR(100),
   primary key (department_id)
);

create table products (
   product_id BIGINT,
   product_name VARCHAR(255),
   aisle_id INT,
   department_id INT,
   primary key (product_id)
);

create table orders (
 order_id BIGINT,
 user_id BIGINT,
 eval_set VARCHAR(100),
 order_number BIGINT,
 order_dow BIGINT,
 order_hour_of_day BIGINT,
 days_since_prior_order DOUBLE PRECISION,
 primary key (order_id)
);

create table order_product (
  order_id BIGINT,
  product_id BIGINT,
  add_to_cart_order BIGINT,
  reordered BIGINT
);