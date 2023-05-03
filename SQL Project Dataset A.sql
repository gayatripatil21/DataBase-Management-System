#create database icc_test_cricket;

# Tasks to be performed:
# 1. Import the csv file to a table in the database.
use icc_test_cricket;
show tables;

# 2. Remove the column 'Player Profile' from the table.
SELECT * FROM icc_test.`icc test batting figures (1)`;
alter table `icc test batting figures (1)`  drop column `Player Profile`;

# 3. Extract the country name and player names from the 
#    given data and store it in separate columns for further usage.
select * from `icc test batting figures (1)`;
 alter table `icc test batting figures (1)`
 add column country varchar(45);
select substr(player,instr(player,"(")+1,(instr(player,")")-instr(player,"("))-1)
 as 'Country' from `icc test batting figures (1)`;

update `icc test batting figures (1)` 
set country=substr(player,instr(player,"(")+1,(instr(player,")")-instr(player,"("))-1);

alter table `icc test batting figures (1)`
add column Name varchar(100);
update `icc test batting figures (1)` set name=left(player,instr(player,'(')-1);

# 4. From the column 'Span' extract the start_year and end_year 
#    and store them in separate columns for further usage.
alter table `icc test batting figures (1)` add column start_year int;
alter table `icc test batting figures (1)` add column end_year int;
select substr(span, 1,4 ) as start_year, 
substr(span, 6, 9) as end_year
from `icc test batting figures (1)`;
update `icc test batting figures (1)` set start_year=substr(span, 1,4 ), end_year=substr(span, 6, 9) ;
select * from `icc test batting figures (1)`;


#5.	The column 'HS' has the highest score scored by the player so 
# far in any given match. The column also has details if the player 
# had completed the match in a NOT OUT status. Extract the data and 
# store the highest runs and the NOT OUT status in different columns.
alter table `icc test batting figures (1)` add highest_rusn int after hs, 
add No_status varchar(20) after NO;

Update `icc test batting figures (1)` set hs = 0 where hs = '-';
select substr(hs, 1, if (locate('*', hs ), locate('*', hs) -1, hs))
highest_runs,
if (locate('*', hs), 'Not out', 'Out') No_status
from `icc test batting figures (1)`;

Update `icc test batting figures (1)` set Highest_runs = substr(hs,1,if(locate('*', hs),
locate ('*', hs) -1, length(hs))),
No_status = if (locate('*', hs), 'NOt out', 'out');

#6.	Using the data given, considering the players who were active in 
#  the year of 2019, create a set of batting order of best 6 players using 
# the selection criteria of those who have a good average score across all 
# matches for India.
update `icc test batting figures (1)` set avg = 0 where avg = ' ';

alter table `icc test batting figures (1)` modify avg decimal (6,2);
select * from `icc test batting figures (1)`;

select name, avg ,row_number() over() as batting_order
from `icc test batting figures (1)`
where end_year = 2019 and country in ('INDIA', 'ICC/INDIA')
order by avg desc
limit 6;

#7.	Using the data given, considering the players who were active in the 
# year of 2019, create a set of batting order of best 6 players using the 
# selection criteria of those who have the highest number of 100s across 
# all matches for India.
update `icc test batting figures (1)` set `100` = 0 where `100` = ' ';


alter table `icc test batting figures (1)`  modify `100` int;

select name, `100` ,(row_number() over ()) as Batting_order
from `icc test batting figures (1)` 
where end_year = '2019' and country in ('INDIA', 'ICC/INDIA')
order by `100` desc
limit 6;

# 8.	Using the data given, considering the players who were active in
# the year of 2019, create a set of batting order of best 6 players using 
#2 selection criteria of your own for India.

select name,`50`, `100` ,(row_number() over ()) as Batting_order
from `icc test batting figures (1)` 
where end_year = '2019' and country in ('INDIA', 'ICC/INDIA') and avg>40 and `50`>1
order by `100` desc
limit 6;

#9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data 
# given, considering the players who were active in the year of 2019, 
# create a set of batting order of best 6 players using the selection 
# criteria of those who have a good average score across all matches for South Africa.
 create view Batting_Order_GoodAvgScorers_SA as
 (
 select name, avg, row_number() over() as Batting_order
from `icc test batting figures (1)`
where end_year = 2019 and country='SA' 
order by avg desc
limit 6);
select * from Batting_Order_GoodAvgScorers_SA;


#10.	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ 
# Using the data given, considering the players who were active in 
#the year of 2019, create a set of batting order of best 6 players
# using the selection criteria of those who have highest number of 
#100s across all matches for South Africa.
create view Batting_Order_HighestCenturyScorers_SA as (
select name,`100`,row_number() over()
 from `icc test batting figures (1)`
where end_year=2019   and country= 'SA'
order by `100` desc
limit 6);
select * from Batting_Order_HighestCenturyScorers_SA;
 
#11.	Using the data given, Give the number of player_played for each country.
select country,count(name)
from `icc test batting figures (1)`
group by country ;


#12.	Using the data given, Give the number of 
#player_played for Asian and Non-Asian continent
select country ,count(name) as player_played_for_Asian  from `icc test batting figures (1)` where country  in ('WI','AUS','Eng','NZ','ZIM','IRE','SA')
 group by country;
select country,count(name) as player_played_for_Nonasian from `icc test batting figures (1)` where country  in ('India','Pak','SL','BDESH','AFG')
 group by country;
 









