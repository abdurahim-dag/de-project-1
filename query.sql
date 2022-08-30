with o as (
	select o.*
	from production.orders o, production.orderstatuses os 
	where os."key" = 'Closed' and o.status = os.id 
),
uo as (
	select u.id, 
		max(o.order_ts) as "date_last_order",
		count(o.*) as "count_orders",
		coalesce(sum(o.payment),0) as "sum_payment"
	from production.users u
	left join o on o.user_id = u.id 
	where o.order_ts >= '01.01.2022'::timestamp
	group by u.id
	),
frequency as
	(select 
		count_orders,
		ntile(5) OVER( order by count_orders ) as "frequency"
	from (select count_orders from uo group by count_orders) t ),
monetary as
	(select 
		sum_payment,
		ntile(5) OVER( order by sum_payment) as "monetary_value"
	from (select sum_payment from uo group by sum_payment) t )
	
SELECT uo.id as "user_id",   
	ntile(5) OVER( ORDER BY uo.date_last_order nulls first) as "recency",
	frequency.frequency,
	monetary.monetary_value
from uo
join frequency on frequency.count_orders = uo.count_orders
join monetary on monetary.sum_payment = uo.sum_payment
