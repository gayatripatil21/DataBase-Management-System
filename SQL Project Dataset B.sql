##### Create the Database as Supply_chain 
###_______________________________________________________###
#Create database Supply_chain;
use Supply_chain;

##### Create table Customer along with its indexes 
###_______________________________________________________###

create table Customer (
   Id                   int                  ,
   FirstName            varchar(40)         not null,
   LastName             varchar(40)         not null,
   City                 varchar(40)         null,
   Country              varchar(40)         null,
   Phone                varchar(20)         null,
   constraint PK_CUSTOMER primary key (Id)
);
create index IndexCustomerName on Customer (
LastName ASC,
FirstName ASC
);

##### Create table Orders along with its indexes 
###_______________________________________________________###


create table Orders (
   Id                   int                  ,
   OrderDate            varchar(20)             not null, 
   OrderNumber          varchar(10)         null,
   CustomerId           int                  not null,
   TotalAmount          decimal(12,2)        null default 0,
   constraint PK_ORDER primary key (Id)
);
create index IndexOrderCustomerId on Orders (
CustomerId ASC
);
create index IndexOrderOrderDate on Orders (
OrderDate ASC
);

##### Create table OrderItem along with its indexes 
###_______________________________________________________###

create table OrderItem (
   Id                   int                  ,
   OrderId              int                  not null,
   ProductId            int                  not null,
   UnitPrice            decimal(12,2)        not null default 0,
   Quantity             int                  not null default 1,
   constraint PK_ORDERITEM primary key (Id)
);

create index IndexOrderItemOrderId on OrderItem (
OrderId ASC
);

create index IndexOrderItemProductId on OrderItem (
ProductId ASC
);

##### Create table Product along with its indexes 
###_______________________________________________________###

create table Product (
   Id                   int                  ,
   ProductName          varchar(50)         not null,
   SupplierId           int                  not null,
   UnitPrice            decimal(12,2)        null default 0,
   Package              varchar(30)         null,
   IsDiscontinued       bit                  not null default 0,
   constraint PK_PRODUCT primary key (Id)
);
create index IndexProductSupplierId on Product (
SupplierId ASC
);
create index IndexProductName on Product (
ProductName ASC
);

##### Create table Supplier along with its indexes 
###_______________________________________________________###


create table Supplier (
   Id                   int                  ,
   CompanyName          varchar(40)         not null,
   ContactName          varchar(50)         null,
   ContactTitle         varchar(40)         null,
   City                 varchar(40)         null,
   Country              varchar(40)         null,
   Phone                varchar(30)         null,
   Fax                  varchar(30)         null,
   constraint PK_SUPPLIER primary key (Id)
);

create index IndexSupplierName on Supplier (
CompanyName ASC
);

create index IndexSupplierCountry on Supplier (
Country ASC
);

 /*1.	Company sells the product at different discounted 
rates. Refer actual product price in product table and
 selling price in the order item table.
 Write a query to find out total amount saved
 in each order then display the orders from highest to lowest amount saved. */
 select * from product;
 select * from orderitem;
 
 select ProductName, sum(actual_price) actual_rate, sum(discounted_price) with_discount, 
		sum(Quantity) total_quantity, sum(discount) total_discount, sum(total_discount) net_discount
	from 
(
select ProductName, SupplierId, p.UnitPrice actual_price, o.UnitPrice discounted_price, 
	Quantity , p.UnitPrice-o.UnitPrice discount, p.UnitPrice*Quantity - o.UnitPrice*Quantity total_discount
  from product p join orderitem o on p.Id = o.ProductId 
  ) T
  group by ProductName order by  sum(total_discount) desc;
 
 -- 2.	Mr. Kavin want to become a supplier. He got the database of
--  "Richard's Supply" for reference. Help him to pick: 
-- a. List few products that he should choose based on demand.
-- b. Who will be the competitors for him for the products suggested in above questions.

-- a. List few products that he should choose based on demand.
-- Solution-:
select productname,sum(quantity) from product p 
join orderitem  o on p.id=productid group by productname
order by sum(quantity) desc limit 5;

-- We suggest these 5 products to Mr.Kavin sholud go for to commence his businnes.

 -- b. Who will be the competitors for him for the products suggested in above questions.

