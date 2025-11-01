/* INTERMEDIATE LEVEL – Analysis & Insights*/

-- 1. Find top 10 customers by total spending.
SELECT c.customer_id,
		concat(c.first_name,' ',c.last_name) as fullname,
        sum(p.amount) total_spending
FROM sakila.customer  as c
join sakila.payment p on c.customer_id=p.customer_id
group by 1
order by 3 desc
limit 10;

-- 2. Identify the top 5 most rented films.
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

-- 3. Find categories that generate the highest revenue.
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

-- 4. Find staff members with the most rentals processed.
SELECT r.staff_id,
		s.first_name,
        s.last_name,
        count(r.rental_id) as rentals_processed
FROM sakila.rental as r
join sakila.staff s on s.staff_id=r.staff_id
group by 1;

-- 5. Show average rental duration per film category.
SELECT c.category_id,
		c.name,
       round(avg( datediff( r.return_date,r.rental_date)),2) as average
        
FROM sakila.category as c
join sakila.film_category as fc on c.category_id=fc.category_id
join sakila.inventory as i on fc.film_id=i.film_id
join sakila.rental as r on i.inventory_id=r.inventory_id
group by 1
order by 3 desc;

-- 6. Find customers who have never made a payment.
with tab1 as 
(SELECT p.customer_id,sum(p.amount) as payment
FROM sakila.payment as p
right join sakila.customer c on p.customer_id=c.customer_id
group by 1)
select * from tab1 
where payment=0 or payment is null;

-- 7. Calculate monthly revenue trends.
SELECT year(payment_date) as 'year',
		month(payment_date) as 'month',
        sum(amount) as revenue
FROM sakila.payment 
group by 1,2;

-- 8. List the top 3 paying customers per country.
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

-- 9. Identify the customers with overdue rentals.
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

-- 10.  Compare average payment amounts by rating (e.g., PG, R, etc.).
SELECT f.rating,
		roun(avg(p.amount),2) as avg_payment
FROM sakila.payment as p 
join sakila.rental as r on p.rental_id=r.rental_id
join sakila.inventory as i on r.inventory_id=i.inventory_id
join sakila.film as f on i.film_id=f.film_id
group by 1
order by 2 desc;

--  Skills practiced: INNER JOIN, LEFT JOIN, HAVING, CASE, SUBQUERY, DATE FUNCTIONS, WINDOW FUNCTIONS (optional) 
