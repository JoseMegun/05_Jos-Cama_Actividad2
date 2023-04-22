											--ACTIVIDAD 01 --- 05_Jose Megun Cama La Madrid--

/* Si la base de datos ya existe la eliminamos */
DROP DATABASE IF EXISTS db_SalesClothes
GO

/*crear la base de datos db_SalesClothes: */
CREATE DATABASE db_SalesClothes;

/*Poner en uso la base de datos db_SalesClothes: */
USE db_SalesClothes;

/*Configurar el idioma español el motor de base de datos: */
SET LANGUAGE Español
GO

/* Ver idioma de SQL Server */
SELECT @@language AS 'Idioma'
GO

/*Configurar el formato de fecha en dmy (día, mes y año) en el motor de base de datos: */
SET DATEFORMAT dmy
GO

/* Ver formato de fecha y hora del servidor */
SELECT sysdatetime() as 'Fecha y  hora'
GO

/*Crear la tabla client con la siguiente estructura: */
/*
-El campo id es clave principal y autoincrementable, empieza en 1 e incrementa de 1 en uno.
-El campo type_document sólo puede admitir datos como DNI ó CNE
-El campo number_document sólo permite dígitos entre 0 a 9, y serán 8 cuando es DNI y 9 cuando sea CNE.
-El el campo email sólo permite correos electrónicos válidos, por ejemplo: mario@gmail.com
-El campo cell_phone acepta solamente 9 dígitos numéricos, por ejemplo: 997158238.
-El campo birthdate sólo permite la fecha de nacimiento de clientes mayores de edad.
-El campo active tendrá como valor predeterminado 1, que significa que el cliente está activo. 
*/
CREATE TABLE client(
	id int  identity(1,1),
    type_document char(3) CHECK(type_document ='DNI' OR type_document ='CNE'),
    number_document char(15)  CHECK (number_document like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^A-Z]'),
    names Varchar(60)  NOT NULL,
    last_name Varchar(90)  NOT NULL,
    email Varchar(80)  CHECK(email LIKE '%@%._%'),
    cell_phone Char(9)  CHECK (cell_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    birthdate date CHECK((YEAR(GETDATE())- YEAR(birthdate )) >= 18),
    active bit  DEFAULT (1),
    CONSTRAINT client_pk PRIMARY KEY  (id)
);

/*Crear la tabla seller con la siguiente estructura: */
/* 
-El campo id es clave principal y autoincrementable, empieza en 1 e incrementa de 1 en uno.
-El campo type_document sólo puede admitir datos como DNI ó CNE
-El campo number_document sólo permite dígitos entre 0 a 9, y serán 8 cuando es DNI y 9 cuando sea CNE.
-El campo salary tiene como valor predeterminado 1025
-El campo cell_phone acepta solamente 9 dígitos numéricos, por ejemplo: 997158238.
-El el campo email sólo permite correos electrónicos válidos, por ejemplo: roxana@gmail.com
-El campo active tendrá como valor predeterminado 1, que significa que el cliente está activo.
*/
CREATE TABLE seller (
    id int  identity(1,1),
    type_document char(3)  CHECK(type_document ='DNI' OR type_document ='CNE'),
    number_document char(15)  CHECK (number_document like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^A-Z]'),
    names varchar(60)  NOT NULL,
    last_name varchar(90)  NOT NULL,
    salary decimal(8,2)  DEFAULT (1025),
    cell_phone char(9)  CHECK (cell_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    email varchar(80)  CHECK(email LIKE '%@%._%'),
    active bit  DEFAULT (1),
    CONSTRAINT seller_pk PRIMARY KEY  (id)
);

/*Crear la tabla clothes con la siguiente estructura: */
/*
-El campo id es clave principal y autoincrementable, empieza en 1 e incrementa de 1 en uno.
-El campo active tendrá como valor predeterminado 1, que significa que el cliente está activo.
*/
CREATE TABLE clothes (
    id int  identity(1,1),
    descriptions varchar(60)  NOT NULL,
    brand varchar(60)  NOT NULL,
    amount int  NOT NULL,
    size varchar(10)  NOT NULL,
    price decimal(8,2)  NOT NULL,
    active bit   DEFAULT (1),
    CONSTRAINT clothes_pk PRIMARY KEY  (id)
);

/*Crear la tabla sale con la siguiente estructura: */
/*
-El campo id es clave principal y autoincrementable, empieza en 1 e incrementa de 1 en uno.
-El campo active tendrá como valor predeterminado 1, que significa que el cliente está activo.
*/
CREATE TABLE sale (
    id int  identity(1,1),
    date_time datetime NOT NULL,
	seller_id int  NOT NULL,
	client_id int  NOT NULL,
    active bit   DEFAULT (1),
    CONSTRAINT sale_pk PRIMARY KEY  (id)
);

/* El campo date_time debe tener como valor predeterminado la fecha y hora del servidor. */
--Quitar columna date_time en tabla sale
ALTER TABLE sale
	DROP COLUMN date_time
GO

-- Agregar columna date_time en la columna sale 
ALTER TABLE sale
	ADD date_time datetime
GO

--Valor predeterminado fecha y hora del servidor 
ALTER TABLE sale
	ADD CONSTRAINT date_time_sale DEFAULT (GETDATE()) FOR date_time
GO


/*Crear la tabla sale_detail con la siguiente estructura: */
CREATE TABLE sale_detail (
    id int  NOT NULL,
    sale_id int  NOT NULL,
    clothes_id int  NOT NULL,
	amount int  NOT NULL,
    CONSTRAINT sale_detail_pk PRIMARY KEY  (id)
);

/* Listar tablas de la base de datos db_SalesClothes */
SELECT * FROM INFORMATION_SCHEMA.TABLES
GO

/*Creación de relaciones: */
/*RELACIÓN DE sale_client:*/
ALTER TABLE sale
	ADD CONSTRAINT sale_client FOREIGN KEY (client_id)
	REFERENCES client (id)
	ON UPDATE CASCADE 
      ON DELETE CASCADE
GO

/*RELACIÓN DE sale_seller:*/
ALTER TABLE sale
	ADD CONSTRAINT sale_seller FOREIGN KEY (seller_id)
	REFERENCES seller (id)
	ON UPDATE CASCADE 
      ON DELETE CASCADE
GO

/*RELACIÓN DE sale_detail_clothes: */
ALTER TABLE sale_detail
	ADD CONSTRAINT sale_detail_clothes FOREIGN KEY (clothes_id)
	REFERENCES clothes (id)
	ON UPDATE CASCADE 
      ON DELETE CASCADE
GO

/*RELACIÓN DE sale_detail_sale: */
ALTER TABLE sale_detail
	ADD CONSTRAINT sale_detail_sale FOREIGN KEY (sale_id)
	REFERENCES sale (id)
	ON UPDATE CASCADE 
      ON DELETE CASCADE
GO

/* Ver relaciones creadas entre las tablas de la base de datos */
SELECT 
    fk.name [Constraint],
    OBJECT_NAME(fk.parent_object_id) [Tabla],
    COL_NAME(fc.parent_object_id,fc.parent_column_id) [Columna FK],
    OBJECT_NAME (fk.referenced_object_id) AS [Tabla base],
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS [Columna PK]
FROM 
    sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fc ON (fk.OBJECT_ID = fc.constraint_object_id)
GO



