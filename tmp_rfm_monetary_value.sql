truncate analysis.tmp_rfm_monetary_value ;

insert into analysis.tmp_rfm_monetary_value 
with o as (
	select o.user_id, o.order_ts, o.payment
	from analysis.orders o, analysis.orderstatuses os 
	where os."key" = 'Closed' and o.status = os.id 
		and o.order_ts >= '01.01.2022'::timestamp	
),
uo as (
	select u.id, 
		sum(coalesce(o.payment,0)) as "sum_payment"
	from analysis.users u
	left join o on o.user_id = u.id 
	group by u.id
	),
monetary as
	(select 
		sum_payment,
		ntile(5) OVER( order by t.sum_payment) as "monetary_value"
	from (select sum_payment from uo group by sum_payment) t )
	
SELECT uo.id as "user_id",   
       monetary.monetary_value
from uo
join monetary on monetary.sum_payment = uo.sum_payment
