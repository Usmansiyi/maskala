# Project Title: Sakila SQL Data Analysis & Automation Project

## Project Overview
A full SQL project journey from beginner analytics to advanced automation using the Sakila DVD Rental dataset.

This project explores, analyzes, and automates business insights using the Sakila sample database.
It progresses from simple SQL queries to advanced techniques such as stored procedures, triggers, and event scheduling, simulating real-world data engineering and analytics workflows.

<img width="1278" height="720" alt="sakila" src="https://github.com/user-attachments/assets/4ba305b8-f6a1-4493-b318-5ed7c074d47f" />



## Objectives
  **1. BEGINNER LEVEL DATA EXPLORATION**
1. List all films — with title, release year, and rental rate.
2. Count films by rating (G, PG, etc.).
3. Find the 10 most recent films released.
4. Show all customers with their full names and email addresses.
5. List all distinct cities where the store operates.
6. Find the number of films per category.
7. Show top 5 actors who appear in the most films.
8. Calculate total payments per customer.
9. List all rentals made by a specific customer (e.g., 'Mary Smith').
10. Show how many films are in inventory for each store.
**Skills Practice: SELECT, WHERE, GROUP BY, ORDER BY, COUNT, JOIN, DISTINCT.**

  **2. INTERMEDIATE LEVEL Analysis & Insights**
11. Find top 10 customers by total spending.

12. Identify the top 5 most rented films.
13. Find categories that generate the highest revenue.
14. Find staff members with the most rentals processed.
15. Show average rental duration per film category.
16. Find customers who have never made a payment.
17. Calculate monthly revenue trends.
18. List the top 3 paying customers per country.
19. Identify the customers with overdue rentals.
20. Compare average payment amounts by rating (e.g., PG, R, etc.).

**Skills practiced: INNER JOIN, LEFT JOIN, HAVING, CASE, SUBQUERY, DATE FUNCTIONS, WINDOW FUNCTIONS**

 **3. ADVANCED LEVEL – Automation & Optimization**
 Goal: Build advanced database objects to show engineering-level SQL proficiency.

21. Create Views
    Create a view vw_customer_revenue summarizing each customer’s total rentals and payments.
22. Stored Procedure
    Create a stored procedure sp_top_customers_by_month(year_input INT, month_input INT)
    Returns top 10 customers by payment amount for that month
23. Function
    Create a function fn_total_customer_spending(customer_id INT)
    Returns the total spending of a given customer.
24. Trigger (AFTER INSERT)
    Create a trigger tr_payment_after_insert that updates a customer’s “loyalty_points” field (add 1 point per $1 spent).
25. Trigger (BEFORE DELETE)
    Log any deleted rentals into a rental_archive table before deletion.
26. Event Scheduler
Create an event that runs monthly to archive all rentals older than 3 years.
27. Complex Query
Using CTEs, calculate revenue growth month-over-month for each store.
28. Dynamic SQL
Write a procedure that accepts a category_name and dynamically returns the top 5 most rented films in that category.
29. Optimization
Create an index on rental (rental_date) and compare query performance before/after.
30. Analytical Report
Create a stored procedure sp_store_performance_report() that:
Calculates revenue, number of rentals, active customers
Outputs results ordered by best-performing store.


 
## Project Structure

### 1. BEGINNER LEVEL DATA EXPLORATION
<img width="299" height="168" alt="download" src="https://github.com/user-attachments/assets/d86024d4-d254-48bf-a892-78e85a8b5279" />

- **Database**: uploaded a database named `sakila`.
- **Skills Practice: SELECT, WHERE, GROUP BY, ORDER BY, COUNT, JOIN, DISTINCT.**

```sql
use sakila;
-- 1. List all films — with title, release year, and rental rate.
select title,
		release_year,
        rental_rate 
from film;
```

**2. Count films by rating (G, PG, etc.)**
```sql
select rating, 
		count(*) as cnt 
from film
	group by 1;
```
    
