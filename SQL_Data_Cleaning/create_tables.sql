DROP TABLE IF EXISTS nashville_housing;

CREATE TABLE nashville_housing (
    unique_id  int PRIMARY KEY,
    parcel_id varchar,
    land_use varchar,
    property_address varchar,
    sale_date date,
    sale_price numeric,
    legal_reference varchar,
    sold_as_vacant varchar,
    owner_name varchar,
    owner_address varchar,
    acreage numeric,
    tax_district varchar,
    land_value numeric,
    building_value numeric,
    total_value numeric,
    year_built int,
    bedrooms int,
    full_bath int,
    half_bath int);
