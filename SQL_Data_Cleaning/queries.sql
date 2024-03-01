/*

Cleaning Data in SQL Queries

*/


SELECT * FROM nashville_housing;

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
---- Identify records where property_address is null
SELECT * 
FROM nashville_housing
WHERE property_address IS NULL
ORDER BY parcel_id;

SELECT
	a.parcel_id,
	a.property_address,
	b.parcel_id,
	b.property_address,
	COALESCE(a.property_address,b.property_address)
FROM nashville_housing a
	JOIN nashville_housing b
		ON a.parcel_id = b.parcel_id
		AND a.unique_id <> b.unique_id
WHERE
	a.property_address IS NULL;

UPDATE nashville_housing AS a
	SET property_address = COALESCE(a.property_address, b.property_address)
	FROM nashville_housing AS b
	WHERE a.parcel_id = b.parcel_id
	  AND a.unique_id <> b.unique_id;

SELECT * FROM nashville_housing;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT property_address FROM nashville_housing;

SELECT
	property_address,
	SUBSTRING(property_address, 1, POSITION(',' IN property_address) - 1) AS address,
	SUBSTRING(property_address, POSITION(',' IN property_address) + 1, LENGTH(property_address)) AS city
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD property_split_address varchar;

UPDATE nashville_housing
	SET property_split_address = SUBSTRING(property_address, 1, POSITION(',' IN property_address) - 1);

ALTER TABLE nashville_housing
ADD property_split_city varchar;

UPDATE nashville_housing
	SET property_split_city = SUBSTRING(property_address, POSITION(',' IN property_address) + 1, LENGTH(property_address));
	
SELECT 
	property_address, 
	property_split_address,
	property_split_city
FROM nashville_housing;


SELECT owner_address FROM nashville_housing;

SELECT
    REVERSE(SPLIT_PART(REVERSE(owner_address), ',', 3)) AS parsed_address,
	REVERSE(SPLIT_PART(REVERSE(owner_address), ',', 2)) AS parsed_city,
	REVERSE(SPLIT_PART(REVERSE(owner_address), ',', 1)) AS parsed_state
FROM
    nashville_housing;

ALTER TABLE nashville_housing
	ADD owner_split_address varchar;

UPDATE nashville_housing
	SET owner_split_address = REVERSE(SPLIT_PART(REVERSE(owner_address), ',', 3));

ALTER TABLE nashville_housing
	ADD owner_split_city varchar;

UPDATE nashville_housing
	SET owner_split_city = REVERSE(SPLIT_PART(REVERSE(owner_address), ',', 2));

ALTER TABLE nashville_housing
	ADD owner_split_state varchar;

UPDATE nashville_housing
	SET owner_split_state = REVERSE(SPLIT_PART(REVERSE(owner_address), ',', 1));

SELECT 
	owner_address,
	owner_split_address,
	owner_split_city,
	owner_split_state
FROM nashville_housing;
	
	
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT 
	DISTINCT(sold_as_vacant), 
	COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY 1
ORDER BY 2;

SELECT 
	sold_as_vacant,
	CASE
		WHEN sold_as_vacant = 'Y' THEN 'Yes'
		WHEN sold_as_vacant = 'N' THEN 'No'
		ELSE sold_as_vacant
	END
FROM nashville_housing;

UPDATE nashville_housing
	SET sold_as_vacant =
		CASE
			WHEN sold_as_vacant = 'Y' THEN 'Yes'
			WHEN sold_as_vacant = 'N' THEN 'No'
			ELSE sold_as_vacant
		END;

SELECT 
	DISTINCT(sold_as_vacant), 
	COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY 1
ORDER BY 2;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
DELETE FROM nashville_housing
WHERE unique_id NOT IN (
    SELECT unique_id
    FROM (
        SELECT unique_id,
            ROW_NUMBER() OVER (
                PARTITION BY 
                    parcel_id,
                    property_address,
                    sale_price,
                    sale_date,
                    legal_reference
                ORDER BY
                    unique_id
            ) AS row_num
        FROM nashville_housing
    ) AS subquery
    WHERE row_num = 1
);


WITH row_num_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                parcel_id,
                property_address,
                sale_price,
                sale_date,
                legal_reference
            ORDER BY
                unique_id) AS row_num
    FROM nashville_housing
)
SELECT 
	row_num,
	COUNT(row_num) AS count_duplicates
FROM row_num_cte
GROUP BY 1;



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
ALTER TABLE nashville_housing
DROP COLUMN owner_address, 
DROP COLUMN property_address;

SELECT * FROM nashville_housing;



