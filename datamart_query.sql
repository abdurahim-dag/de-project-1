truncate analysis.dm_rfm_segments;

insert into analysis.dm_rfm_segments(user_id,recency,frequency,monetary_value)
select u.id as "user_id", r.recency, f.frequency, m.monetary_value from 
	analysis.tmp_rfm_frequency f, analysis.tmp_rfm_recency r, analysis.tmp_rfm_monetary_value m, analysis.users u
where u.id = r.user_id and u.id=m.user_id  and u.id=f.user_id 

-- user_id recency frequency monetary_value
-- 0	1	2	3
-- 1	4	2	3
-- 2	2	2	4
-- 3	2	2	3
-- 4	4	2	2
-- 5	5	3	4
-- 6	1	2	4
-- 7	4	2	2
-- 8	1	1	2
-- 9	1	2	2
-- 10	3	3	2