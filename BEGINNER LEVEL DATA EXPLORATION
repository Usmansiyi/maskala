/* BEGINNER LEVEL DATA EXPLORATION */

use sakila;
-- 1. List all films — with title, release year, and rental rate.
select title,
		release_year,
        rental_rate 
from film;

-- 2. Count films by rating (G, PG, etc.)
select rating, 
		count(*) as cnt 
from film
	group by 1;
    
-- 3. Find the 10 most recent films released.
   select title,
		  release_year,
          last_update
from film 
order by 2,3
limit 10;

-- 4. Show all customers with their full names and email addresses.
 select first_name,
		last_name,
        email
 from customer;

-- 5. List all distinct cities where the store operates.
SELECT distinct ct.city_id,
				ct.city
FROM sakila.store as st
join sakila.address ad on st.address_id=ad.address_id
join city ct on ad.city_id=ct.city_id;

-- 6. Find the number of films per category.
SELECT name as category,
	   count(*) as no_films
FROM sakila.film_category as fc
join sakila.category as ct on fc.category_id=ct.category_id
group by 1;

-- 7. Show top 5 actors who appear in the most films.
SELECT a.actor_id,
		a.first_name,
        a.last_name,
        count(*) as appearance
FROM sakila.actor as a 
join sakila.film_actor as fa on a.actor_id=fa.actor_id
group by 1
order by 4 desc
limit 5;

-- 8. Calculate total payments per customer.
SELECT c.customer_id,
		c.first_name,
        c.last_name,
        sum(p.amount) as total_payment
FROM sakila.customer as c
join sakila.payment as p on c.customer_id=p.customer_id
group by 1;

-- 9. List all rentals made by a specific customer (e.g., 'Mary Smith').
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

-- 10. Show how many films are in inventory for each store.
select store_id,count(distinct film_id) as no_films
from sakila.inventory
group by 1 

-- Skills Practice: SELECT, WHERE, GROUP BY, ORDER BY, COUNT, JOIN, DISTINCT.