**3. Find the 10 most recent films released.**
```sql
   select title,
		  release_year,
          last_update
from film 
order by 2,3
limit 10;
```
 **4. Show all customers with their full names and email addresses.**
 ```sql
 select first_name,
		last_name,
        email
 from customer;
```
**5. List all distinct cities where the store operates.**
```sql
SELECT distinct ct.city_id,
				ct.city
FROM sakila.store as st
join sakila.address ad on st.address_id=ad.address_id
join city ct on ad.city_id=ct.city_id;
```
**6. Find the number of films per category.**
```sql
SELECT name as category,
	   count(*) as no_films
FROM sakila.film_category as fc
join sakila.category as ct on fc.category_id=ct.category_id
group by 1;
```
 **7. Show top 5 actors who appear in the most films.**
 ```sql
SELECT a.actor_id,
		a.first_name,
        a.last_name,
        count(*) as appearance
FROM sakila.actor as a 
join sakila.film_actor as fa on a.actor_id=fa.actor_id
group by 1
order by 4 desc
limit 5;
```
**8. Calculate total payments per customer.**
```sql
SELECT c.customer_id,
		c.first_name,
        c.last_name,
        sum(p.amount) as total_payment
FROM sakila.customer as c
join sakila.payment as p on c.customer_id=p.customer_id
group by 1;
```
**9. List all rentals made by a specific customer (e.g., 'Mary Smith').**
```sql
SELECT c.customer_id,
		concat(c.first_name,' ',c.last_name)as 'name',
        group_concat(f.title separator ',') as 'list',
		count(*) as no_rentals 
FROM sakila.customer as c
join sakila.rental as r on c.customer_id=r.customer_id
join sakila.inventory as i on r.inventory_id=i.inventory_id
join sakila.film as f on i.film_id=f.film_id
where first_name='Mary' and last_name='Smith'
group by 1;
```
 **10. Show how many films are in inventory for each store.**
```sql
select store_id,count(distinct film_id) as no_films
from sakila.inventory
group by 1;

```