select * from supplier where id in 
(select supplierid from product p join
(select p.id from product p 
join orderitem o on p.id=productid group by productname
order by sum(quantity)desc limit 5) as t on p.id=t.id) ;

 -- These 4 companies are the compititoors fro Mr.Kavin.
 -- They manfacture the content which is in huge demand.
 
 -- 3.	Create a combined list to display customers and suppliers details considering the following criteria 
-- ●	Both customer and supplier belong to the same country
-- ●	Customer who does not have supplier in their country
-- ●	Supplier who does not have customer in their country
-- Solution-:
create table if not  exists temp
select * from
(
select 
CustomerId, CONCAT(FirstName,' ',LastName) cust_name, T1.City cust_city, 
T1.Country cust_country,  ContactName, CompanyName,  T5.City supp_city, T5.Country supp_country
 from customer T1 join orders T2 on T1.Id = T2.CustomerId
join orderitem T3 on T3.OrderId = T2.Id join product T4 on T3.ProductId = T4.Id
join supplier T5 on T5.Id = T4.SupplierId) R1;

-- a.Both customer and supplier belong to the same country
select * from customer;
select * from supplier;
select  cust_name customer, ContactName supplier, supp_city, supp_country
from temp where cust_name<>ContactName and cust_city=supp_city;


-- b.Customer who does not have supplier in their country

select cust_name, cust_country, ContactName, supp_country
 from temp
where cust_country<>supp_country;

-- c.Supplier who does not have customer in their country
select cust_name, cust_country, ContactName, supp_country
 from temp
where cust_country<>supp_country;


-- 4.	Every supplier supplies specific products to the customers.
-- Create a view of suppliers and total sales made by their products
-- and write a query on this view to find out top 2 suppliers 
-- (using windows function) in each country by total sales done by the products.
create view suppliers as (
 select *,
dense_rank() over(order by COUNRY_TOT_AMNT desc) 'RANK'
FROM
(
select ContactName, ProductName, SUM(total_amount) COUNRY_TOT_AMNT, Country
from
(
select CompanyName, ContactName,  ProductName, SUM(T2.UnitPrice) actual, 
SUM(T3.UnitPrice) discount, SUM(TotalAmount) total_amount, Country
 from supplier T1 join product T2 on T1.Id = T2.SupplierId 
 join orderitem T3 on T3.ProductId = T2.Id join orders T4 on T4.Id = T3.OrderId
 group by ContactName order by SUM(TotalAmount) desc) R1
 group by Country) R2 LIMIT 2);
 
 
-- 5.	Find out for which products, UK is dependent on other countries for the supply. 
-- List the countries which are supplying these products in the same list.
-- Solution-:
select * from  supplier s join product p on s.Id = p.SupplierId;

select ProductName from (
select ProductName, Country from  supplier s join product p on s.Id = p.SupplierId) R1
where ProductName not in (
select ProductName from supplier s join product p on s.Id = p.SupplierId where Country like 'UK') ;

-- UK is dependent on these products, hence these products do not get manufactured in UK

 
-- 6.	Create two tables as ‘customer’ and ‘customer_backup’ as follow - 
-- ‘customer’ table attributes -
-- Id, FirstName,LastName,Phone
-- ‘customer_backup’ table attributes - 
-- customer1Id, FirstName,LastName,Phone

-- Create a trigger in such a way that It should insert the details into the 
--  ‘customer_backup’ table when you delete the record from the ‘customer’ table automatically.
create table customer1(
id int,
firstname varchar(20),
lastname  varchar(20),
Phone varchar(20));

create table customer_backup(
id int,
firstname varchar(20),
lastname  varchar(20),
Phone varchar(20));
insert into customer1 values
 (1,'Manoj','kale','1293832480'),
 (2,'Vinit','Pawar','129385480');
 select * from customer1;
 delimiter |
 create trigger insert_into_trigger_customer
 before delete on customer1
 for each row 
 begin
 insert into customer_backup set id=old.id,
 firstname=old.firstname, lastname=old.lastname,
 phone=old.phone;
 End;
 |
 delimiter ;
 select * from customer1;
 select  * from customer_backup;
 delete from customer1 where id=1; 
 





 

