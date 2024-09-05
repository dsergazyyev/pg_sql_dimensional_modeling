-- dimension region
create table dim_region (
	id serial primary key, -- id of a region
	"name" varchar(50) -- name of a region
	)
	
-- dimension country 
create table dim_country (
	id serial primary key, -- id of a country
	"name" varchar(50), -- name of a country
	region_id int4 references dim_region(id) -- id of a region
	)
	
-- dimension priority
create table dim_priority (
	id serial primary key, -- id of a priority
	"name" varchar(8) -- name of a priority
	)

-- dimension item
create table dim_item (
	id serial primary key, -- id of an item
	"name" varchar(30), -- name of an item
	price numeric(5,2), -- price of an item
	cost numeric(5,2) -- cost of an item
	)
	
-- fact sales
create table fact_sales (
	order_id int4 primary key, -- id of an order
	item_id int4 references dim_item(id), -- id of an item
	order_date date, -- date of an order
	ship_date date, -- date of a shipping
	units_sold int4, -- number of units sold
	total_revenue int4, -- total revenue
	total_cost int4, -- total cost
	total_profit int4, -- total profit
	country_id int4 references dim_country(id), -- id of a country
	priority_id int4 references dim_priority(id), -- id of a priority
	sales_channel bool -- sales channel: true - online, false - offline
	)