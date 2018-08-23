create database shop;
use shop;
create table books (id int NOT NULL AUTO_INCREMENT, title VARCHAR(256), price decimal(4,2), creation DATE);
insert into books value ('Gates of Fire', 13.99, CURDATE());
