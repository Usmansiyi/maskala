-- ADVANCED LEVEL – Automation & Optimization 

-- Goal: Build advanced database objects to show engineering-level SQL proficiency.

/* 1. Create Views
Create a view vw_customer_revenue summarizing each customer’s total rentals and payments.*/

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


/* 2. Stored Procedure
Create a stored procedure sp_top_customers_by_month(year_input INT, month_input INT)
→ Returns top 10 customers by payment amount for that month.*/

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

/* 3. Function
Create a function fn_total_customer_spending(customer_id INT)
→ Returns the total spending of a given customer.*/

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


/* 4. Trigger (AFTER INSERT)
Create a trigger tr_payment_after_insert that updates a customer’s “loyalty_points” field (add 1 point per $1 spent).*/

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

/* 5. Trigger (BEFORE DELETE)
Log any deleted rentals into a rental_archive table before deletion.

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

/* 6. Event Scheduler
Create an event that runs monthly to archive all rentals older than 3 years.*/
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

/* 7. Complex Query
Using CTEs, calculate revenue growth month-over-month for each store.*/

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

/* 8. Dynamic SQL
Write a procedure that accepts a category_name and dynamically returns the top 5 most rented films in that category.*/

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


/* 9. Optimization
Create an index on rental (rental_date) and compare query performance before/after.*/

select * from sakila.rental
where rental_date = '2005-05-24 23:03:39';
create index idx_rental_date on sakila.rental (rental_date);
select * from sakila.rental
where rental_date = '2005-05-24 23:03:39';
-- query is faster after creating index because its using the index instead of scanning the whole rental table
-- as result the query perfomance improved

/* 10. Analytical Report
Create a stored procedure sp_store_performance_report() that
Calculates revenue, number of rentals, active customers
Outputs results ordered by best-performing store.*/

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
-- Skills practiced: VIEWS, CTEs, TRIGGERS, STORED PROCEDURES, EVENTS, INDEXES, DYNAMIC SQL
