create temp table if not exists test1 (i integer)
tablespace tempspace1;

insert into test1(i) values (1), (2), (4);

create temp table if not exists test2 (s varchar(255))
tablespace tempspace2;

insert into test2(s) values ('a'), ('b'), ('ab');

create table if not exists test3 (name varchar(100));

insert into test3(name) values ('dimka'), ('stepka'), ('romka');