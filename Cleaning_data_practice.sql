CREATE TABLE tableName (
    UniqueID 	VARCHAR(512),
    ParcelID	VARCHAR(512),
    LandUse	VARCHAR(512),
    PropertyAddress	VARCHAR(512),
    SaleDate	VARCHAR(512),
    SalePrice	VARCHAR(512),
    LegalReference	VARCHAR(512),
    SoldAsVacant	VARCHAR(512),
    OwnerName	VARCHAR(512),
    OwnerAddress	VARCHAR(512),
    Acreage	VARCHAR(512),
    TaxDistrict	VARCHAR(512),
    LandValue	VARCHAR(512),
    BuildingValue	VARCHAR(512),
    TotalValue	VARCHAR(512),
    YearBuilt	VARCHAR(512),
    Bedrooms	VARCHAR(512),
    FullBath	VARCHAR(512),
    HalfBath 	VARCHAR(512)
);

select *
from tablename;

SHOW VARIABLES LIKE 'secure_file_priv';
-- edit my. file in C:\ProgramData\MySQL\MySQL Server 8.0 and give permission for: secure-file-priv=""

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Nashville Housing Data for Data Cleaning.csv' 
INTO TABLE tablename 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

select *
from nashville_house_data;

describe nashville_house_data;

-- Standardize Date Format

ALTER TABLE nashville_house_data
ADD COLUMN SaleDate_Formatted DATE;

UPDATE nashville_house_data
SET SaleDate_Formatted = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d');

-- SELECT 
--    SaleDate, 
--    DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d') AS SaleDate_Formatted 
-- FROM nashville_house_data; -- this have been altered in table

describe nashville_house_data;

-- Populate Property Address data

SELECT 
    ParcelID, 
    COUNT(*) AS DuplicateCount
FROM nashville_house_data
GROUP BY ParcelID
HAVING COUNT(*) > 1;

select PropertyAddress, 
from nashville_house_data