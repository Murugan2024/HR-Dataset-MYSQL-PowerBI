
create database  project;

SELECT * FROM hrdataset;

#ID name changeing
alter table hrdataset
change column ï»¿id emd_id varchar (20) null;

DESCRIBE HRdataset;

select birthdate from hrdataset;  #birthdate month and date mixing in the column
------------------------------------------------------------------------------------------

set sql_safe_updates=0;

UPDATE hrdataset
SET birthdate = CASE
  WHEN birthdate LIKE'%/%'THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
  WHEN birthdate LIKE'%-%'THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
  ELSE NULL
END;
ALTER table hrdataset
modify column birthdate date;
--------------------------------------------------------------------------------------------
UPDATE hrdataset
SET hire_date= CASE
  WHEN hire_date LIKE'%/%'THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
  WHEN hire_date LIKE'%-%'THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
  ELSE NULL
END;
#select hire_date from hrdataset;

ALTER table hrdataset
modify column hire_date date;
DESCRIBE HRdataset;

-----------------------------------------------------------------------------------
SELECT termdate from hrdataset;

SELECT termdate FROM hrdataset 
WHERE termdate IS NOT NULL AND termdate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

UPDATE hrdataset
SET termdate = NULL
WHERE termdate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

UPDATE hrdataset
SET termdate = STR_TO_DATE(termdate, '%Y-%m-%d')
WHERE termdate IS NOT NULL;

ALTER TABLE hrdataset 
MODIFY COLUMN termdate DATE NULL;

DESC hrdataset;
SELECT termdate FROM hrdataset LIMIT 10;

SELECT COUNT(*) AS null_count FROM hrdataset WHERE termdate IS NULL;

UPDATE hrdataset 
SET termdate = '0000-00-00' 
WHERE termdate IS NULL;

SELECT @@GLOBAL.sql_mode;
SET GLOBAL sql_mode = 'NO_ENGINE_SUBSTITUTION';



--------------------------------------------------------------------------------------------------
#age caclulate birthdate and age 

alter table hrdataset add column age int;

update hrdataset 
set age = timestampdiff(year,birthdate,curdate());

select birthdate,age from hrdataset;

select 
min(age) as young,
max(age) as oldest
from hrdataset;  
select count(*) from hrdataset where age <18;
----------------------------------------------------------------------------------------------------------
#my analysis
# 1 what is the gender breakdown of employees in company?
select gender,count(*) as count
from hrdataset
where age >=18 and termdate='0000-00-00'
group by gender;
---------------------------------------------------------------------------------------------------------
#2 what is the race/ethnicity distribution of employees in the company?
select race,count(*) as count
from hrdataset
where age >=18 and termdate ='0000-00-00'
group by race     
order by count(*) desc; #descending
----------------------------------------------------------------------------------------------------------
#3 what is the age distribution of employees on the company?
select 
min(age) as young,
max(age) as oldest
from hrdataset
where age >=18 and termdate ='0000-00-00';

select
  case
    when age >=18 and age <=24 then '18-24'
    when age >=25 and age <=34 then '25-34'
    when age >=35 and age <=44 then '35-44'
    when age >=44 and age <=54 then '44-54'
    when age >=55 and age <=64 then '55-64'
    else '65+'
  end as age_group,gender,
  count(*)as count
from hrdataset
where age >=18 and termdate ='0000-00-00'
group by age_group,gender
order by age_group,gender;
--------------------------------------------------------------------------------------------
 #4 how many employees work at headquarters versus remote locations?
 select location,count(*) as count
 from hrdataset
 where age >=18 and termdate ='0000-00-00'
 group by location;
 desc hrdataset;
 ----------------------------------------------------------------------------------------------
 #5 what is the average length of employees who have been terminated?
select
   round(avg(datediff(termdate,hire_date))/365,0)as avg_length_employment
from hrdataset
where termdate<= curdate() and termdate <>'0000-00-00' and age >=18;
----------------------------------------------------------------------------------------------     
#6 how does the gender distribution vary across departments and job titles?
select department,gender,count(*) as count
from hrdataset
where age >=18 and termdate ='0000-00-00'
group by department,gender
order by department;
-----------------------------------------------------------------------------------------------
#7 what is the distribution of job titles across the company?
select jobtitle,count(*) as count
from hrdataset
where age >=18 and termdate ='0000-00-00'
group by jobtitle
order by jobtitle desc;
----------------------------------------------------------------------------------------------
#8 which department has the highest turnover rate?
select department,
 total_count,
 terminated_count,
 terminated_count/total_count as termination_rate
from (
 select department,count(*) as total_count,
 sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminated_count
 from hrdataset where age>=18
 group by department)as subquery order by termination_rate desc;
------------------------------------------------------------------------------------------------------------ 
#9 what is distribution of employee across locations by city and state?
select location_state,count(*) as count
from hrdataset
where age >=18 and termdate ='0000-00-00'
group by location_state
order by count desc;
------------------------------------------------------------------------------------------------------------
#10 how has the company's employee count changed over time based on hire and term dates?0
select 
  year,
  hires,
  terminations,
  hires-terminations as net_change,
  round((hires - terminations)/hires*100,2)as net_change_percent
 from(
     select 
        year(hire_date) as year,
	    count(*) as hires,
	    sum(case when termdate <> '0000-00-00' and termdate<=curdate()then 1 else 0 end) as terminations
        from hrdataset 
        where age >= 18
        group by year(hire_date)
        ) as subquery
order by year asc;

#11 what is the tenure distribution for each department?
select department,round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hrdataset
where termdate <=curdate() and termdate <>'0000-00-00' and age>=18
group by department;
