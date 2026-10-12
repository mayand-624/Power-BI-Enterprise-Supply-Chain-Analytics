

create database test_env

use test_env

select * from [dbo].[Products]

select * from [dbo].[Test+Environment+Inventory+Dataset]

------------------------------------------------------------

-- Checking the columns for null values, etc.

select distinct product_id from [dbo].[Test+Environment+Inventory+Dataset]

-----------------------------------------------

-- Performing 'Left Join' on both tables.

select * from [dbo].[Test+Environment+Inventory+Dataset] as a
left join [dbo].[Products] as b
on a.product_id = b.product_id

-- Since the above code outputs the foreign key (product_id) twice, we optimize this code.

select a.[Order_Date_DD_MM_YYYY], a.product_id, a.availability, a.demand, b.product_name, b.unit_price
from [dbo].[Test+Environment+Inventory+Dataset] as a
left join [dbo].[Products] as b
on a.product_id = b.product_id

--------------------------------------------------

-- The above was one method to optimize, however, in case we want to store this inside a new table:

select * into new_table from
(select a.[Order_Date_DD_MM_YYYY], a.product_id, a.availability, a.demand, b.product_name, b.unit_price
from [dbo].[Test+Environment+Inventory+Dataset] as a
left join [dbo].[Products] as b
on a.product_id = b.product_id) x				-- Subquery used.

select * from new_table

-------------------------------------------------

create database PROD

use PROD

select distinct [Order_Date_DD_MM_YYYY] from [dbo].[Prod+Env+Inventory+Dataset]
where [Order_Date_DD_MM_YYYY] is null or [Order_Date_DD_MM_YYYY] = ''				-- To check null values.

select distinct product_id from [dbo].[Prod+Env+Inventory+Dataset]

-- Since there are 2 'Extra' product ids in the production environment (22 vs 20).
-- And, say we are given a pre-requisite/real-life scenario that the 2 extra ids are nothing but mis spellings, that is:
-- Prod_id = 21 -> 7 & 22 -> 11
-- We are told from the systems dept that they will resolve this issue within a week. However, since we have to present the report right now,
-- we will replace these values with their corrected values.

update [dbo].[Prod+Env+Inventory+Dataset]
set product_id = 7 where product_id = 21

update [dbo].[Prod+Env+Inventory+Dataset]
set product_id = 11 where product_id = 22

-- Now generate output in asc order.

select distinct product_id from [dbo].[Prod+Env+Inventory+Dataset] order by product_id


-- Check null values for remaining columns.
select distinct availability from [dbo].[Prod+Env+Inventory+Dataset]
where availability is null or availability = ''

select distinct demand from [dbo].[Prod+Env+Inventory+Dataset]
where demand is null or demand = ''