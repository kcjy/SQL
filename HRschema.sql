select * from employees

select * from departments

select * from jobs

select employee_id, last_name, job_id, manager_id,
        hire_date, level from employees
where level <= 2
connect by prior employee_id = manager_id
start with manager_id is null
order by level

select employee_id, last_name, job_id, manager_id,
      salary, department_id, hire_date, level,
      sys_connect_by_path(last_name, '/') as hier
      from employees
where department_id = 110
connect by prior employee_id = manager_id
start with manager_id is null
order siblings by last_name

select to_date('01-jan-2016','dd-mon-yyyy') -1 + level, level from dual
connect by level <= 31

select emp_name, sum(salary) as total_salary
from
(
select connect_by_root last_name as emp_name, salary
from employees
where department_id = 110
connect by prior employee_id = manager_id
)
group by emp_name


select d.department_name, e.job_id, sum(e.salary) as salary
from departments d, employees e
where d.department_id = e.department_id
group by rollup (d.department_name, e.job_id)
order by d.department_name, e.job_id

select d.department_name, e.job_id, sum(e.salary) as salary
from departments d, employees e
where d.department_id = e.department_id
group by cube (d.department_name, e.job_id)
order by d.department_name, e.job_id

select d.department_name, e.job_id,
grouping_id(d.department_name, e.job_id) as flag_id,
sum(e.salary) as salary
from departments d, employees e
where d.department_id = e.department_id
group by cube (d.department_name, e.job_id)
order by d.department_name, e.job_id