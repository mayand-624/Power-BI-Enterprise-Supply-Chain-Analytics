create database PROD;

use PROD;

SELECT * FROM prod.`prod+env+inventory+dataset`;

-- Updating the 2 extra prod ids from ssms.
update prod.`prod+env+inventory+dataset`
set `product id` = 7 where `product id` = 21;

update prod.`prod+env+inventory+dataset`
set `product id` = 11 where `product id` = 22;


-------------------------------------------------------

-- Creating a new table in order to perform left join for both the tables.

use prod;

Create table new_table as 
select 
a.`Order Date (DD/MM/YYYY)` as `Order_Date_DD_MM_YYYY`,
a.`Product ID` as `product_id`,
a.availability,
a.demand,
b.`Product Name` as `product_name`,
b.`Unit Price ($)` as `unit_price`
from
prod.`prod+env+inventory+dataset` as a left join prod.products as b
on a.`Product ID` = b.`Product ID`;

SELECT * FROM prod.new_table;