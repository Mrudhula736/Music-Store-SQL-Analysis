CREATE DATABASE musicstore;
USE musicstore;

-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY,
	name VARCHAR(120)
);

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
  levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);


-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
);

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

INSERT INTO employee
    values 
    (9,'Madan','Mohan','Senior General Manager',NULL,'L7',
    '1961-01-26','2002-01-14',
    '1008 Vrine','Edmonton','AB','Canada','T5K 2N1',
    '+1 (780) 428-9482',
    '+1 (780) 428-3457',
    'madan.mohan@chinookcorp.com');

SELECT * FROM Employee;

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE  track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);

-- Q1: Who is the senior most employee based on the Job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2: Which countries have the most invoices?

SELECT billing_country, COUNT(*) AS c
FROM Invoice
GROUP BY billing_country
ORDER BY c DESC;

-- Q3: What are top three values of invoices?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4: Which city has the best customers? We would like to throw a promotional MusicFestival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name and sum of all invoice totals.
SELECT billing_city, SUM(total) AS invoice_total
FROM Invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

-- Q5: Who is the best customer?
-- The customer  who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money.

SELECT customer.customer_id,
customer.first_name, 
customer.last_name, 
SUM(invoice.total) AS total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1;

-- Q6: Write a query to return the email, first name, last name and Genre of all Rock music listeners.
-- Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT 
    c.email, 
    c.first_name, 
    c.last_name, 
    g.name AS genre
FROM Customer c
JOIN Invoice i 
    ON c.customer_id = i.customer_id
JOIN InvoiceLine il 
    ON i.invoice_id = il.invoice_id
JOIN Track t 
    ON il.track_id = t.track_id
JOIN Genre g 
    ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

-- Q7: Lets invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT 
    a.artist_id, 
    a.name, 
    COUNT(*) AS no_of_songs
FROM Track t
JOIN Album al 
    ON t.album_id = al.album_id
JOIN Artist a 
    ON al.artist_id = a.artist_id
JOIN Genre g 
    ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id
ORDER BY no_of_songs DESC
LIMIT 10;

-- Q8: Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track.
-- Order by the song length with the longest songs listed first.

SELECT 
    name, 
    milliseconds
FROM Track
WHERE milliseconds > (
    SELECT AVG(milliseconds) 
    FROM Track
)
ORDER BY milliseconds DESC;

-- Q9: Find how much amount spent by each customer on artists?
-- Write a query to return customer name, artist name and total spent.

SELECT concat(c.first_name, c.last_name) as full_name, A.name as Artist_name,sum(i.total) as total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoiceline il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON t.album_id = alb.album_id
JOIN artist A ON alb.artist_id = A.artist_id
GROUP BY full_name,Artist_name
ORDER BY Total_spent desc;

SELECT 
    c.first_name,
    c.last_name,
    ar.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent_on_artist
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY c.customer_id, ar.artist_id, c.first_name, c.last_name, ar.name
ORDER BY total_spent_on_artist DESC;
-- Q10: We want to find out the most popular music genre for each country.
-- We determine the most popular genre as the genre with highest amount of purchases.
-- Write a query that returns each country along with the top genre.
-- For countries where the maximum number of purchases is shared return all genres.

WITH popular_genre AS (
    SELECT 
        COUNT(il.quantity) AS purchases,
        c.country,
        g.name AS genre_name,
        g.genre_id,
        ROW_NUMBER() OVER(
            PARTITION BY c.country 
            ORDER BY COUNT(il.quantity) DESC
        ) AS RowNo
    FROM InvoiceLine il
    JOIN Invoice i   ON i.invoice_id = il.invoice_id
    JOIN Customer c  ON c.customer_id = i.customer_id
    JOIN Track t     ON t.track_id = il.track_id
    JOIN Genre g     ON g.genre_id = t.genre_id
    GROUP BY c.country, g.name, g.genre_id
)
SELECT 
    country, 
    genre_name, 
    purchases
FROM popular_genre
WHERE RowNo = 1
ORDER BY country ASC;
 
 -- Q11: Write a query that determines the customer that has spent the most on music for each ciuntry.
 -- Write a query that returns the country along with the top customer and how much they spent.
 -- For countries where the top amount spentis shared, provide all customers who spent this amount
 
 WITH customer_with_country AS(
	SELECT customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
	 ROW_NUMBER() OVER (PARTITION BY billing_country
	 ORDER BY SUM(total) DESC) AS RowNo
	 FROM invoice
	 JOIN customer ON customer.customer_id= invoice.customer_id
	 GROUP BY 1,2,3,4
	 ORDER BY 4 ASC, 5 DESC)
SELECT * FROM customer_with_country WHERE RowNo <= 1;