select distinct brand from transaction t where t.standard_cost > 1500;

select * from transaction t where t.order_status = 'Approved' and to_date(t.transaction_date, 'DD.MM.YYYY') between '2017-04-01' and '2017-04-09'

select * from customer c where (c.job_industry_category IN ('IT', 'Financial Services')) and c.job_title like 'Senior%';

select brand 
from transaction t
left join customer c on t.customer_id = c.customer_id
where c.job_industry_category = 'Financial Services';

select distinct c.*
from customer c
left join transaction t on t.customer_id = c.customer_id
where t.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
limit 10;

SELECT c.*
FROM customer c
LEFT JOIN transaction t ON t.customer_id = c.customer_id
WHERE t.customer_id IS NULL;

SELECT DISTINCT c.*
FROM customer c
JOIN transaction t ON t.customer_id = c.customer_id
WHERE c.job_industry_category = 'IT'
	AND t.standard_cost = (
		SELECT MAX(t2.standard_cost)
		FROM transaction t2
	);

SELECT DISTINCT c.*
FROM customer c
INNER JOIN transaction t ON t.customer_id = c.customer_id
	AND t.order_status = 'Approved'
	AND to_date(t.transaction_date, 'DD.MM.YYYY') BETWEEN '2017-07-07' AND '2017-07-17'
WHERE c.job_industry_category IN ('IT', 'Health');
