select sales_date, order_id, product_id, customer_id from sales
intersect
select sales_date, order_id, product_id, customer_id from sales_history

/////Merge into sales_history dest
      using sales src
      on (dest.sales_date = src.sales_date
      and dest.order_id = src.order_id
      and dest.product_id = src.product_id
      and dest.customer_id = src.customer_id)
When matched then 
      update set dest.quantity = src.quantity,
                 dest.unit_price = src.unit_price,
                 dest.sales_amount = src.sales_amount,
                 dest.tax_amount = src.tax_amount,
                 dest.total_amount = src.total_amount
                
when not matched then
      Insert (sales_date, order_id, product_id, customer_id, salesperson_id,
              quantity, unit_price, sales_amount, tax_amount, total_amount
              )
      Values (src.sales_date, src.order_id, src.product_id, src.customer_id,
              src.salesperson_id, src.quantity, src.unit_price, src.sales_amount,
              src.tax_amount, src.total_amount
              )
      
SELECT sp.first_name,
sum(sales_amount) as sales_amount,
ntile(5) over (order by sum(sales_amount) desc) as band
from sales s, salesperson sp
where s.salesperson_id = sp.salesperson_id
GROUP by sp.first_name
order by 3

select sales_month, sales_amount, previous_month,
round(((sales_amount - previous_month) / previous_month) * 100,2) as growth_perc
from
(
select trunc(sales_date, 'mon') as sales_month,
sum(sales_amount) as sales_amount,
lag (sum(sales_amount), 1) over (order by trunc(sales_date, 'mon')) as previous_month,
lead (sum(sales_amount), 1) over (order by trunc(sales_date, 'mon')) as next_month
from SALES s
group by trunc(sales_date, 'mon')
)

create table sales_pivot as
select * from
(
select trunc(sales_date, 'mon') as sales_month, product_id, total_amount from sales
)
pivot ( sum(total_amount) for product_id in (100, 101, 105, 106, 200))
order by sales_month

select region,
listagg(last_name, ',') within group (order by last_name) as customer_names
from customer
group by region

select 
concat (lpad (' ', level*3-3),first_name) as hier_first, level
from salesperson
connect by prior first_name = manager
start with manager is null
order siblings by salesperson.first_name desc

select top_boss, first_name, sum(total_amount) as sales from
(
select salesperson_id, first_name, level, manager,
connect_by_root first_name as top_boss from salesperson
connect by prior first_name = manager
start with manager = 'Raj'
) hier, sales
where hier.salesperson_id = sales.salesperson_id
group by top_boss, first_name
order by 1

select salesperson_id, first_name, level, 
sys_connect_by_path(first_name, '/') as hier
from salesperson
connect by prior first_name = manager
start with manager is null

select level as c_number from dual
connect by level <= 200

select trunc(sales_date, 'mon') as sales_month,
product_name,
grouping_id (trunc(sales_date, 'mon'), product_name) as flag_id,
sum(sales_amount) as sales_amount from sales s, product p
where s.product_id = p.product_id
group by cube (trunc(sales_date, 'mon'), product_name)
order by trunc(sales_date, 'mon'), product_name


select trunc(s.sales_date, 'mon') as sales_month,
        p.product_name,
        c.city,
        sum(sales_amount) as sales_amount
from sales s, product p, customer c
where s.product_id = p.product_id
and s.customer_id = c.customer_id
group by cube((trunc(s.sales_date, 'mon'), p.product_name), c.city)
order by trunc(s.sales_date, 'mon'), p.product_name, c.city
