# Витрина RFM

## Задача — построить витрину для RFM-классификации:

## 1.1. Требования к целевой витрине.
	Присвойте каждому клиенту три значения — значение фактора Recency, значение фактора Frequency и значение фактора Monetary Value:
	- Фактор Recency измеряется по последнему заказу. Распределите клиентов по шкале от одного до пяти, где значение 1 получат те, кто либо вообще не делал заказов, либо делал их очень давно, а 5 — те, кто заказывал относительно недавно.
	- Фактор Frequency оценивается по количеству заказов. Распределите клиентов по шкале от одного до пяти, где значение 1 получат клиенты с наименьшим количеством заказов, а 5 — с наибольшим.
	- Фактор Monetary Value оценивается по потраченной сумме. Распределите клиентов по шкале от одного до пяти, где значение 1 получат клиенты с наименьшей суммой, а 5 — с наибольшей.

**Необходимые проверки и условия:**
- Проверьте, что количество клиентов в каждом сегменте одинаково. Например, если в базе всего 100 клиентов, то 20 клиентов должны получить значение 1, ещё 20 — значение 2 и т. д.
- Для анализа нужно отобрать только успешно выполненные заказы - заказ со статусом Closed.
- Просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), решаем создать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

**Где хранятся данные:** в схеме production содержатся оперативные таблицы.

**Куда надо сохранить витрину:** витрина должна располагаться в той же базе в схеме analysis.

**Стуктура витрины:** витрина должна называться dm_rfm_segments и состоять из таких полей:
	- user_id
	- recency (число от 1 до 5)
	- frequency (число от 1 до 5)
	- monetary_value (число от 1 до 5)
**Глубина данных:** в витрине нужны данные с начала 2022 года.

**Обновления не нужны.**


## 1.2. Структура исходных данных.

Данные будут браться из схемы production, следующих таблиц и соответствующих столбцов:
- Таблица users. Используемые поля: id(тип int) - идентификатор пользователя.
- Таблица orderstatuses. Используемые поля: id(тип int) - идентификатор статуса заказа, key(тип varchar(255)) - значение ключа статуса.
- Таблица orders. Используемые поля: user_id(тип int) - идентификатор пользоавтеля, order_ts(тип timestamp) - дата и время заказа, payment(numeric(19,5)) - сумма оплаты по заказу.

## 1.3. Качество данных

| Таблицы             | Объект                      | Инструмент      | Для чего используется |
| ------------------- | --------------------------- | --------------- | --------------------- |
| production.users | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.orderstatuses | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о пользователях |
| production.orderstatuses | key varchar(255) NOT NULL | NOT NULL  | Обеспечивает отсутствие пустых значений поля ключа статуса заказа |
| production.orders | id int NOT NULL PRIMARY KEY | Первичный ключ  | Обеспечивает уникальность записей о заказах |
| production.orders | status varchar(255) NOT NULL | NOT NULL  | Обеспечивает отсутствие пустых значений поля ключа статуса заказа |
| production.orders | user_id int NOT NULL | NOT NULL  | Обеспечивает отсутствие пустых значений поля идентификатора пользователя |
| production.orders | order_ts timestamp NOT NULL | NOT NULL  | Обеспечивает отсутствие пустых значений поля даты заказа |

**Таблицы users и orderstatuses.**

Нареканий по качеству данных нет. 

**Таблица orders.**

Нареканий по качеству имеющихся данных нет. Возможные источники появления проблем:
 - отсутствие проверки поля payment на значение больше 0;
 - отсутствие внешнего ключа, для поля  user_id.

## 1.4. Подготовка витрины данных

### 1.4.1. SQL-запросы для создания VIEW для таблиц из схемы production.** в схеме analysis.

```SQL
create or replace view analysis.orderitems 
as select * from production.orderitems;
create or replace view analysis.orderstatuses
as select * from production.orderstatuses;
create or replace view analysis.orderstatuslog
as select * from production.orderstatuslog;
create or replace view analysis.products
as select * from production.products;
create or replace view analysis.users
as select * from production.users;
create or replace view analysis.orders
as select * from production.orders;
```

### 1.4.2. DDL-запрос для создания витрины.

```SQL
create table analysis.dm_rfm_segments (
	user_id int NOT NULL PRIMARY KEY,
    recency int NOT NULL CHECK(recency >= 1 AND recency <= 5)
	frequency int NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
	monetary_value int NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);```

### 1.4.3. SQL запрос для заполнения витрины

```SQL
insert into analysis.dm_rfm_segments 
with o as (
	select o.user_id, o.order_ts, o.payment
	from analysis.orders o, analysis.orderstatuses os 
	where os."key" = 'Closed' and o.status = os.id 
),
uo as (
	select u.id, 
		max(o.order_ts) as "date_last_order",
		count(o.*) as "count_orders",
		coalesce(sum(o.payment),0) as "sum_payment"
	from analysis.users u
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
	from (select sum_payment from uo group by sum_payment) t ),
recency as
	(select 
		date_last_order,
		ntile(5) OVER( ORDER BY t.date_last_order nulls first) as "recency"
	from (select date_last_order from uo group by date_last_order) t )
	
SELECT uo.id as "user_id",   
	recency.recency,
	frequency.frequency,
	monetary.monetary_value
from uo
join frequency on frequency.count_orders = uo.count_orders
join recency on recency.date_last_order = uo.date_last_order
join monetary on monetary.sum_payment = uo.sum_payment
```
