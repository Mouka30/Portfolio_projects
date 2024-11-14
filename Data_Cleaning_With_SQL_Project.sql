--Standize SalesDate
Go
SELECT SaleDate
FROM PortfolioProject..Nashville_Housing_Data

Go
ALTER TABLE PortfolioProject..Nashville_Housing_Data
ADD SaleDateConverted Date;

UPDATE PortfolioProject..Nashville_Housing_Data
SET SaleDateConverted = CONVERT(DATE,SaleDate)

--Populate Property Adress Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..Nashville_Housing_Data a
JOIN PortfolioProject..Nashville_Housing_Data b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville_Housing_Data a
JOIN PortfolioProject..Nashville_Housing_Data b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


--Break Address into Individual Columns
SELECT PropertyAddress 
FROM PortfolioProject..Nashville_Housing_Data

SELECT
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject..Nashville_Housing_Data

ALTER TABLE PortfolioProject..Nashville_Housing_Data
ADD PropertySplitAddress NVARCHAR(255);
GO

UPDATE PortfolioProject..Nashville_Housing_Data
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
GO


ALTER TABLE PortfolioProject..Nashville_Housing_Data
ADD PropertySplitCity NVARCHAR(255);
GO
UPDATE PortfolioProject..Nashville_Housing_Data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
GO

--USE PARSENAME to separate OwnerAddress and Add the columns to Nashville Housing Table

SELECT 

PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) City,
PARSENAME(REPLACE(OwnerAddress, '', '.'), 1) State
FROM PortfolioProject..Nashville_Housing_Data


ALTER TABLE PortfolioProject..Nashville_Housing_Data
ADD OwnerSplitAddress NVARCHAR(255);
GO

UPDATE PortfolioProject..Nashville_Housing_Data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
GO


ALTER TABLE PortfolioProject..Nashville_Housing_Data
ADD OwnerSplitCity NVARCHAR(255);
GO
UPDATE PortfolioProject..Nashville_Housing_Data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

GO
ALTER TABLE PortfolioProject..Nashville_Housing_Data
ADD OwnerSplitState NVARCHAR(255);
GO
UPDATE PortfolioProject..Nashville_Housing_Data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, '', '.'), 1)
GO

--Change Y and N to Yes and No in SoldAsVacant Column

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..Nashville_Housing_Data


UPDATE PortfolioProject..Nashville_Housing_Data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Remove Duplicates 
WITH rowNUMCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			 UniqueID
			 ) row_num
FROM PortfolioProject..Nashville_Housing_Data
)
DELETE 
FROM rowNUMCTE
WHERE row_num > 1


--Delete Unused Columns

ALTER TABLE PortfolioProject..Nashville_Housing_Data
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress 

ALTER TABLE PortfolioProject..Nashville_Housing_Data
DROP COLUMN SaleDate