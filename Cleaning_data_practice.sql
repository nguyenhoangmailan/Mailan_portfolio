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

-- Find the duplicate ID

SELECT 
    ParcelID, 
    COUNT(*) AS DuplicateCount
FROM nashville_house_data
GROUP BY ParcelID
HAVING COUNT(*) > 1;

select LegalReference
from nashville_house_data
order by substr(LegalReference, -3);

select *
from nashville_house_data;

-- Breaking out Address into 3 columns: Address, City, State

select 
	substring(PropertyAddress, 1, instr(PropertyAddress, ',') -1 ) as Address
,	substring(PropertyAddress, instr(PropertyAddress, ',' ) +1 , length(PropertyAddress) ) as Address
from nashville_house_data;

alter table nashville_house_data
add PropertySplitAddress nvarchar(255);

update nashville_house_data
set PropertySplitAddress = substring(PropertyAddress, 1, instr(PropertyAddress, ',') -1 );

alter table nashville_house_data
add PropertySplitCity nvarchar(255);

update nashville_house_data
set PropertySplitCity = substring(PropertyAddress, instr(PropertyAddress, ',' ) +1 , length(PropertyAddress) ); 

select OwnerAddress
from nashville_house_data;

select 
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1) AS Street,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1) AS City,
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1) AS State
from nashville_house_data;
    
alter table nashville_house_data
add OwnerSplitAddress nvarchar(255);

update nashville_house_data
set OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1);

alter table nashville_house_data
add OwnerSplitCity nvarchar(255);

update nashville_house_data
set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1); 
    
alter table nashville_house_data
add OwnerSplitState nvarchar(255);

update nashville_house_data
set OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1); 

select *
from nashville_house_data;

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct SoldAsVacant, count(SoldAsVacant)
from nashville_house_data
group by SoldAsVacant
order by 2;

select distinct SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
         else SoldAsVacant
         end
from nashville_house_data;

update nashville_house_data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
         else SoldAsVacant
         end;

-- Remove Duplicates

with RowNumCTE as (
select
	row_number() over (
    partition by ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate_Formatted,
				 LegalReference
                 order by UniqueID
						) as row_num,
                    nashville_house_data.*
from nashville_house_data
)
DELETE FROM nashville_house_data 
WHERE UniqueID IN ( -- CTE is read-only => cannot directly use DELETE
    SELECT UniqueID FROM RowNumCTE WHERE row_num > 1
);

select *
from nashville_house_data;

-- Delete unused Columns

ALTER TABLE nashville_house_data
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

ALTER TABLE nashville_house_data
DROP COLUMN SaleDate;