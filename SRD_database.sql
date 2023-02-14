###########################
## Creating the DataBase ##
###########################
CREATE DATABASE IF 
NOT EXISTS `FlyHigh` DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';

USE FlyHigh;									# We will use the FlyHigh database

#DROP DATABASE `FlyHigh`; 						# To delete the database FlyHigh

#########################
## Creating the tables ##
#########################
CREATE TABLE IF NOT EXISTS `customer` (
	`cust_id` INT UNSIGNED AUTO_INCREMENT,
	`acc_email` VARCHAR(256) UNIQUE NOT NULL,
    `id_type` ENUM('Passport','National Identity Card') NOT NULL, 
    `id_number` VARCHAR(20) NOT NULL, 
    `id_expiration` DATE NOT NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `phone_number` VARCHAR(15) NOT NULL,
    `country` VARCHAR(60) NOT NULL,
    `state` VARCHAR(60) NOT NULL,
    `city` VARCHAR(60) NOT NULL,
    `address` VARCHAR(100) NOT NULL,
    `postal_code` VARCHAR(10) NOT NULL,   #zip code is a type of postal code
    `birth_date` DATE NOT NULL,
    `gender` ENUM('Male','Female','Other') NOT NULL,
    PRIMARY KEY (`cust_id`)
);
CREATE TABLE IF NOT EXISTS `check_in` (
	`check_in_id` INT UNSIGNED AUTO_INCREMENT,
    `flight_id` MEDIUMINT UNSIGNED NOT NULL,
    `cust_id` INT UNSIGNED NOT NULL,
    `checked_in` BINARY NOT NULL DEFAULT 0,
    PRIMARY KEY (`check_in_id`)
);
CREATE TABLE IF NOT EXISTS `boarding` (
	`boarding_id` INT UNSIGNED AUTO_INCREMENT,
    `check_in_id` INT UNSIGNED NOT NULL,
    `boarded` BINARY NOT NULL DEFAULT 0,
    PRIMARY KEY (`boarding_id`)
);
CREATE TABLE IF NOT EXISTS `order` (
	`order_id` INT UNSIGNED AUTO_INCREMENT,
    `cust_id` INT UNSIGNED NOT NULL,
    `date_time` DATETIME NOT NULL,
    `discount_id` SMALLINT UNSIGNED DEFAULT NULL,  
    PRIMARY KEY (`order_id`)
);
CREATE TABLE IF NOT EXISTS `order_item` (
	`order_item_id` INT UNSIGNED AUTO_INCREMENT,
	`order_id` INT UNSIGNED NOT NULL,
    `flight_id` MEDIUMINT UNSIGNED NOT NULL,
    `seat_code` TINYINT NOT NULL,
    PRIMARY KEY (`order_item_id`)
);
CREATE TABLE IF NOT EXISTS `discount` (
	`discount_id` SMALLINT UNSIGNED AUTO_INCREMENT,
    `code` VARCHAR(10) NOT NULL,
    `rate` DECIMAL(2,2) NOT NULL,
    `start_time` DATETIME NOT NULL,
    `end_time` DATETIME NOT NULL,
    PRIMARY KEY (`discount_id`)
);
CREATE TABLE IF NOT EXISTS `payment` (
	`payment_id` INT UNSIGNED AUTO_INCREMENT,
    `order_id` INT UNSIGNED UNIQUE NOT NULL,
    `total_price` DECIMAL(10,2) NOT NULL,              #this price does not take into account tax and discount rate - the calculation is made below on the invoice
    `tax_rate` DECIMAL(2,2) NOT NULL,
    `type` ENUM('Paypal','Credit Card') NOT NULL,
    `paypal_email` VARCHAR(256) DEFAULT NULL,
    `card_number` BIGINT UNSIGNED DEFAULT NULL,
    `card_name` VARCHAR(30) DEFAULT NULL,
    `card_cvv` SMALLINT UNSIGNED DEFAULT NULL,
    `card_expiration` DATE DEFAULT NULL,
    `status` BINARY DEFAULT 0,
    PRIMARY KEY (`payment_id`)
);
CREATE TABLE IF NOT EXISTS `rating` (
	`rating_id` INT UNSIGNED AUTO_INCREMENT,
    `rating_number` TINYINT UNSIGNED NOT NULL,
    `rating_comment` TEXT DEFAULT NULL,
    `flight_id` MEDIUMINT UNSIGNED NOT NULL,
    `cust_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`rating_id`)
);
CREATE TABLE IF NOT EXISTS `flight` (
	`flight_id` MEDIUMINT UNSIGNED AUTO_INCREMENT,
	`flight_number` VARCHAR(6) UNIQUE NOT NULL,
    `aircraft_id` SMALLINT UNSIGNED NOT NULL,
    `route_id` SMALLINT UNSIGNED NOT NULL,
    `pilot_id` SMALLINT UNSIGNED NOT NULL,
    `predicted_departure_time` DATETIME NOT NULL,
    `predicted_arrival_time` DATETIME NOT NULL,
    `departure_time` DATETIME,
    `arrival_time` DATETIME,
    `air_time` TIME NOT NULL,
	`price` DECIMAL(7,2) UNSIGNED NOT NULL,
    `tickets_sold_rate` DECIMAL(2,2) UNSIGNED NOT NULL,
    PRIMARY KEY (`flight_id`)
);
CREATE TABLE IF NOT EXISTS `aircraft` (
	`aircraft_id` SMALLINT UNSIGNED AUTO_INCREMENT,
    `aircraft_registration` VARCHAR(20) UNIQUE NOT NULL,
    `total_flight_time` TIME NOT NULL,
    `capacity` SMALLINT UNSIGNED NOT NULL,
    `model` VARCHAR(20) NOT NULL,
    `manufacturer` VARCHAR(20) NOT NULL,
    `date_manufacture` DATE NOT NULL,
    PRIMARY KEY (`aircraft_id`)
);
CREATE TABLE IF NOT EXISTS `airport` (
	`airport_id` SMALLINT UNSIGNED AUTO_INCREMENT,
    `airport_code` CHAR(3) UNIQUE NOT NULL,
    `city` VARCHAR(60) NOT NULL,
    `country` VARCHAR(60) NOT NULL,
    `airport_name` VARCHAR(60) UNIQUE NOT NULL,
    PRIMARY KEY (`airport_id`)
);
CREATE TABLE IF NOT EXISTS `route` (
	`route_id` SMALLINT UNSIGNED AUTO_INCREMENT,
	`origin_id` SMALLINT UNSIGNED NOT NULL,
    `destination_id` SMALLINT UNSIGNED NOT NULL,
    `distance` SMALLINT UNSIGNED NOT NULL,
	PRIMARY KEY (`route_id`)
);
 CREATE TABLE IF NOT EXISTS `pilot` (
	`pilot_id` SMALLINT UNSIGNED AUTO_INCREMENT,
    `full_name` VARCHAR(100) NOT NULL,
    `birth_date` DATE NOT NULL,
    `gender` ENUM('Male','Female','Other') NOT NULL,
    PRIMARY KEY (`pilot_id`)
);
CREATE TABLE IF NOT EXISTS `aircraft_log` (
	`log_id` TINYINT UNSIGNED AUTO_INCREMENT,
    `user` VARCHAR(100) NOT NULL,
    `aircraft_id` SMALLINT UNSIGNED NOT NULL,
    `datetime_change` DATETIME NOT NULL,
	`description` TEXT,
    `old_aircraft_registration` VARCHAR(20) UNIQUE NOT NULL,
    `old_total_flight_time` TIME NOT NULL,
    `old_capacity` SMALLINT UNSIGNED NOT NULL,
    `old_model` VARCHAR(20) NOT NULL,
    `old_manufacturer` VARCHAR(20) NOT NULL,
    `old_date_manufacture` DATE NOT NULL,
    `new_aircraft_registration` VARCHAR(20) UNIQUE NOT NULL,
    `new_total_flight_time` TIME NOT NULL,
    `new_capacity` SMALLINT UNSIGNED NOT NULL,
    `new_model` VARCHAR(20) NOT NULL,
    `new_manufacturer` VARCHAR(20) NOT NULL,
    `new_date_manufacture` DATE NOT NULL,
    PRIMARY KEY (`log_id`)
);

##############################
## Defining FK's and checks ##
##############################

ALTER TABLE `check_in`
ADD CONSTRAINT `fk_check_in_1`
	FOREIGN KEY (`flight_id`) 
    REFERENCES `flight`(`flight_id`)
    ON DELETE RESTRICT       			# we can´t delete a flight that has a check in information associated to it
    ON UPDATE CASCADE,					# if we update the flight, we also have to update it in the check-in table
ADD CONSTRAINT `fk_check_in_2`
	FOREIGN KEY (`cust_id`)
    REFERENCES `customer` (`cust_id`)
ON DELETE RESTRICT       				# we can´t delete a customer that has a check in information associated to it
    ON UPDATE CASCADE;					# if we update the customer, we also have to update it in the check-in table
    
ALTER TABLE `boarding`
ADD CONSTRAINT `fk_boarding_1`
	FOREIGN KEY(`check_in_id`)
    REFERENCES `check_in` (`check_in_id`)
    ON DELETE RESTRICT					# we can´t delete a check_in that has a boarding information associated to it
    ON UPDATE CASCADE;					# if we update the check_in, we also have to update it in the boarding table

ALTER TABLE `order`
ADD CONSTRAINT `fk_order_1`
	FOREIGN KEY (`cust_id`)
    REFERENCES `customer` (`cust_id`)
	ON DELETE RESTRICT 					# we can´t delete a customer that has a order associated to it
	ON UPDATE CASCADE,					# if we update a customer information, we also have to update it in the order table
ADD CONSTRAINT `fk_order_2`
	FOREIGN KEY (`discount_id`)
	REFERENCES `discount` (`discount_id`)
	ON DELETE SET NULL   				# if we delete a discount, we put the discount_id to null in the order table
    ON UPDATE CASCADE;  				# if we update a discount information, we also have to update it in the order table

ALTER TABLE `order_item`
ADD CONSTRAINT `fk_order_item_1`
	FOREIGN KEY (`order_id`)
    REFERENCES `order` (`order_id`)
    ON DELETE CASCADE					# if we delete a ORDER, we also have to delete it in the ORDER_ITEM table
    ON UPDATE CASCADE,					# if we update a ORDER information, we also have to update it in the ORDER_ITEM table
ADD CONSTRAINT `fk_order_item_2`
	FOREIGN KEY (`flight_id`)
    REFERENCES `flight` (`flight_id`)
    ON DELETE RESTRICT					# we can´t delete a FLIGHT that has a ORDER_ITEM associated to it
    ON UPDATE CASCADE;					# if we update a FLIGHT information, we also have to update it in the ORDER_ITEM table
    
ALTER TABLE `discount`
ADD CONSTRAINT `check_discount_1`
	CHECK(start_time<end_time),			# start_time needs to be less than the end_time
ADD CONSTRAINT `check_discount_2`
	CHECK(rate<1);				        # rate needs to be less than 1
    
ALTER TABLE `payment`
ADD CONSTRAINT `fk_payment_1`
	FOREIGN KEY (`order_id`)
    REFERENCES `order` (`order_id`)
    ON DELETE CASCADE					# if we delete a ORDER, we also have to delete it in the PAYMENT table 
    ON UPDATE CASCADE,					# if we update a ORDER, we also have to update it in the PAYMENT table  
ADD CONSTRAINT `check_payment_1`
	CHECK(total_price > 0),				# the total_price needs to be positive
ADD CONSTRAINT `check_payment_2`
	CHECK(tax_rate<1);					# tax_rate needs to be less than 1

ALTER TABLE `rating`
ADD CONSTRAINT `fk_rating_1`
	FOREIGN KEY(`flight_id`)
    REFERENCES `flight` (`flight_id`)
    ON DELETE CASCADE					# if we update the flight, we also have to update it in the rating table
    ON UPDATE CASCADE,					# if we update the flight, we also have to update it in the rating table
ADD CONSTRAINT `fk_rating_2`
	FOREIGN KEY(`cust_id`)
    REFERENCES `customer` (`cust_id`)
    ON DELETE CASCADE					# if we update the customer, we also have to update it in the rating table
    ON UPDATE CASCADE,					# if we update the customer, we also have to update it in the rating table
ADD CONSTRAINT `check_rating_1`
	CHECK(0<rating_number<=5);			# rating needs to be between 1 and 5
    
ALTER TABLE `flight`
ADD CONSTRAINT `fk_flight_1`
	FOREIGN KEY (`aircraft_id`)
    REFERENCES `aircraft` (`aircraft_id`)
    ON DELETE RESTRICT					# we can´t delete an AIRCRAFT that has a FLIGHT associated to it 
    ON UPDATE CASCADE,					# if we update an AIRCRAFT, we also have to update it in the FLIGHT table
ADD CONSTRAINT `fk_flight_2`
	FOREIGN KEY (`route_id`)
    REFERENCES `route` (`route_id`)
    ON DELETE RESTRICT 					# we can´t delete a ROUTE that has a FLIGHT associated to it
    ON UPDATE CASCADE,					# if we update a ROUTE, we also have to update it in the FLIGHT table
ADD CONSTRAINT `fk_flight_3`
	FOREIGN KEY (`pilot_id`)
    REFERENCES `pilot` (`pilot_id`)
    ON DELETE RESTRICT 					# we can´t delete a PILOT that has a FLIGHT associated to it
    ON UPDATE CASCADE,					# if we update a PILOT, we also have to update it in the FLIGHT table
ADD CONSTRAINT `check_flight_1`
	CHECK(`tickets_sold_rate`<=1);		# tickets_sold_rate needs to be less or equal to 1
    
ALTER TABLE `aircraft`
ADD CONSTRAINT `check_aircraft_1`
	CHECK(capacity > 0);				# the capacity needs to be positive
    
ALTER TABLE `route`
ADD CONSTRAINT `fk_route_1`
	FOREIGN KEY (`origin_id`)
    REFERENCES `airport` (`airport_id`)
	ON DELETE RESTRICT					# we can´t delete an airport ORIGIN that has a ROUTE associated to it
    ON UPDATE CASCADE,					# if we update an airport ORINGIN, we also have to update it in the ROUTE table
ADD CONSTRAINT `fk_route_2`
	FOREIGN KEY (`destination_id`)
    REFERENCES `airport` (`airport_id`)
	ON DELETE RESTRICT					# we can´t delete an airport DESTINATION that has a ROUTE associated to it
    ON UPDATE CASCADE,					# if we update the airport DESTINATION, we also have to update it in the ROUTE table
ADD CONSTRAINT `check_route_1`
	CHECK(distance > 0);				# the distance needs to be positive


##########################################
## Inserting data into FlyHigh database ##
##########################################

INSERT INTO pilot (pilot_id, full_name, birth_date, gender)
VALUES (1, 'Rodrigo Brigham', '1990-07-15', 'Male'),
(2,'Miguel Cruz','1983-10-27','Male'),
(3,'Ana Viseu','1987-06-13','Female'),
(4,'Ana Sal','1991-02-12','Female'),
(5,'Sara Galguinho','1997-11-1','Female');

INSERT INTO aircraft (aircraft_id,capacity,model,manufacturer,date_manufacture,total_flight_time,aircraft_registration)
VALUES (1,9,'CJ3','Cessna','2004-11-04','300:00:00','fly_high_1'),
(2,10,'Falcon 2000','Dassault Aviation','1994-07-01','410','fly_high_2'),
(3,8,'Phenom 100','Embraer','2007-05-03','120:00:00','fly_high_3'),
(4,11,'King Air 350i','Beechcraft','2005-08-07','310:00:00','fly_high_4'),
(5,10,'900XP','Hawker','2005-06-05','122:00:00','fly_high_5'),
(6,14,'Challenger 300','Bombardier','2006-05-01','411:00:00','fly_high_6'),
(7,12,'G150','Gulfstream','2003-07-04','260:00:00','fly_high_7');

INSERT INTO airport (airport_id,airport_code,airport_name,city,country)
VALUES (1,'NRT','Narita International Airport','Japan','Tokyo'),
(2,'LGW','London Gatwick Airport','United Kingdom','London'),
(3,'DEL','Indira Gandhi International Airport','India','Delhi'),
(4,'CAI','Cairo International Airport','Egypt','Cairo'),
(5,'JNB','OR Tambo International Airport','South Africa','Johannesburg'),
(6,'SYD','Sydney Airport','Australia','Sydney'),
(7,'DXB','Dubai International Airport','UAE','Dubai'),
(8,'LAX','Los Angeles International Airport','USA','Los Angeles'),
(9,'MAD','Adolfo Suarez Madrid-Barajas Airport','Spain','Madrid'),
(10,'GRU','Sao Paulo - Guarulhos International Airport','Brazil','Sao Paulo'),
(11,'ORY','Paris Orly Airport','France','Paris'),
(12,'PVG','Shanghai Pudong International Airport','China','Shanghai'),
(13,'YYZ','Toronto Pearson International Airport','Canada','Toronto'),
(14,'EZE','Ministro PiInternational Airportstarini','Argentina','Buenos Aires'),
(15,'LIS','Lisbon Portela Airport','Portugal','Lisbon'),
(16,'AMS','Amsterdam Schipol Airport','Netherlands','Amsterdam'),
(17,'BKK','Suvarnabhumi Airport','Thailand','Bangkok'),
(18,'SVO','Sheremetyevo International Airport','Russia','Moskow');

INSERT INTO customer(cust_id,acc_email,id_type,id_number,id_expiration,full_name,phone_number,country,state,city,address,postal_code,birth_date,gender)
VALUES (1,'Aladdin.Ababa@gmail.com','National Identity Card','801066817','2027-05-03', 'Aladdin Ababa' ,'519-934-6890','Nigeria','Lagos','Ikeja', '12 Lanre Awolokun Street','100001','1978-06-04','Male'),
(2,'Nemo.Silva@gmail.com','Passport','US9567892','2024-05-21','Nemo Silva' ,'845-398-7164','USA','Washington','Tacoma','1114 E. Locust Street','98402','1988-07-05','Male'),
(3,'Woody.Pride@gmail.com','National Identity Card','187077753','2026-03-01','Woody Pride' ,'815-251-0054','France','Paris','Paris','34 Quai de Grenelle','75015','1966-06-27','Male'),
(4,'Olaf.Brigham@gmail.com','National Identity Card','125777289','2024-04-16','Olaf Brigham','605-802-7162','Japan','Tokyo','Minato-Ku','3-2-15 Nishiazabu','106-0031','1962-08-20','Male'),
(5,'Dunga.Cruz@gmail.com','National Identity Card','140266851','2025-01-09','Dunga Cruz','518-527-1703','Malaysia','Penang','George Town','54-74 Elgin Street','10300','1969-08-25','Male'),
(6,'Shrek.Galguinho@gmail.com','National Identity Card','873203196','2023-01-29','Shrek Galguinho','727-398-9132','UK','London','London','20-22 Wenlock Road','N1 7GU','1983-05-11','Male'),
(7,'Gaston.LeGume@gmail.com','National Identity Card','919240379','2022-06-08','Gaston LeGume','618-847-1366','Canada','Quebec','Trois-Riviéres','801 Avenue de Grand-Mère','G8Z 2W2','1991-11-05','Male'),
(8,'Hércules.Ferreira@gmail.com','National Identity Card','792506153','2025-05-04','Hércules Ferreira','250-735-7837','France','Paris','Paris','123 Rue de la Paix','75002','1973-07-05','Male'),
(9,'Bambi.Agostinho@gmail.com','National Identity Card','977159927','2023-11-30','Bambi Agostinho' ,'937-939-9231','USA','Texas','El Paso','1205 E. Montana Avenue','79925','1980-06-09','Male'),
(10,'Peter.Pan@gmail.com','Passport','FR3420581','2023-01-03','Peter Pan' ,'850-876-1866','France','Saint-Tropez','Saint-Tropez','3/2 Avenue de LEglise','83990','1972-10-20','Male'),
(11,'Winnie.Pooh@gmail.com','National Identity Card','228120048','2023-07-01','Winnie Pooh','517-362-7273','USA','Ney Jersey','Newark','98-26 N. Market Street','7102','1986-11-02','Male'),
(12,'Simba.Sousa@gmail.com','National Identity Card','525090966','2025-12-26','Simba Sousa','815-829-2068','Brazil','São Paulo','São Paulo','2458 Cidade de São Paulo','01310-000','1980-04-25','Male'),
(13,'Mufasa.Pereira@gmail.com','National Identity Card','746049640','2026-07-31','Mufasa Pereira ','801-419-3103','Saudi Arabia','Riyadh','Riyadh','5/15 K. Street','11495','1987-01-05','Male'),
(14,'Pumba.Felício@gmail.com','Passport','JP7845312','2022-03-04','Pumba Felício' ,'602-551-7142','Japan','Tokyo','Minato-Ku','1-14-5 Roppongi','106-0031','1982-04-19','Male'),
(15,'Remy.Ratatouille@gmail.com','National Identity Card','394939775','2022-11-21','Remy Ratatouille' ,'385-360-8102','Senegal','Dakar','Dakar','2254 Rue des Nations Unies','20116','1981-09-26','Male'),
(16,'Mike.Wazowski@gmail.com','National Identity Card','966775352','2026-06-09','Mike Wazoswki','765-468-4319','Thailand','Bangkok','Lumpini','1349 Langsuan Road','10330','1994-05-08','Male'),
(17,'Bela.Alves@gmail.com','National Identity Card','454880155','2024-08-26','Bela Alves','763-619-0044','Russia','Moskow','Moskow','25-1 K Street','125009','1957-11-16','Female'),
(18,'Dory.Silva@gmail.com','National Identity Card','385777201','2027-12-03','Dory Silva','610-871-8234','Russia','Moskow','Moskow','40-52 Tverskaya Street','125009','1968-11-11','Female'),
(19,'Mulan.Hua@gmail.com','National Identity Card','867041350','2024-05-05','Mulan Hua' ,'818-955-9611','USA','California','Burbank','1515 W. Olive Avenue','91506','2004-02-04','Female'),
(20,'Muana.Esteves@gmail.com','National Identity Card','837623240','2024-11-22','Muana Esteves','480-648-4688','USA','Maryland','Baltimore','24-85 Eutaw Place','21201','1996-11-03','Female'),
(21,'Rapunzel.Bezerra@gmail.com','National Identity Card','137715245','2026-08-08','Rapunzel Bezerra' ,'614-253-1881','Ireland','Dublin','Dublin','6-3/4 Wexford Street','D2','1987-09-27','Female'),
(22,'Fiona.Graciete@gmail.com','Passport','US9647821','2026-03-01','Fiona Graciete','832-932-9186','USA','New York','New York','506 5th Avenue','10017','1964-05-12','Female'),
(23,'Anna.Arendelle@gmail.com','National Identity Card','191374322','2025-08-23','Anna Arendelle','919-890-7899','Australia','Melbourne','Melbourne','32-43 Southbank Boulevard','3006','1965-10-13','Female'),
(24,'Cruella.DeVil@gmail.com','National Identity Card','915494747','2023-12-05','Cruella DeVil','240-430-4543','Dominican Republic','Santo Domingo','Santo Domingo', '4 Autopista Duarte','10109','1973-05-16','Female'),
(25,'Elsa.Arendelle@gmail.com','National Identity Card','385605990','2027-03-01','Elsa Arendelle' ,'651-921-7137','Hong Kong','Central','Central','4th Floor 19-21 Wellington Street','2001','1972-04-15','Female'),
(26,'Wendy.Darling@gmail.com','National Identity Card','456826746','2024-03-01','Wendy Darling','678-402-6826','South Africa','Johannesburg','Johannesburg','25 Skyline Drive','2090','1971-06-07','Female'),
(27,'Elly.Moda@gmail.com','National Identity Card','233547087','2023-05-29','Elly Moda','717-628-5903','Canada','Quebec','Quebec','467 Rue St. Jean','G1R 5G4','1977-02-19','Female'),
(28,'Sally.Carrera@gmail.com','National Identity Card','525877860','2025-06-25','Sally Carrera','301-957-9194','Singapore','Jacarta','Jacarta','3-2-3/3 Orchard Road','238899','1971-10-29','Female'),
(29,'Glória.Viseu@gmail.com','Passport','US1234719','2025-07-26','Glória Viseu','912-822-1362','USA','California','Los Angeles','1201 South Hope Street','90015','1987-06-24','Female'),
(30,'Lilo.Pelekai@gmail.com','National Identity Card','249087452','2024-03-30','Lilo Pelekai','904-320-4511','Belgium','Brussels','Brussels',' 8 Rue de lUniversite','1000','1988-07-06','Female');

INSERT INTO discount(discount_id,`code`,rate,start_time,end_time)
VALUES (1,'FCV',0.1,'2020-05-01 00:00:01','2020-05-10 23:59:59'),
(2,'AGH',0.05,'2020-11-01 00:00:01','2020-11-10 23:59:59'),
(3,'KJH',0.2,'2021-05-01 00:00:01','2021-05-01 23:59:59'),
(4,'ETB',0.1,'2021-11-01 00:00:01','2021-11-10 23:59:59'),
(5,'MNK',0.15,'2022-01-01 00:00:01','2022-01-10 23:59:01'),
(6,'JUI',0.2,'2022-05-01 00:00:01','2022-05-10 23:59:59');

INSERT INTO route (route_id, origin_id,destination_id,distance)
VALUES (1,1,8,8073),
(2,2,3,6764),
(3,4,5,8184),
(4,6,7,8441),
(5,9,10,8907),
(6,11,12,8053),
(7,13,14,8945),
(8,15,3,6788),
(9,16,17,7179),
(10,18,1,6082);

INSERT INTO flight (flight_id,flight_number,aircraft_id,route_id,pilot_id,predicted_departure_time,predicted_arrival_time,departure_time,arrival_time, air_time,price,tickets_sold_rate)
VALUES (1,'AA163',2,3,3,'2020-05-12 03:30:00','2020-05-12 11:30:00','2020-05-12 04:00:00','2020-05-12 11:25:00','07:05:00',1077,0.10),
(2,'DL521',1,2,2, '2020-05-12 14:30:00','2020-05-12 23:45:00','2020-05-12 23:33:00','2020-05-13 09:00:00','08:47:00',1063,0.11), 
(3,'UA983',3,4,4,'2020-06-03 06:00:00','2020-06-03 20:50:00','2020-06-03 06:20:00','2020-06-03 20:30:00','14:07:00',1231,0.25),
(4,'LH531',4,6,1,'2020-07-15 11:00:00','2020-07-15 22:00:00','2020-07-15 11:10:00','2020-07-15 21:35','10:15:00',1324,0.09),
(5,'AF231',3,5,3,'2020-10-07 08:15:00','2020-10-07 20:15:00','2020-10-07 08:27:00','2020-10-07 22:45:00','11:41:00',1113,0.13),
(6,'SQ747',1,2,5,'2020-11-12 12:00:00','2020-11-12 21:15:00','2020-11-12 12:15:00','2020-11-12 21:10:00','08:47:00',1453,0.11),
(7,'KL731',7,7,1,'2020-12-24 14:00:00','2020-12-25 02:40:00','2020-12-24 14:10:00','2020-12-25 02:30:00','12:15:00',1009,0.17),
(8,'EY632',2,8,2,'2020-12-31 20:00:00','2021-01-01 06:35:00','2020-12-31 20:15:00','2021-01-01 06:30:00','10:10:00',1088,0.10),
(9,'QF227',3,1,4,'2021-01-15 05:00:00','2021-01-15 19:55:00','2021-01-15 05:10:00','2021-01-15 19:47:00','14:24:00',1015,0.13),
(10,'BA819',4,5,2,'2021-02-14 07:30:00','2021-02-14 19:45:00','2021-02-14 07:45:00','2021-02-14 19:45:00','11:41:00',1206,0.09),
(11,'CX074',5,10,1,'2021-03-25 10:15:00','2021-03-25 19:10:00','2021-03-25 10:25:00','2021-03-25 19:03:00','08:25:00',1321,0.20),
(12,'AY487',1,3,5,'2021-04-21 09:00:00','2021-04-21 16:40:00','2021-04-21 09:15:00','2021-04-21 16:30:00','07:05:00',1411,0.11),
(13,'KQ945',6,4,3,'2021-05-12 09:30:00','2021-05-12 17:05:00','2021-05-12 10:00:00','2021-05-12 17:25:00','07:05:00',1032,0.07),
(14,'OZ356',5,9,4,'2021-06-13 08:45:00','2021-06-13 19:00:00','2021-06-13 09:00:00','2021-06-13 19:00:00','09:50:00',1090,0.20),
(15,'JL219',7,2,2,'2021-08-17 07:10:00','2021-08-17 16:30:00','2021-08-17 07:25:00','2021-08-17 16:20:00','08:47:00',1124,0.08),
(16,'TG532',3,1,4,'2021-10-10 08:00:00','2021-10-10 23:10:00','2021-10-10 08:12:00','2021-10-10 22:47:00','14:24:00',980,0.13),
(17,'MH231',2,4,1,'2021-12-23 05:00:00','2021-12-23 19:55:00','2021-12-23 05:10:00','2021-12-23 19:28:00','14:07:00',1130,0.20),
(18,'NZ811',6,5,5,'2022-01-05 10:30:00','2022-01-05 22:55:00','2022-01-05 10:42:00','2022-01-05 22:32:00','11:41:00',1025,0.07),
(19,'VA095',3,10,2,'2022-03-02 11:00:00','2022-03-02 20:10:00','2022-03-02 11:07:00','2022-03-02 19:37:00','08:25:00',1210,0.38),
(20,'AR993',5,8,3,'2022-05-13 09:30:00','2022-05-13 20:30:00','2022-05-13 09:30:00','2022-05-13 19:53:00','10:10:00',1090,0.50);

INSERT INTO `order` (order_id,cust_id,date_time,discount_id)
VALUES (1,1,'2020-05-02 09:30:00',1),
(2,2,'2020-05-10 14:15:00',NULL),
(3,3,'2020-06-01 06:00:00',NULL),
(4,4,'2020-06-02 06:01:00',NULL),
(5,5,'2020-07-05 11:00:00',NULL),
(6,6,'2020-10-02 08:15:00',NULL),
(7,7,'2020-11-12 12:00:00',NULL),
(8,8,'2020-12-14 14:00:00',NULL),
(9,9,'2020-12-17 14:01:00',NULL),
(10,10,'2020-12-25 20:00:00',NULL),
(11,11,'2021-01-05 05:00:00',NULL),
(12,12,'2021-02-08 07:30:00',NULL),
(13,13,'2021-03-15 10:15:00',NULL),
(14,14,'2021-03-17 10:16:00',NULL),
(15,15,'2021-04-15 9:00:00',NULL),
(16,16,'2021-05-06 09:30:00',NULL),
(17,17,'2021-06-03 08:45:00',NULL),
(18,18,'2021-06-07 08:46:00',NULL),
(19,19,'2021-08-07 07:10:00',NULL),
(20,20,'2021-10-02 08:00:00',NULL),
(21,21,'2021-12-12 05:00:00',NULL),
(22,22,'2021-12-18 05:01:00',NULL),
(23,23,'2022-01-01 10:30:00',NULL),
(24,24,'2022-02-25 11:00:00',NULL),
(25,25,'2022-02-26 11:01:00',NULL),
(26,26,'2022-02-27 11:02:00',NULL),
(27,27,'2022-05-03 09:30:00',NULL),
(28,28,'2022-05-04 09:31:00',6),
(29,29,'2022-05-05 09:32:00',NULL),
(30,1,'2022-05-08 09:33:00',NULL),
(31,1,'2022-05-08 09:35:00',NULL);

INSERT INTO order_item (order_item_id,order_id,flight_id,seat_code)
VALUES (1,1,1,1),
(2,2,2,1),
(3,3,3,1),
(4,4,3,2),
(5,5,4,1),
(6,6,5,1),
(7,7,6,1),
(8,8,7,1),
(9,9,7,2),
(10,10,8,1),
(11,11,9,1),
(12,12,10,1),
(13,13,11,1),
(14,14,11,2),
(15,15,12,1),
(16,16,13,1),
(17,17,14,1),
(18,17,15,1),
(19,18,14,2),
(20,19,16,1),
(21,20,17,1),
(22,21,17,2),
(23,22,18,1),
(24,23,19,1),
(25,24,19,2),
(26,25,19,3),
(27,26,20,1),
(28,27,20,2),
(29,28,20,3),
(30,29,20,4),
(31,30,20,5),
(32,31,20,6);

INSERT INTO rating(rating_id,rating_number,rating_comment,flight_id,cust_id)
VALUES (1,4,'Very Nice',1,1),
(2,3,NULL,2,2),
(3,4,NULL,3,3),
(4,4,NULL,3,4),
(5,5,'Everything was smooth',5,6),
(6,5,NULL,6,7),
(7,4,NULL,7,8),
(8,3,'I didn´t like the food options :/',8,10),
(9,4,NULL,9,11),
(10,4,NULL,10,12),
(11,5,'I loved the quality of the seat!',11,13),
(12,3,NULL,11,14),
(13,3,NULL,12,15),
(14,4,NULL,14,17),
(15,3,NULL,14,18),
(16,5,NULL,15,19),
(17,4,NULL,17,21),
(18,3,NULL,17,22),
(19,4,NULL,18,23),
(20,4,NULL,19,24),
(21,5,NULL,19,26),
(22,5,NULL,20,27),
(23,4,NULL,20,28),
(24,5,NULL,20,29),
(25,5,NULL,20,30),
(26,5,'Always a great experience',20,1);

INSERT INTO payment (payment_id,order_id,total_price,tax_rate,`type`,paypal_email,card_number,card_name,card_cvv,card_expiration,`status`)
VALUES (1,1,1077,0.05,'Paypal','Aladdin.Ababa@gmail.com',NULL,NULL,NULL,NULL,1),
(2,2,1063,0.05,'Paypal','Nemo.Silva@gmail.com',NULL,NULL,NULL,NULL,1),
(3,3,1231,0.05,'Credit Card',NULL,'2987668512212720','Woody Pride' ,646,'2023-05-20',1),
(4,4,1231,0.05,'Credit Card',NULL,'4878434400232950','Olaf Brigham',960,'2027-07-02',1),
(5,5,1324,0.05,'Credit Card',NULL,'3592310305297410','Dunga Cruz',124,'2022-06-04',1),
(6,6,1113,0.05,'Paypal','Shrek.Galguinho@gmail.com',NULL,NULL,NULL,NULL,1),
(7,7,1453,0.05,'Credit Card',NULL,'1338647231834690','Gaston LeGume',665,'2026-05-19',1),
(8,8,1009,0.05,'Credit Card',NULL,'7410990395170800','Hércules Ferreira',447,'2027-03-18',1),
(9,9,1009,0.05,'Credit Card',NULL,'2416838156117270','Bambi Agostinho',784,'2023-06-16',1),
(10,10,1088,0.05,'Credit Card',NULL,'9553621766811310','Peter Pan',534,'2026-08-26',1),
(11,11,1015,0.05,'Credit Card',NULL,'1209132789879270','Winnie Pooh',881,'2026-04-17',1),  			
(12,12,1206,0.05,'Credit Card',NULL,'3914398371273610','Simba Sousa',207,'2025-01-15',1),
(13,13,1321,0.05,'Credit Card',NULL,'8928700508924290','Mufasa Pereira',356,'2023-07-12',1),
(14,14,1321,0.05,'Credit Card',NULL,'4944143222725290','Pumba Felício',338,'2027-04-20',1),
(15,15,1411,0.05,'Credit Card',NULL,'9003399010149260','Remy Ratatouille',151,'2022-11-18',1),
(16,16,1032,0.05,'Credit Card',NULL,'7141086311713830','Mike Wazoswki',593,'2022-04-05',1),
(17,17,2214,0.05,'Paypal','Bela.Alves@gmail.com',NULL,NULL,NULL,NULL,1),
(18,18,1090,0.05,'Credit Card',NULL,'3870148787023270','Mulan Hua',404,'2026-11-29',1),
(19,19,980,0.05,'Credit Card',NULL,'4535509581033990','Muana Esteves',529,'2025-11-23',1),
(20,20,1130,0.05,'Credit Card',NULL,'8651441905907930','Rapunzel Bezerra ',972,'2025-07-06',1),
(21,21,1130,0.05,'Credit Card',NULL,'9179081790628240','Fiona Graciete',380,'2026-12-05',1),
(22,22,1025,0.05,'Credit Card',NULL,'3145855359040450','Anna Arendelle',950,'2027-11-04',1),
(23,23,1210,0.05,'Credit Card',NULL,'9357035824184400','Cruella DeVil',807,'2026-08-22',1),
(24,24,1210,0.05,'Credit Card',NULL,'5195219385157740','Elsa Arendelle' ,877,'2023-11-04',1),
(25,25,1210,0.05,'Credit Card',NULL,'5369009685357840','Wendy Darling',174,'2024-08-22',1),
(26,26,1090,0.05,'Credit Card',NULL,'4206853988916210','Elly Moda',470,'2023-10-24',1),
(27,27,1090,0.05,'Credit Card',NULL,'1561342689017120','Sally Carrera',721,'2027-10-05',1),
(28,28,1090,0.05,'Paypal','Glória.Viseu@gmail.com',NULL,NULL,NULL,NULL,1),
(29,29,1090,0.05,'Credit Card',NULL,'5783678139785920','Lilo Pelekai',543,'2023-10-11',1),
(30,30,1090,0.05,'Paypal','Aladdin.Ababa@gmail.com',NULL,NULL,NULL,NULL,1),
(31,31,1090,0.05,'Credit Card',NULL,'3583476439754520','Aladdin Ababa',902,'2025-06-24',0);


INSERT INTO check_in (check_in_id, cust_id,flight_id, checked_in)
VALUES (1,1,1,1),
(2,2,2,1),
(3,3,3,1),
(4,4,3,1),
(5,5,4,1),
(6,6,5,1),
(7,7,6,1),
(8,8,7,1),
(9,9,7,1),
(10,10,8,1),
(11,11,9,1),
(12,12,10,1),
(13,13,11,1),
(14,14,11,1),
(15,15,12,1),
(16,16,13,1),
(17,17,14,1),
(18,18,14,1),
(19,19,15,1),
(20,20,16,1),
(21,21,17,1),
(22,22,17,1),
(23,23,18,1),
(24,24,19,1),
(25,25,19,1),
(26,26,19,1),
(27,27,20,1),
(28,28,20,1),
(29,29,20,1),
(30,30,20,1),
(31,1,20,0);

INSERT INTO boarding (boarding_id,check_in_id,boarded)
VALUES (1,1,1),
(2,2,1),
(3,3,1),
(4,4,1),
(5,5,1),
(6,6,1),
(7,7,1),
(8,8,1),
(9,9,1),
(10,10,1),
(11,11,1),
(12,12,1),
(13,13,1),
(14,14,1),
(15,15,1),
(16,16,1),
(17,17,1),
(18,18,1),
(19,19,1),
(20,20,1),
(21,21,1),
(22,22,1),
(23,23,1),
(24,24,1),
(25,25,1),
(26,26,1),
(27,27,1),
(28,28,1),
(29,29,1),
(30,30,1);


################################################################
## Trigger 1 -> a trigger that inserts a row in a “log” table ##
################################################################

#DROP TRIGGER `aircraft_update_log`;
DELIMITER $$
CREATE TRIGGER `aircraft_update_log` AFTER UPDATE ON aircraft
FOR EACH ROW
BEGIN
	INSERT INTO aircraft_log(user,aircraft_id,datetime_change,old_aircraft_registration,
	old_total_flight_time,old_capacity,old_model,old_manufacturer,old_date_manufacture,
	new_aircraft_registration,new_total_flight_time,new_capacity,new_model,new_manufacturer,
	new_date_manufacture) 
	VALUES (USER(),NEW.aircraft_id,NOW(),OLD.aircraft_registration,OLD.total_flight_time,
	OLD.capacity,OLD.model,OLD.manufacturer,OLD.date_manufacture,NEW.aircraft_registration,
	NEW.total_flight_time,NEW.capacity,NEW.model, NEW.manufacturer,NEW.date_manufacture);
END $$
DELIMITER ;

# Testing trigger 1
UPDATE aircraft a
SET a.total_flight_time="130:00:00"
WHERE a.aircraft_id=5;
SELECT * FROM aircraft_log;

######################################################################
## Trigger 2 -> a trigger for update a pilot associated to a flight ##
######################################################################

#DROP TRIGGER `pilot_change`;
DELIMITER $$
CREATE TRIGGER pilot_change BEFORE UPDATE ON flight
FOR EACH ROW
BEGIN
    IF  
		OLD.pilot_id!=NEW.pilot_id AND
		((SELECT ABS(MIN(DATEDIFF(f.predicted_arrival_time,NEW.predicted_departure_time)))
        FROM flight f
        WHERE pilot_id=NEW.pilot_id)<1 
        OR 
        (SELECT ABS(MIN(DATEDIFF(f.predicted_departure_time,NEW.predicted_arrival_time)))
        FROM flight f
        WHERE pilot_id=NEW.pilot_id)<1)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Unavailable Pilot';
END IF;
END $$
DELIMITER ;
/*
Here, we assume that a pilot can be assigned to a new flight only if he/she is not piloting any flight
that arrives within a day of the new flight departure time and if he/she is not piloting any flight that 
departs within a day of the new flight arrival time (and we know that we do not have two flights happening
at the same time).	
This trigger is activated if in the table flight we adjust the pilot. 
If this happens and the assumption above is violated, an error occurs named 'Unavailable Pilot' and the 
trigger blocks the update.
*/

# Testing trigger 2
#UPDATE flight f
#SET f.pilot_id=3
#WHERE f.flight_id=2;

UPDATE flight f
SET f.pilot_id=4
WHERE f.flight_id=2;

############################################################################
## Trigger 3 -> a trigger for update the boarding "status" after check-in ##
############################################################################

#DROP TRIGGER `boarding_update`;
DELIMITER $$
CREATE TRIGGER `boarding_update` AFTER UPDATE ON check_in 
FOR EACH ROW
BEGIN
	IF OLD.checked_in=0 AND NEW.checked_in=1 THEN 
		INSERT INTO boarding(check_in_id) VALUES (NEW.check_in_id);
	END IF;
END $$ 
DELIMITER ;
/*
Here, the idea is that when the customer checks in for their flight, a new line is inserted in the boarding
table with the check_in_id. This because only the customers that have checked in for their flights are able
to board the flight.
*/

# Testing trigger 3
UPDATE check_in c
SET c.checked_in=1
WHERE c.check_in_id=31;
SELECT * FROM boarding;

############################################
## View 1 -> View for the Head and Totals ##
############################################

#DROP VIEW invoice_head_totals;
CREATE VIEW `invoice_head_totals` AS
SELECT o.order_id AS 'Invoice Number',CAST(o.date_time AS DATE) AS 'Date of Issue',
c.full_name AS 'Customer Name', c.address AS "Customer's Address", 
CONCAT(c.city,", ",c.state,", ",c.country) AS "Customer's City, State and Country",
c.postal_code AS "Customer's Postal Code", "FlyHigh" AS "Company's Name",
"604 Sunset BL" AS "Company's Address","Los Angeles, California, USA"
AS "Company's City,State and Country", "(323) 848-0939" AS "Company's Phone Number",
"flyhigh@high.us" AS "Company's Email", "www.flyhigh.com" AS "Company's Website",
o.date_time + interval 30 minute AS 'Pay by', p.total_price AS 'Subtotal',p.tax_rate AS 'Tax Rate',
ROUND((p.total_price*(1-IFNULL(d.rate,0)))*(p.tax_rate),2) AS 'Tax',
ROUND(p.total_price*IFNULL(d.rate,0),2) AS 'Discount',
ROUND((p.total_price-IFNULL(d.rate,0)*p.total_price)*(1+p.tax_rate),2) AS 'Total'
FROM `order` o
JOIN customer c ON c.cust_id=o.cust_id
JOIN payment p ON p.order_id=o.order_id
LEFT JOIN discount d ON d.discount_id=o.discount_id;

############################################
## View 2 -> View for the invoice details ##
############################################
#DROP VIEW invoice_details;
CREATE VIEW `invoice_details` AS                     
SELECT o.order_id AS 'Invoice Number', f.flight_number AS 'Item Name', 
f.price AS 'Unit Cost'
FROM `order` o
JOIN order_item i ON i.order_id=o.order_id
JOIN flight f ON f.flight_id=i.flight_id
GROUP BY i.order_item_id;
#Here we did not consider quantity and amount because, within our business process,
#the client is not able to buy more than one ticket for the same flight (at least not under the same cust_id).

#Testing the views
SELECT * FROM invoice_head_totals;
SELECT * FROM invoice_details;
