--Cleaning Data Project

SELECT *
FROM PortfolioProject..NashvilleHousing

--Standardize Date Format


Select SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

--Make entire new column
ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

--Change Column datatype
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date


--Populate Property Address data

-- Replace NULL PropertyAddress using ParcelID (they have the same address)
Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL

SELECT *
FROM PortfolioProject..NashvilleHousing
Where PropertyAddress is NULL


--Breaking out Address into individual Columns (Address, City, State)


--Split the address with comma delimiter
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Ville
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add SplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
add SplitCity nvarchar(255)

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Split sentence with period(.) delimiter
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--CHANGE Y AND N TO YES AND NO IN "Sold as Vacant" Field



Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
	 WHEN SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
					 WHEN SoldAsVacant = 'N' Then 'No'
					 ELSE SoldAsVacant
					 END

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing


--REMOVE DUPLICATE

WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress,
							SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as row_num
FROM NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--DELETE
--FROM RowNumCTE
--WHERE row_num > 1


--DELETE UNUSED COLUMN


SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate