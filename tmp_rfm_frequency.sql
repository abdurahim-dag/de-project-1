truncate analysis.tmp_rfm_frequency;

insert into analysis.tmp_rfm_frequency 
with o as (
	select o.user_id, o.order_ts
	from analysis.orders o, analysis.orderstatuses os 
	where os."key" = 'Closed' and o.status = os.id 
),
uo as (
	select u.id, 
		count(o.*) as "count_orders"
	from analysis.users u
	left join o on o.user_id = u.id 
	where o.order_ts >= '01.01.2022'::timestamp
	group by u.id
	),
frequency as
	(select 
		count_orders,
		ntile(5) OVER( order by t.count_orders ) as "frequency"
	from (select count_orders from uo group by count_orders) t )

SELECT uo.id as "user_id",   
       frequency.frequency
from uo
join frequency on frequency.count_orders = uo.count_orders
