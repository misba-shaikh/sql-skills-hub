-->> Question: For each join type, provide the number of rows returned by various types of joins
-->> Join types are 1. Inner 2. Left 3. Right 4. Full 5. Cross
-- Sample data
create table public.join_test_a (id int);
insert into join_test_a (id) 
values (1),(1),(1),(null),(1),(0);

create table public.join_test_b (id int);
insert into join_test_b (id) 
values (1),(1),(1),(null),(0),(null);

-- Answers:
-- Inner Join results in 4 times 1 joining 3 times 1 = 12 +1 = 13 rows
select a.id as a, b.id as b from join_test_a a
join join_test_b b on a.id = b.id;

-- Left Join results in 4 times 1 joining 3 times 1 = 12 +1 rows + 1 Null = 14 rows
select a.id as a, b.id as b from join_test_a a
left join join_test_b b on a.id = b.id;

-- Right Join results in 3 times 1 joining 4 times 1 = 12 +1 rows + 2 Null= 15 rows
select a.id as a, b.id as b from join_test_a a
right join join_test_b b on a.id = b.id;

-- Full Join results in 4 times 1 joining 3 times 1 = 12 +1 rows + 3 Null = 16 rows
select a.id as a, b.id as b from join_test_a a
full join join_test_b b on a.id = b.id;

-- Cross join = 6 x 6 = 36 rows
select a.id as a, b.id as b from join_test_a a
cross join join_test_b b ;
