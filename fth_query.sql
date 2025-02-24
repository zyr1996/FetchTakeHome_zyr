
/*Drop TABLE product;*/

/*since there are missing value in barcode, it is not set as primary key as depicted in the Entity Relationship Model*/
Create Table Product (
	category_1 varchar,
	category_2 varchar,
	category_3 varchar,
	category_4 varchar,
	manufacturer varchar,
	brand varchar,
	barcode bigint
	
);


copy Product from 'C:\Users\zyir1\Fetch Take home challenge\Products_unique.csv' delimiter ',' csv HEADER;

select * from product
limit 10;

select * from product
where barcode is Null
limit 10;

/*count the number of rows(3968) with empty barcode*/
select count(*) as null_barcode
from product
where barcode is Null;

create table Users (
	ID varchar not null,
	CREATED_DATE timestamp,
	BIRTH_DATE timestamp,
	STATE Varchar,
	language Varchar,
	Gender Varchar,
	PRIMARY KEY (ID)
);

copy Users from 'C:\Users\zyir1\Fetch Take home challenge\USER_TAKEHOME.csv' delimiter ',' csv HEADER;

select * from Users
limit 10;

select * from Users
where id is Null
limit 10;


drop table Transactions;


create table Transactions (
	RECEIPT_ID varchar ,
	PURCHASE_DATE date,
	SCAN_DATE timestamp,
	STORE_NAME varchar,
	USER_ID varchar,
	BARCODE bigint,
	FINAL_QUANTITY varchar,
	FINAL_SALE varchar
);


copy Transactions from 'C:\Users\zyir1\Fetch Take home challenge\Transactions_unique.csv' delimiter ',' csv HEADER;

select * from Transactions
where receipt_id = '0326a774-0077-4378-8828-a780057f21f9';

select * from Transactions
where (FINAL_QUANTITY = 'zero') and FINAL_SALE = '0'
limit 10;

select * from Transactions
where (FINAL_SALE = ' ')
limit 10;


/*
replace character zero to number 0 in FINAL_QUANTITY
replace space to Null in FINAL_SALE
*/

update Transactions
SET FINAL_QUANTITY = replace(FINAL_QUANTITY,'zero','0'),
	FINAL_SALE = NULLif (FINAL_SALE, ' ');

select * from Transactions
where (FINAL_QUANTITY = '0')
limit 10;

select FINAL_SALE from Transactions;

select * from Transactions
where (FINAL_SALE is Null)
limit 10;

/*change the data type of FINAL_QUANTITY and FINAL_SALE to numeric*/
Alter table Transactions
Alter column FINAL_QUANTITY TYPE numeric USING (FINAL_QUANTITY::numeric),
Alter column FINAL_SALE TYPE numeric USING (FINAL_SALE::numeric);

select FINAL_QUANTITY, FINAL_SALE from Transactions
limit 10;

/*count the number of Transactions with 0 final quantity and final sale > 0, result 12341*/
select count(*) from Transactions
where (FINAL_QUANTITY = 0) and (FINAL_SALE > 0);

/*count the number of Transactions with final sale = 0, result 480*/
select count(*) from Transactions
where (FINAL_SALE = 0);


/*What are the top 5 brands by receipts scanned among users 21 and over?*/

/*Since there is tie on RECEIPT_COUNT = 4, we return all the brand with RECEIPT_COUNT >= 4*/
select brand, count(RECEIPT_ID) as RECEIPT_COUNT from 
(Select RECEIPT_ID, barcode
from Transactions T join Users U
on U.id = T.user_id
where (CURRENT_TIMESTAMP - make_interval(21)) > birth_date ) as TU
left join Product P 
on TU.barcode = P.barcode
where brand is not null
Group by brand
having count(RECEIPT_ID) >= 4
order by RECEIPT_COUNT DESC
;


/*What are the top 5 brands by sales among users that have had their account for at least six months?*/

select brand, sum(FINAL_SALE) as Total_sale from 
(Select FINAL_SALE, barcode
from Transactions T join Users U
on U.id = T.user_id
where (CURRENT_TIMESTAMP - make_interval(months => 6)) > created_date ) as TU
left join Product P 
on TU.barcode = P.barcode
where brand is not null
Group by brand
order by Total_sale DESC
limit 5
;

/*Who are Fetch’s Power Users?*/
/*Assumption: Power users are defined as users who have spent the most money.*/

SELECT u.id, u.created_date, u.birth_date, u.state, u.gender, COUNT(t.receipt_id) AS transaction_count, SUM(t.FINAL_SALE) as total_spent
FROM Users u
JOIN Transactions t ON u.id = t.user_id
GROUP BY u.id
ORDER BY SUM(t.FINAL_SALE) DESC
LIMIT 10;






