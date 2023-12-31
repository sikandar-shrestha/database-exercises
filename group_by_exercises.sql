-- Exercise Goals

-- Use the GROUP BY clause to create more complex queries

-- Q1) Create a new file named group_by_exercises.sql

/*
Q2) In your script, use DISTINCT to find the unique titles in the titles table. 
How many unique titles have there ever been? Answer that in a comment in your SQL file.
*/

USE employees;
select database();
show tables;
describe titles;

select title from titles; -- to understand the data table

select count(distinct title)
from titles;

-- A:7







-- Q3) Write a query to find a list of all unique last names that start and end with 'E' using GROUP BY.

select last_name
from employees
where last_name like 'e%e'
group by last_name;


-- Q4) Write a query to to find all unique combinations of first and last names of all employees whose last names start and end with 'E'.

select first_name,last_name
-- select concat(first_name,' ',last_name)
from employees
where last_name like 'e%e'
group by first_name, last_name;
-- order by last_name,first_name


-- Q5) Write a query to find the unique last names with a 'q' but not 'qu'. Include those names in a comment in your sql code.

select  last_name
from employees
where last_name like '%q%' and last_name not like '%qu%'
group by last_name;

-- Q6) Add a COUNT() to your results for exercise 5 to find the number of employees with the same last name.

select last_name, count(*) as cnt
from employees
where last_name like '%q%' and last_name not like '%qu%'
group by last_name;

-- if you distinct you cant use count() 
-- when you group by we can use aggregation function like count()


/*
Q7) Find all employees with first names 'Irena', 'Vidya', or 'Maya'. 
	Use COUNT(*) and GROUP BY to find the number of employees with those names for each gender.
*/


select first_name,gender, count(*) as cnt
from employees
where first_name in ('Irena','Vidya','Maya')
group by first_name,gender;
-- order by first_name





-- Q8) Using your query that generates a username for all employees, generate a count of employees with each unique username.

select concat(lower(substr(first_name,1,1)),lower(substr(last_name,1,4)),'_',substr(birth_date,6,2),substr(birth_date,3,2)) as username
,count(*) as cnt
from employees
group by username;
-- having cnt>1
-- order by cnt desc



/*
Q9) From your previous query, are there any duplicate usernames? What is the highest number of times a username shows up? 
	Bonus: How many duplicate usernames are there?
*/

select concat(lower(substr(first_name,1,1)),lower(substr(last_name,1,4)),'_',substr(birth_date,6,2),substr(birth_date,3,2)) as username, count(*) as count
from employees
group by username
having count>1
order by count desc;


-- A: 6



-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Bonus: More practice with aggregate functions:
-------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Q10) Determine the historic average salary for each employee. 
When you hear, read, or think "for each" with regard to SQL, you'll probably be grouping by that exact column.
*/

select emp_no,round(avg(salary),1) as average_salary
from salaries
group by emp_no;






/*
Q11) Using the dept_emp table, count how many current employees work in each department. 
The query result should show 9 rows, one for each department and the employee count.
*/

select * from dept_emp;


select dept_no, count(*) as no_of_employees
from dept_emp
where to_date='9999-01-01'
group by dept_no;


-- Q12) Determine how many different salaries each employee has had. This includes both historic and current.

select salary
from salaries;

select emp_no, count(*) as cnt
from salaries
group by emp_no;


-- Q13) Find the maximum salary for each employee.
select emp_no,max(salary) as max_sal
from salaries
group by emp_no;


-- Q14) Find the minimum salary for each employee.

select emp_no,min(salary) as min_sal
from salaries
group by emp_no;


-- Q15) Find the standard deviation of salaries for each employee.

select emp_no,round(std(salary),1) as std_salary
-- stddev() -- can be used
from salaries
group by emp_no;


-- Q16) Find the max salary for each employee where that max salary is greater than $150,000.

select emp_no,max(salary) as max_sal
from salaries
group by emp_no
having max_sal >150000;


-- Q17) Find the average salary for each employee where that average salary is between $80k and $90k.

select emp_no, avg(salary) as average_salary
from salaries
group by emp_no
having average_salary between 80000 and 90000;