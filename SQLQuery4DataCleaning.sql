---------------Data Cleaning in SQL 



SELECT * 
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format 


SELECT SaleDateConverted, CONVERT(Date, SaleDate) As SaleDate
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,Saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate)


-- Populate Property Address data ---------

Select *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

----- creating self joins within the data set, based on parcelID, and that unique ID has to be different, on property addresses that is NULL. 
------ ISNULL(a.PropertyAddress, b.propertyAddress) is checking if a.PropertyAddress is null, if it is, replace it with b. property.  

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b 
on a.ParcelID = b.ParcelID 
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null 

------ Breaking out Address into Individual Columns (Address, City, State) 
SELECT * 
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, --- -1 here is to drop the comma in the 19th position as the comma is on the 19th position. 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address  
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-------------------- Another method--------------------- 
SELECT OwnerAddress 
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

---------------- Change Y and N to Yes and no in "Sold as Vacant" field ---------------

Select Distinct(SoldASVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
FROM PortfolioProject..NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
FROM PortfolioProject..NashvilleHousing

--- Remove Duplicates -----------
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing
--order by ParcelID 
)
SELECT * 
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing
--order by ParcelID 
)
DELETE 
FROM RowNumCTE 
WHERE row_num > 1
--ORDER BY PropertyAddress 

-- Delete Unused Columns 
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate