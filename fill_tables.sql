-- fill dim_region
insert into 
	dim_region ("name")
select distinct 
	"Region" -- name of a region
from 
	flat_sales -- original flat table
	
-- fill dim_country
insert into 
	dim_country ("name", region_id)
select distinct 
	fs2."Country", -- name of a country
	dr.id -- id of a region
from 
	flat_sales fs2 -- original flat table
inner join 
	dim_region dr -- dimension region
	on fs2."Region" = dr."name" 
	
-- fill dim_priority
insert into 
	dim_priority ("name")
values 
	('Low'), 
	('Medium'), 
	('High'), 
	('Critical')
	
-- fill dim_item
insert into 
	dim_item ("name", price, cost)
select distinct 
	"Item Type", -- name of an item
	"Unit Price", -- price of an item
	"Unit Cost" -- cost of an item
from 
	flat_sales 

-- fill fact_sales
insert into 
	fact_sales (order_id, item_id, order_date, ship_date, units_sold, total_revenue, total_cost, total_profit, country_id, priority_id, sales_channel)
select 
	fs2."Order ID", -- id of an order
	di.id, -- id of an item
	to_date(fs2."Order Date", 'mm/dd/yyyy'), -- date of an order
	to_date(fs2."Ship Date", 'mm/dd/yyyy'), -- date of a shipping
	fs2."Units Sold", -- number of units sold
	fs2."Total Revenue", -- total revenue
	fs2."Total Cost", -- total_cost
	fs2."Total Profit", -- total profit
	dc.id as country_id, -- id of a country
	dp.id as priority_id, -- id of a priority
	case
		when fs2."Sales Channel" = 'Online' then true
		when fs2."Sales Channel" = 'Offline' then false
	end as sales_channel -- sales channel: true - online, false - offline
from 
	flat_sales fs2
inner join 
	dim_country dc 
	on dc."name" = fs2."Country" 
inner join 
	dim_item di
	on di."name" = fs2."Item Type" 
inner join 
	dim_priority dp
	on left(dp."name", 1) = fs2."Order Priority" 