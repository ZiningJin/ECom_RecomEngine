-- 1 --
create view order_products_prior as
    (select a.*, b.product_id, b.add_to_cart_order, b.reordered
    from orders a
    join order_product b on
    a.order_id = b.order_id
    where a.eval_set = 'prior');

-- 2 --
select max(order_number) max_order_number,
       sum(day_since_prior_order) sum_day_since_prior_order,
       avg(day_since_prior_order) avg_day_since_prior_order
from orders
group by user_id;

-- 3 --
select user_id,
       count(product_id) total_products,
       count(distinct(product_id)) distinct_products,
       sum(reordered)::decimal / count(case when order_number > 1 then 1 end) user_reorder_ratio
from order_products_prior
group by user_id;

-- 4 --
select user_id,
       product_id,
       sum(order_number) total_products_groupby_userid_productid,
       min(order_number) min_ordernum_groupby_userid_productid,
       max(order_number) max_ordernum_groupby_userid_productid,
       avg(add_to_cart_order) avg_addtocartorder_groupby_userid_productid
from order_products_prior
group by (user_id, product_id);

-- 5.1 --
with temp as (
    select user_id,
           order_number,
           product_id,
           reordered,
           rank() over(partition by user_id, product_id order by order_number) product_seq_time
    from order_products_prior
)
select count(product_id) total_products,
       sum(reordered) total_reordered,
       sum(case when product_seq_time = 1 then 1 end) product_seq_time_1,
       sum(case when product_seq_time = 2 then 1 end) product_seq_time_2
from temp
group by product_id;
