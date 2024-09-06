-- easy -- 
-- items that cost more than 200
select 
	"name",
	"cost" 
from 
	dim_item 
where
	"cost" > 200

-- total revenue per channels
select 
	sales_channel, sum(total_revenue)
from
	fact_sales
group by
	sales_channel

-- medium --
-- sales channel distribution by country
select 
    dc."name" as country_name, -- name of a country
    sum(case when sales_channel = true then units_sold else 0 end) as online_total_units, -- total units sold online
    sum(case when sales_channel = false then units_sold else 0 end) as offline_total_units -- total units sold offline
from 
	fact_sales f
inner join
	dim_country dc 
	on dc.id = f.country_id 
group by 
	dc."name" 
	
-- delayed orders per country
select 
    c."name" as country_name, -- name of a country
    count(f.order_id) as delayed_orders_count -- number of delayed orders
from 
	fact_sales f
inner join 
	dim_country c 
	on f.country_id = c.id
where 
	f.ship_date - f.order_date > (select -- criteria for a delayed order
									avg(ship_date - order_date)
								  from 
								  	fact_sales) 
group by 
	country_name
order by 
	delayed_orders_count desc
	
-- advanced --
-- top 3 items by total sales in each country
select 
	country_name, -- name of a country
	item_name, -- name of an item
	total_sales, -- total sales 
	rank_within_country
from (
    select 
        dc."name" as country_name,
        di."name" as item_name,
        sum(units_sold) as total_sales,
        rank() over (partition by dc."name" order by sum(units_sold) desc) as rank_within_country
    from 
    	fact_sales fs2
    inner join
    	dim_country dc 
    	on dc.id = fs2.country_id
    inner join 
    	dim_item di 
    	on di.id = fs2.item_id
    group by 
    	dc."name", 
    	di."name"
	) as ranked_sales
where 
	rank_within_country <= 3
order by 
	country_name, 
	rank_within_country
	
-- yearly growth revenue in percentage
with revenue_per_year as (
    select
        date_part('year', order_date) as "year",
        sum(total_revenue) as total_revenue
    from 
    	fact_sales
    group 
    	by "year"
	),
yearly_growth as (
    select
        "year",
        total_revenue,
        lag(total_revenue) over (order by "year") as previous_year_revenue
    from revenue_per_year
	)
select
    year,
    total_revenue,
    previous_year_revenue,
    case
        when previous_year_revenue is null then null
        else round((total_revenue::decimal - previous_year_revenue::decimal) / previous_year_revenue::decimal * 100, 3)
    end as revenue_growth_percentage
from yearly_growth


