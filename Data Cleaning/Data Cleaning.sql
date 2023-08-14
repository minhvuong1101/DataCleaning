
-- Standardize Date Format
select SaleDate, CONVERT(date, SaleDate)
from NashvilleHousing

alter table NashvilleHousing
alter column SaleDate date

-- Populate Property Address data
select 
	a.ParcelID, a.PropertyAddress, 
	b.ParcelID, b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
on a.ParcelID = b. ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
on a.ParcelID = b. ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) 

select 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Change Y and N to Yes and No in "Sold As Vacant" field
SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Remove duplicate
SELECT DISTINCT *
INTO duplicate_table
FROM NashvilleHousing
WHERE [UniqueID ] IN (
    SELECT [UniqueID ]
    FROM NashvilleHousing
    GROUP BY [UniqueID ]
    HAVING COUNT([UniqueID ]) > 1
);

DELETE FROM NashvilleHousing
WHERE [UniqueID ] IN (
    SELECT [UniqueID ]
    FROM duplicate_table
);

INSERT INTO NashvilleHousing
SELECT *
FROM duplicate_table;

DROP TABLE duplicate_table;

-- Delete unused column
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


