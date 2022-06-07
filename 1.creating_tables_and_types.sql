
DROP TABLE IF EXISTS department_levels;
CREATE TABLE department_levels (
    id SERIAL PRIMARY KEY,
    name VARCHAR (20) NOT NULL
);

DROP TABLE IF EXISTS department_types;
CREATE TABLE department_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR (35) NOT NULL
);

DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR (50) UNIQUE NOT NULL,
    parent_id INTEGER NOT NULL,
    level_id INTEGER NOT NULL,
    type_id INTEGER
);

DROP TABLE IF EXISTS plants;
DROP TYPE IF EXISTS AXIS_TYPE;
CREATE TYPE AXIS_TYPE AS (latitude REAL, longitude REAL);
CREATE TABLE plants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) UNIQUE NOT NULL,
    department_id INTEGER NOT NULL,
    axis_place AXIS_TYPE NOT NULL,
    prev_id INTEGER NOT NULL, -- Для выстроения дерева (схема сбора нефти)
    next_id INTEGER NOT NULL -- Для выстроения дерева (схема сбора нефти)
);

DROP TABLE IF EXISTS tanks;
CREATE TABLE tanks (
    id SERIAL PRIMARY KEY,
    plant_id INTEGER NOT NULL,
    name VARCHAR(20) NOT NULL
);

DROP TABLE IF EXISTS business_plans;
CREATE TABLE business_plans (
    id SERIAL PRIMARY KEY,
    cdate DATE NOT NULL,
    plant_id INTEGER NOT NULL,
    oil_mining REAL NOT NULL,
    water_drop REAL NOT NULL
);

DROP TABLE IF EXISTS two_hour_mining_reports;
DROP TABLE IF EXISTS water_drop_reports;
DROP TABLE IF EXISTS tanks_reports;

DROP TYPE IF EXISTS CTIMES;
CREATE TYPE CTIMES AS ENUM
    ('02:00','04:00','06:00','08:00','10:00','12:00',
     '14:00','16:00','18:00','20:00','22:00','00:00');

CREATE TABLE two_hour_mining_reports (
    id SERIAL PRIMARY KEY,
    cdate DATE NOT NULL,
    ctime CTIMES NOT NULL,
    plant_id INTEGER NOT NULL,
    liquid REAL NOT NULL,
    oil REAL NOT NULL
);
CREATE TABLE tanks_reports (
    id SERIAL PRIMARY KEY,
    cdate DATE NOT NULL,
    ctime CTIMES NOT NULL,
    tank_id INTEGER NOT NULL,
    volume REAL NOT NULL
);

CREATE TABLE water_drop_reports (
    id SERIAL PRIMARY KEY,
    cdate DATE NOT NULL,
    plant_id INTEGER NOT NULL,
    volume REAL NOT NULL
);

DROP TABLE IF EXISTS daily_mining_reports;
CREATE TABLE daily_mining_reports (
    id SERIAL PRIMARY KEY,
    cdate DATE NOT NULL,
    plant_id INTEGER NOT NULL,
    liquid REAL NOT NULL,
    oil REAL NOT NULL,
    water_drop REAL NOT NULL,
    liquid_pump REAL NOT NULL,
    oil_availability REAL NOT NULL,
    oil_free REAL NOT NULL,
    pump_pressure REAL NOT NULL,
    gas_pump REAL NOT NULL,
    equipment_pressure VARCHAR(10) NOT NULL
);

DROP TABLE IF EXISTS monthly_reports;
CREATE TABLE monthly_reports (
    id SERIAL PRIMARY KEY,
    mdate DATE NOT NULL, -- дата может быть только последний день месяца
    plant_id INTEGER NOT NULL,
    oil_mining REAL NOT NULL,
    water_drop REAL NOT NULL,
    oil_mining_difference REAL NOT NULL,
    water_drop_difference REAL NOT NULL
);

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR (50) UNIQUE NOT NULL,
    passwd VARCHAR (30) NOT NULL,
    first_name VARCHAR (30) NOT NULL,
    last_name VARCHAR (30) NOT NULL,
    role_department_id INTEGER NOT NULL,
    role_is_write BOOLEAN NOT NULL DEFAULT false
);


