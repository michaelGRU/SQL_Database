CREATE DATABASE SCHRUDY
USE SCHRUDY
/*Create all of the look-up tables(no FKs) based on the ERD*/
-----------------------------------------------------
CREATE TABLE tblFARM(
farm_id int PRIMARY KEY IDENTITY(1,1),
farm_name varchar(50) NOT NULL,
farm_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblPRODUCTTYPE(
product_type_id int PRIMARY KEY IDENTITY(1,1),
product_type_name varchar(50) NOT NULL,
product_type_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblORGANIZATION(
organization_id int PRIMARY KEY IDENTITY(1,1),
organization_name varchar(50) NOT NULL,
organization_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblSTATE(
state_id int PRIMARY KEY IDENTITY(1,1),
state_name varchar(50) NOT NULL,
state_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblCUSTOMERTYPE(
customer_type_id int PRIMARY KEY IDENTITY(1,1),
customer_type_name varchar(50) NOT NULL,
customer_type_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblORDERTYPE(
order_type_id int PRIMARY KEY IDENTITY(1,1),
order_type_name varchar(50) NOT NULL,
order_type_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblLIVESTOCKTYPE(
livestock_type_id int PRIMARY KEY IDENTITY(1,1),
livestock_type_name varchar(50) NOT NULL,
livestock_type_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblGENDER(
gender_id int PRIMARY KEY IDENTITY(1,1),
gender_name varchar(50) NOT NULL
)
-----------------------------------------------------
CREATE TABLE tblPOSITION(
position_id int PRIMARY KEY IDENTITY(1,1),
position_name varchar(50) NOT NULL,
position_description varchar(255)
)
-----------------------------------------------------
CREATE TABLE tblEVENTTYPE(
event_type_id int PRIMARY KEY IDENTITY(1,1),
event_type_name varchar(50) NOT NULL,
event_type_description varchar(255)
)
-----------------------------------------------------
CREATE TABLE tblMEASUREMENT(
measurement_id int PRIMARY KEY IDENTITY(1,1),
measurement_name varchar(50) NOT NULL,
measurement_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblIFCOVIDSHOT(
if_covid_shot_id int PRIMARY KEY IDENTITY(1,1),
if_covid_shot_name varchar(20) NOT NULL,
if_covid_shot_description varchar(50) NOT NULL
)
/*Create the tables with FKs*/
-----------------------------------------------------
CREATE TABLE tblCUSTOMER(
customer_id int PRIMARY KEY IDENTITY(1,1),
organization_id int FOREIGN KEY
REFERENCES tblORGANIZATION(organization_id),
state_id int FOREIGN KEY
REFERENCES tblSTATE(state_id),
customer_type_id int FOREIGN KEY
REFERENCES tblCUSTOMERTYPE(customer_type_id),
customer_first_name varchar(50) NOT NULL,
customer_last_name varchar(50) NOT NULL,
customer_description varchar(255) NOT NULL
)
-----------------------------------------------------
CREATE TABLE tblPRODUCT(
product_id int PRIMARY KEY IDENTITY(1,1),
farm_id int FOREIGN KEY
REFERENCES tblFARM(farm_id),
product_type_id int FOREIGN KEY
REFERENCES tblPRODUCTTYPE(product_type_id),
product_name varchar(50) NOT NULL,
product_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblPRICEHISTORY(
price_history_id int PRIMARY KEY IDENTITY(1,1),
product_id int FOREIGN KEY
REFERENCES tblPRODUCT(product_id),
from_date date NOT NULL,
to_date date NOT NULL,
price_amount money NOT NULL
)
-----------------------------------------------------
CREATE TABLE tblEVENT(
event_id int PRIMARY KEY IDENTITY(1,1),
event_type_id int FOREIGN KEY
REFERENCES tblEVENTTYPE(event_type_id),
event_name varchar(50) NOT NULL,
event_description varchar(255) NULL
)
-----------------------------------------------------
CREATE TABLE tblLIVESTOCK(
livestock_id int PRIMARY KEY IDENTITY(1,1),
livestock_type_id int FOREIGN KEY
REFERENCES tblLIVESTOCKTYPE(livestock_type_id),
gender_id int FOREIGN KEY
REFERENCES tblGENDER(gender_id),
livestock_dob date NOT NULL
)
ALTER TABLE tblLIVESTOCK
ADD livestock_name varchar(50) NOT NULL
-----------------------------------------------------
CREATE TABLE tblEMPLOYEE(
employee_id int PRIMARY KEY IDENTITY(1,1),
position_id int FOREIGN KEY
REFERENCES tblPOSITION(position_id),
if_covid_shot_id int FOREIGN KEY
REFERENCES tblIFCOVIDSHOT(if_covid_shot_id),
employee_first_name varchar(50) NOT NULL,
employee_last_name varchar(50) NOT NULL,
hire_date date NOT NULL,
employee_email varchar(255) NOT NULL
)
-----------------------------------------------------
CREATE TABLE tblORDER(
order_id int PRIMARY KEY IDENTITY(1,1),
customer_id int FOREIGN KEY
REFERENCES tblCUSTOMER(customer_id),
order_type_id int FOREIGN KEY
REFERENCES tblORDERTYPE (order_type_id),
product_id int FOREIGN KEY
REFERENCES tblPRODUCT(product_id),
employee_id int FOREIGN KEY
REFERENCES tblEMPLOYEE(employee_id),
order_date date NOT NULL,
order_total_price money NOT NULL
)
-----------------------------------------------------
CREATE TABLE tblEMPLOYEE_EVENT(
employee_event_id int PRIMARY KEY IDENTITY(1,1),
customer_id int FOREIGN KEY
REFERENCES tblCUSTOMER(customer_id),
measurement_id int FOREIGN KEY
REFERENCES tblMEASUREMENT(measurement_id),
event_id int FOREIGN KEY
REFERENCES tblEVENT(event_id),
[date] date NOT NULL,
quantity float NOT NULL
)
-----------------------------------------------------
CREATE TABLE tblEMP_EVENT_PRODUCT(
emp_event_product_id int PRIMARY KEY IDENTITY(1,1),
product_id int FOREIGN KEY
REFERENCES tblPRODUCT(product_id),
employee_event_id int FOREIGN KEY
REFERENCES tblEMPLOYEE_EVENT(employee_event_id)
)
-----------------------------------------------------
CREATE TABLE tblEMP_EVENT_LIVESTOCK(
emp_event_livestock_id int PRIMARY KEY IDENTITY(1,1),
livestock_id int FOREIGN KEY
REFERENCES tblLIVESTOCK(livestock_id),
employee_event_id int FOREIGN KEY
REFERENCES tblEMPLOYEE_EVENT(employee_event_id)
)