### 2. INTERMEDIATE LEVEL – Analysis & Insights
![advanced-sql-techniques-for-complex-analysis](https://github.com/user-attachments/assets/0b770f6e-c621-41eb-a59a-3e27b5785073)


- **Skills practiced: INNER JOIN, LEFT JOIN, HAVING, CASE, SUBQUERY, DATE FUNCTIONS, WINDOW FUNCTIONS**

**11. Find top 10 customers by total spending.**
```sql
SELECT c.customer_id,
		concat(c.first_name,' ',c.last_name) as fullname,
        sum(p.amount) total_spending
FROM sakila.customer  as c
join sakila.payment p on c.customer_id=p.customer_id
group by 1
order by 3 desc
limit 10;
```
**12. Identify the top 5 most rented films.**
```sql
SELECT * from
(SELECT f.film_id,
	   f.title,
       count(r.rental_id) as no_rented_film,
       dense_rank() over(order by count(r.rental_id) desc) as rnk
FROM sakila.film as f
join sakila.inventory as i on f.film_id=i.film_id
join sakila.rental as r on i.inventory_id=r.inventory_id
group by 1) as t1
where rnk <=5;
```
**13. Find categories that generate the highest revenue.**
```sql
SELECT c.category_id,
		c.name,
        sum(p.amount) as revenue
FROM sakila.category as c
join sakila.film_category as fc on c.category_id=fc.category_id
join sakila.inventory as i on fc.film_id=i.film_id
join sakila.rental as r on i.inventory_id=r.inventory_id
join sakila.payment as p on r.rental_id=p.rental_id
group by 1
order by 3 desc;
```
**14. Find staff members with the most rentals processed.**
```sql
SELECT r.staff_id,
		s.first_name,
        s.last_name,
        count(r.rental_id) as rentals_processed
FROM sakila.rental as r
join sakila.staff s on s.staff_id=r.staff_id
group by 1;
```
**15. Show average rental duration per film category.**
```sql
SELECT c.category_id,
		c.name,
       round(avg( datediff( r.return_date,r.rental_date)),2) as average
        
FROM sakila.category as c
join sakila.film_category as fc on c.category_id=fc.category_id
join sakila.inventory as i on fc.film_id=i.film_id
join sakila.rental as r on i.inventory_id=r.inventory_id
group by 1
order by 3 desc;
```
**16. Find customers who have never made a payment.**
```sql
with tab1 as 
(SELECT p.customer_id,sum(p.amount) as payment
FROM sakila.payment as p
right join sakila.customer c on p.customer_id=c.customer_id
group by 1)
select * from tab1 
where payment=0 or payment is null;
```
**17. Calculate monthly revenue trends.**
```sql
SELECT year(payment_date) as 'year',
		month(payment_date) as 'month',
        sum(amount) as revenue
FROM sakila.payment 
group by 1,2;
```
**18. List the top 3 paying customers per country.**
```sql
with  tab2 as
(SELECT ctr.country_id,
		ctr.country,
        p.customer_id,
        concat(c.first_name,' ',c.last_name) as fullname,
        sum(amount) as payment,
        dense_rank() over(partition by ctr.country_id order by sum(amount) desc) as rnk
FROM sakila.payment as p
join sakila.customer as c on p.customer_id=c.customer_id
join sakila.address as a on c.address_id=a.address_id
join sakila.city as ct on a.city_id=ct.city_id
join sakila.country as ctr on ct.country_id=ctr.country_id
group by 1,3)
select * from tab2
where rnk <= 3;
```
**19. Identify the customers with overdue rentals.**
```sql
SELECT c.customer_id,
		concat(c.first_name,' ',c.last_name) as fullname,
        f.title,
		case when return_date > date_add(rental_date,interval f.rental_duration day)  then 'returned late'
        when return_date is null then 'not return'
        else 'returned ontime'
        end as rent_status,
        case when return_date > date_add(rental_date,interval f.rental_duration day)  
        then datediff(return_date,date_add(rental_date,interval f.rental_duration day))
        when return_date is null then datediff(now(),date_add(rental_date,interval f.rental_duration day) )
        else 0
        end as overdue_days
FROM sakila.rental as r
join sakila.customer as c on r.customer_id
join sakila.inventory as i on r.inventory_id=i.inventory_id
join sakila.film as f on i.film_id=f.film_id
where (r.return_date > date_add(r.rental_date,interval f.rental_duration day)) 
or (r.return_date is null and now()>date_add(r.rental_date,interval f.rental_duration day))
order by 5 desc;
```
**20.  Compare average payment amounts by rating (e.g., PG, R, etc.).**
```sql
SELECT f.rating,
		roun(avg(p.amount),2) as avg_payment
FROM sakila.payment as p 
join sakila.rental as r on p.rental_id=r.rental_id
join sakila.inventory as i on r.inventory_id=i.inventory_id
join sakila.film as f on i.film_id=f.film_id
group by 1
order by 2 desc;
```
### 3. ADVANCED LEVEL – Automation & Optimization
<img width="750" height="394" alt="sql-script" src="https://github.com/user-attachments/assets/7db19bb6-31f8-4e77-958e-f0bc29456c68" />



- **The Goal is to Build advanced database objects to show engineering-level SQL proficiency**





**21. Create Views
Create a view vw_customer_revenue summarizing each customer’s total rentals and payments.**  

```sql
use sakila;
Create or replace view vw_customer_revenue as
(SELECT c.customer_id,
		concat(c.first_name,' ',c.last_name) as fullname,
        round(sum(p.amount),2) as total_payment,
        count(r.rental_id) as total_rentals
FROM sakila.payment as p
join sakila.customer as c 
join sakila.rental as r on p.customer_id=c.customer_id and  r.customer_id=c.customer_id
group by c.customer_id);
select * from vw_customer_revenue;
```

**22. Stored Procedure
Create a stored procedure sp_top_customers_by_month(year_input INT, month_input INT)
Returns top 10 customers by payment amount for that month.**
```sql
DELIMITER $$
drop procedure if exists sp_top_customers_by_month$$
create procedure sp_top_customers_by_month(in year_input INT,in month_input INT)
BEGIN
SELECT * FROM
	(WITH Summary_table AS 
		(SELECT year(payment_date) as 'year',
				month(payment_date) as 'month',
				c.customer_id,
				concat(c.first_name,' ',c.last_name) as fullname,
				sum(amount) as revenue,
				dense_rank() over(partition by year(payment_date),month(payment_date) order by sum(amount) desc) AS RNK
		FROM sakila.payment as p
		join sakila.customer as c  on p.customer_id=c.customer_id 
		group by 1,2,3)
	 SELECT * FROM Summary_table where RNK <= 10)AS ST
where year=year_input and month=month_input;
END$$
DELIMITER ;
call sp_top_customers_by_month(2005, 5);
```
**23. Function
Create a function fn_total_customer_spending(customer_id INT)
Returns the total spending of a given customer.**
```sql
DELIMITER $$
drop function if exists fn_total_customer_spending$$
Create function fn_total_customer_spending(customer_id INT)
returns int
deterministic
begin
declare total_spending int;
		select b into total_spending from
			(SELECT cs.customer_id as c,
				concat(cs.first_name,' ',cs.last_name) ,
				round(sum(p.amount),2) as b
		FROM sakila.payment as p
		join sakila.customer as cs  on p.customer_id=cs.customer_id
		group by 1)tab1
        where c=customer_id;
 return total_spending ;    
end$$
DELIMITER ;
select fn_total_customer_spending(1);
```

**24. Trigger (AFTER INSERT)
Create a trigger tr_payment_after_insert that updates a customer’s “loyalty_points” field (add 1 point per $1 spent).**
```sql
DELIMITER $$
drop trigger if exists tr_payment_after_insert$$
create trigger tr_payment_after_insert
after insert on sakila.payment
for each row
begin
  update sakila.customer
  set sakila.customer.loyalty_point= sakila.customer.loyalty_point + new.amount;
end$$
DELIMITER ;
```
**25. Trigger (BEFORE DELETE)
Log any deleted rentals into a rental_archive table before deletion.**
```sql
-- Had to create another table to save the old records*/

drop table if exists rental_archive;
create table rental_archive like rental;
alter table rental_archive
add column deleted_at DATETIME DEFAULT NOW();

DELIMITER $$
drop trigger if exists save_deleted_rental_records$$
create trigger save_deleted_rental_records
before delete on sakila.rental
for each row
begin
  insert into sakila.rental_archive(rental_id,
									rental_date,
                                    inventory_id,
                                    customer_id,
                                    return_date,
                                    staff_id,
                                    last_update,
                                    deleted_at)
							values(old.rental_id,
									old.rental_date,
                                    old.inventory_id,
                                    old.customer_id,
                                    old.return_date,
                                    old.staff_id,
                                    old.last_update,
                                    now());
end$$
DELIMITER ;
```
**26. Event Scheduler
Create an event that runs monthly to archive all rentals older than 3 years.**
```sql
CREATE TABLE IF NOT EXISTS rental_archive (
    archive_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT,
    rental_date DATETIME,
    inventory_id INT,
    customer_id INT,
    return_date DATETIME,
    staff_id INT,
    last_update TIMESTAMP,
    deleted_at DATETIME DEFAULT NOW(),
    archived_by_event TINYINT DEFAULT 1
);
 DELIMITER $$
 drop event if exists old_rentals$$
 create event old_rentals
 on schedule every 1 month
 starts '2025-10-31 02:55:19'
 do
 begin
 INSERT INTO rental_archive (
        rental_id,
        rental_date,
        inventory_id,
        customer_id,
        return_date,
        staff_id,
        last_update,
        deleted_at,
        archived_by_event
    )
    SELECT
        r.rental_id,
        r.rental_date,
        r.inventory_id,
        r.customer_id,
        r.return_date,
        r.staff_id,
        r.last_update,
        NOW(),
        1
    FROM rental r
    WHERE r.rental_date < NOW() - INTERVAL 3 YEAR;

 
 delete FROM sakila.rental
 where rental_date > now()-interval 3 year;
 end$$
DELIMITER ;
```
**27. Complex Query
Using CTEs, calculate revenue growth month-over-month for each store.**
```sql
with monthly_revenue as 
	(SELECT year(payment_date) as 'year',
		month(payment_date) as 'month',
        s.store_id,
        sum(amount) as revenue
	FROM sakila.payment as p
	join sakila.store as s on p.staff_id=s.manager_staff_id
	group by 1,2,3)
select *,
		coalesce(lag(revenue) over(partition by store_id order by year,month),0) last_revenue,
        concat(
        round(coalesce(((revenue-coalesce(lag(revenue) over(partition by store_id order by year,month),0))
        /coalesce(lag(revenue) over(partition by store_id order by year,month),0))*100,0),0),
        '%')as MoM_revenue
from monthly_revenue;
```
**28. Dynamic SQL
Write a procedure that accepts a category_name and dynamically returns the top 5 most rented films in that category.**
```sql
DELIMITER $$
drop procedure if exists the_top5_mostRented_films_by_category$$
create procedure the_top5_mostRented_films_by_category(in p_category varchar(30))
begin
set @shehu='WITH t1 as 
(SELECT c.name,
	   f.title,
       count(r.rental_id) as no_rented_film,
       dense_rank() over(partition by c.name order by count(r.rental_id) desc) as rnk
FROM sakila.film_category as fc
join sakila.category as c on fc.category_id=c.category_id
join sakila.film as f on fc.film_id=f.film_id
join sakila.inventory as i on fc.film_id=i.film_id
join sakila.rental as r on i.inventory_id=r.inventory_id
group by 1,2)SELECT * from t1 
where rnk <=5 and name= ?;';
prepare tab from @shehu;
set @maskala = p_category;
execute tab using @maskala;
deallocate prepare tab;
end$$
DELIMITER ;
call  the_top5_mostRented_films_by_category('drama');
```

**29. Optimization
Create an index on rental (rental_date) and compare query performance before/after.**
```sql
select * from sakila.rental
where rental_date = '2005-05-24 23:03:39';
create index idx_rental_date on sakila.rental (rental_date);
select * from sakila.rental
where rental_date = '2005-05-24 23:03:39';
-- query is faster after creating index because its using the index instead of scanning the whole rental table
-- as result the query perfomance improved
```
**30. Analytical Report
Create a stored procedure sp_store_performance_report() that Calculates revenue, number of rentals, active customers
Outputs results ordered by best-performing store.**
```sql
DELIMITER $$
drop procedure if exists sp_store_performance_report$$
create procedure sp_store_performance_report()
	begin
    SELECT s.store_id,
        a.address as store_address,
        ct.city as store_city,
        ctr.country as store_country,
        sum(amount) as revenue,
        count(distinct r.rental_id) as no_of_rentals,
        count(distinct p.customer_id) active_customers
	FROM sakila.payment as p
		join sakila.store as s on p.staff_id=s.manager_staff_id
		join sakila.rental as r on p.rental_id=r.rental_id
		join sakila.customer as c on r.customer_id=c.customer_id
		join sakila.address as a on s.address_id=a.address_id
		join sakila.city as ct on a.city_id=ct.city_id
		join sakila.country as ctr on ct.country_id=ctr.country_id
	group by 1
	order by 5;
	end$$
DELIMITER ;
call sp_store_performance_report();
```
## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**:Top 10 Customers by Revenue, Monthly Revenue Growth per Store, Category-wise Film Rental Frequency,
  					Overdue Rentals & Customer Retention and Automated Monthly Archival Event.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion
Overall, the project represents a complete mini–data warehouse lifecycle:
Extract - Analyze - Automate - Optimize - Report

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```
[[git clone https://github.com/<usmansiyi>/sakila-sql-analysis.git
cd sakila-sql-analysis](https://github.com/Usmansiyi/maskala.git)](https://github.com/Usmansiyi/Sakila-SQL-Data-Analysis-Automation-Project.git)
   

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Usman Siyi

This project showcases SQL skills essential for database management and analysis. looking For someone with skills on SQL and data analysis , connect with me through the following channels:

- **Email**: (nuraensiyi@Ggmail.com)
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/UsmanSiyi)

Thank you for your interest in this project!
