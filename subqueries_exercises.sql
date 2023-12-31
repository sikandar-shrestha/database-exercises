
-- Exercise Goals

-- Use subqueries to find information in the employees database

--  Create a file named subqueries_exercises.sql and craft queries to return the results for the following criteria:

-- Q1) Find all the current employees with the same hire date as employee 101010 using a subquery.
use employees;
select database();
show tables;

select hire_date
from employees
where emp_no='101010';


select emp_no, first_name, last_name, hire_date
from employees
join dept_emp
	using(emp_no)
where hire_date =(select hire_date from employees where emp_no=101010) 
		and to_date>now()
;
 



-- Q2) Find all the titles ever held by all current employees with the first name Aamod.

select * 
from employees
where first_name='Aamod';



select distinct title
from titles
where emp_no in
		(
        select emp_no
        from employees
        where first_name='Aamod'
        )
        and to_date>now();

-- Or----------------------------

select distinct t.title
from titles as t
join employees as e
	on t.emp_no=e.emp_no
    and t.to_date>NOW()
where e.first_name in  (select first_name from employees where first_name='Aamod')
	;


-- Q3) How many people in the employees table are no longer working for the company? Give the answer in a comment in your code.

select *
from dept_emp
where to_date<now();


select count(*)
from
(
select de.emp_no
from employees
join dept_emp de
	using(emp_no)
where de.to_date< curdate()
    ) as a;
    
    
    
select count(*) as cnt
from employees
where emp_no not in -- filtering out the current employees
				(
                select emp_no
                from dept_emp
                where to_date >now()
                ) ;-- all my current employees
    
-- A: 




-- Q4) Find all the current department managers that are female. List their names in a comment in your code.




select 

		concat(first_name,' ',last_name) as female_Manager_Name, gender

from employees 
where emp_no in (
			select emp_no
            from dept_manager
            where to_date>curdate()
            )
		and gender='f';
        
        
/* A:'Isamu Legleitner','F'
'Karsten Sigstam','F'
'Leon DasSarma','F'
'Hilary Kambil','F'

*/


	
-- Q5) Find all the employees who currently have a higher salary than the companie's overall, historical average salary.


select avg(salary)
from salaries
;




select count(*)
from salaries 
join employees 
where salary > 
				(
                select avg(salary) as avg_sal -- if you round to 0, 3 people are cut off 
                from salaries
			
                )
		and to_date>curdate() -- dont have duplicate employees since i filtered to current 
                ;
                






-- Q6) How many current salaries are within 1 standard deviation of the current highest salary? 
-- (Hint: you can use a built-in function to calculate the standard deviation.) What percentage of all salaries is this?

-- Hint You will likely use multiple subqueries in a variety of ways
-- Hint It's a good practice to write out all of the small queries that you can. 
--      Add a comment above the query showing the number of rows returned. 
--      You will use this number (or the query that produced it) in other, larger queries.


-- 1st way 

select round((max(salary)-std(salary)),0) 
			from salaries
            where to_date>curdate();
-- A: cutoff salary= 140910

select count(*) as num_within_std
from salaries
where salary>=
			( -- cutoff point ,~140k
            select (max(salary)-std(salary)) 
			from salaries
            where to_date>curdate()
            )
		and to_date>now();
  -- A : 83 
  
  select count(*)
  from salaries
  where to_date>now();

-- 240124

# The % for above the cutoff salary

select 
		(num_within_std*100/total_current_salary) as 'percentage within std (%)'
from 
		(
        select count(*) as num_within_std
		from salaries
		where salary>=
			(
            select (max(salary)-std(salary)) 
			from salaries
            where to_date>curdate()
            )
            and to_date>curdate()
            ) as num_within_std_subquery
            ,
            
            (
            select count(*) as total_current_salary
			from salaries
			where to_date>curdate()
            ) as total_current_salary
            ;



-- 2nd way          83/total *100

select 
		(
			select count(*) as num_within_std
from salaries
where salary>=
			( 
            -- cutoff point ,~140k
            select (max(salary)-std(salary)) 
			from salaries
            where to_date>curdate()
            )
		and to_date>now()
)  -- 83
/
(select count(*)
from salaries
where to_date>now()
)  -- 240124
*100
;




-- ------------------------------- BONUS----------------------------------------------------------------------------

-- BQ1) Find all the department names that currently have female managers.

select 
		d.dept_name
from departments d
join dept_manager dm
	on d.dept_no=dm.dept_no
    and to_date>curdate()
where dm.emp_no in 
					(
                    select emp_no
                    from employees
                    where gender='f'
                    ) 
                    
group by d.dept_name;




-- BQ2) Find the first and last name of the employee with the highest salary.


select first_name, last_name
from employees
where emp_no= (
				select emp_no
                from salaries
                order by salary desc
                limit 1
                )
                ;

-- BQ3) Find the department name that the employee with the highest salary works in.

select d.dept_name,first_name,last_name
from departments d
join dept_emp de
	on d.dept_no=de.dept_no
join 
	(select first_name, last_name,emp_no
		from employees
		where emp_no= (
				select emp_no
                from salaries
                order by salary desc
                limit 1
                )
    ) m
    on de.emp_no=m.emp_no;
    
    -- A : Sales(Tokuyasu Pesch)



-- BQ4) Who is the highest paid employee within each department.

select max(salary),dept_no
from dept_emp
join salaries
	using(emp_no)
group by dept_no;



SELECT
	d.dept_no,
    d.dept_name AS department_name,
    e.first_name,
    e.last_name,
    s.salary
FROM
    departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN employees e ON de.emp_no = e.emp_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE
    s.to_date > NOW()
    AND (de.dept_no, s.salary) IN (
        SELECT de1.dept_no, MAX(s1.salary)
        FROM salaries s1 join dept_emp de1 using (emp_no)
        WHERE s1.to_date > NOW() and de1.to_date>now()
        GROUP BY de1.dept_no
    )
    ;

/* Answer:-
dept_no,department_name,first_name,last_name,salary
'd009','Customer Service','Vidya','Hanabata','144866'
'd008','Research','Ramachenga','Soicher','130211'
'd007','Sales','Tokuyasu','Pesch','158220'
'd006','Quality Management','Shin','Luck','132103'
'd005','Development','Khosrow','Sgarro','144434'
'd004','Production','Youjian','Cronau','138273'
'd003','Human Resources','Yinlin','Flowers','141953'
'd002','Finance','Lunjin','Swick','142395'
'd001','Marketing','Akemi','Warwick','145128'
*/






