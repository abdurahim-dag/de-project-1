create or replace view analysis.orders as 
select o.order_id, 
	ol.dttm as "order_ts", 
	o.user_id, o.bonus_payment, o.payment, o."cost", o.bonus_grant,
	ol.status_id as "status" 
from production.orders o
left join production.orderstatuslog ol 
    on ol.order_id = o.order_id and 
    ol.dttm = (select max(ol2.dttm) from production.orderstatuslog ol2 where ol2.order_id = o.order_id)