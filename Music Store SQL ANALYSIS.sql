use musicstoredb;

/* Senior most employee based on job title*/

select concat(first_name,' ',last_name) as e_name from employee
order by levels desc
limit 1; 


/* Countries with most invoices*/

select billing_country, count(*) as c from invoice
group by billing_country
order by c desc;


/* Top 3 values of total invoice*/

select total from invoice 
order by total desc
limit 3;


/* Which city has the best customer? write a query City with sum of total invoice*/

select billing_city, sum(total) as t from invoice
group by billing_city
order by t desc; 


/* customer who spends the most money*/

select c.customer_id, c.first_name, c.last_name, sum(total) as total from invoice as i
join customer as c on i.customer_id = c. customer_id
group by c.customer_id 
order by total desc
limit 1; 


/*Customers who are listeners of Rock Music*/

select DISTINCT first_name, last_name, email from customer as c 
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on il.invoice_id = i.invoice_id
Where track_id IN (
	select track_id from track as t 
	join genre as g on t.genre_id = g.genre_id 
	where name = 'Rock')
order by email; 


/* Artists who have written the most rock music*/  

select artist.name, count(artist.artist_id) as num_of_songs from artist 
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
group by artist.artist_id
order by num_of_songs desc
limit 10;
 
 
 /*track name that have song length greater than average song length*/
 
select track_id, milliseconds
from track 
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;


/*how much amount spent by each customer on most popular artist*/

with best_selling_artist as(
 select artist.artist_id, artist.name as artist_name, 
 sum(invoice_line.unit_price * invoice_line.quantity) as total_sales from invoice_line
 join track on invoice_line.track_id = track.track_id
 join album on track.album_id = album.album_id
 join artist on artist.artist_id = album.artist_id
 group by 1
 order by 3 desc
 limit 1
 )
 select c.customer_id, c.first_name, c.last_name , bsa.artist_name, 
 sum(invoice_line.unit_price * invoice_line.quantity) as amount_spent from invoice
 join customer as c on invoice.customer_id = c.customer_id
 join invoice_line on invoice_line.invoice_id = invoice.invoice_id
 join track on invoice_line.track_id = track.track_id
 join album on album.album_id = track.album_id
 join best_selling_artist as bsa on bsa.artist_id = album.artist_id
 group by 1,2,3,4
 order by 5 desc;
 

/*most popular music genre for each country*/

with popular_genre as 
(    
     select c.country, Count(il.quantity) as total_purchase, g.name as genre, g.genre_id,
     ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY count(il.quantity) desc) as Row_no
     from customer as c
     join invoice as i on c.customer_id = i.customer_id
     join invoice_line as il on i.invoice_id = il.invoice_id
     join track on il.track_id = track.track_id
     join genre as g on g.genre_id = track.genre_id
     group by c.country, g.name,4 
     order by  c.country, total_purchase desc 
)

select * from popular_genre where Row_no <=1;


/* customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_w_country as 
(   
    select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(i.total) as total_spent, 
    ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY sum(i.total)desc) as row_no 
    from customer as c
	join invoice as i on c.customer_id = i.customer_id
    group by 1,c.first_name, c.last_name, i.billing_country
    order by total_spent desc, 5
    )
    
 select * from customer_w_country where row_no <= 1; 
 
 
