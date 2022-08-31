truncate analysis.tmp_rfm_recency;

insert into analysis.tmp_rfm_recency 
with o as (
	select o.user_id, o.order_ts
	from analysis.orders o, analysis.orderstatuses os 
	where os."key" = 'Closed' and o.status = os.id 
),
uo as (
	select u.id, 
		max(o.order_ts) as "date_last_order"
	from analysis.users u
	left join o on o.user_id = u.id 
	where o.order_ts >= '01.01.2022'::timestamp
	group by u.id
	),
recency as
	(select 
		date_last_order,
		ntile(5) OVER( ORDER BY t.date_last_order nulls first) as "recency"
	from (select date_last_order from uo group by date_last_order) t )

SELECT uo.id as "user_id",   
       recency.recency
from uo
join recency on recency.date_last_order = uo.date_last_order
