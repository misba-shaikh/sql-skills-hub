-->> Building a Recursive Hierarchy in a PostgreSQL DB
/*
This SQL code performs the following tasks:

1. Creates a temporary table called "tmp_remove_cycles" to store the employee hierarchy without cycles.
2. Uses a recursive CTE (Common Table Expression) called "employee_hierarchy" to generate the employee hierarchy.
   - The initial part of the CTE selects the root employees (those without a manager) and assigns an empty path.
   - The recursive part of the CTE joins the current level of the hierarchy with the next level, appending the current employee to the path.
   - The WHERE clause in the recursive part ensures that cycles are not formed in the hierarchy.
3. Selects the distinct employee ID and manager ID from the "employee_hierarchy" CTE, filtering out duplicate rows.
4. Creates a table called "employee_hierarchy" to store the final hierarchy with additional columns.
5. Inserts data into the "employee_hierarchy" table using another recursive CTE.
   - The initial part of the CTE selects the employees without cycles and assigns a distance of 1 and a path.
   - The recursive part of the CTE joins the current level of the hierarchy with the next level, incrementing the distance and appending the current employee to the path.
   - The WHERE clause in the recursive part ensures that cycles are not formed in the hierarchy.
6. Calculates the maximum distance for each employee using the MAX() window function.
7. Filters out rows with cycle_found = 0 from the "employee_hierarchy" CTE.

Note: The code assumes the existence of a table called "employee" with columns emp_id, mgr_id, and row_id.
*/
DROP TABLE IF EXISTS tmp_remove_cycles;
CREATE TEMPORARY TABLE tmp_remove_cycles AS
WITH RECURSIVE employee_hierarchy AS (
    SELECT t.emp_id, t.mgr_id, ''::text AS path 
    FROM employee t 
    
    UNION ALL
    
    SELECT e.emp_id, e.mgr_id, eh.path || ':' || eh.emp_id || ':' 
    FROM employee_hierarchy eh
    INNER JOIN employee e ON eh.mgr_id = e.emp_id 
    WHERE POSITION(':' || eh.emp_id || ':' IN eh.path) = 0
) 
SELECT DISTINCT emp_id, mgr_id
FROM employee_hierarchy eh
WHERE POSITION(':' || emp_id || ':' IN path) > 0;

CREATE TABLE IF NOT EXISTS employee_hierarchy AS (
    row_id VARCHAR(255),
    emp_id VARCHAR(255),
    mgr_id VARCHAR(255),
    distance INTEGER,
    max_distance INTEGER,
    path VARCHAR(4000)
);
INSERT INTO employee_hierarchy (row_id, emp_id, mgr_id, distance, max_distance,path)
WITH RECURSIVE employee_hierarchy AS (
    SELECT t.row_id, t.emp_id, t.mgr_id, 1 AS distance,
           ':' || t.mgr_id || ':' || t.emp_id || ':' AS path, 0 AS cycle_found
    FROM employee t 
    LEFT JOIN tmp_remove_cycles c ON t.emp_id = c.emp_id AND t.mgr_id = c.mgr_id
    WHERE c.emp_id IS NULL AND t.mgr_id IS NOT NULL
        
    UNION ALL

    SELECT e.row_id || '~' || eh.emp_id || '~' || eh.mgr_id AS row_id, e.emp_id, eh.mgr_id, eh.distance + 1,
           path || e.emp_id || ':' AS path,
           POSITION(':' || e.emp_id || ':' IN path) AS cycle_found
    FROM employee e
    INNER JOIN employee_hierarchy eh ON e.mgr_id = eh.emp_id 
    WHERE eh.cycle_found = 0
) 
SELECT emp_id || '~' || mgr_id || '~' || distance AS row_id, emp_id, mgr_id, distance,
       MAX(distance) OVER (PARTITION BY emp_id ORDER BY emp_id) AS max_distance,path
FROM employee_hierarchy eh
WHERE eh.cycle_found = 0;


