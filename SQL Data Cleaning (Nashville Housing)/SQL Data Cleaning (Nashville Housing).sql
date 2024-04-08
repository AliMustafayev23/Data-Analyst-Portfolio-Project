/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing..NashvilleHousingData

-- Standardize Date Format

Select SaleDate ,CONVERT(Date,SaleDate)
From NashvilleHousing..NashvilleHousingData

Update NashvilleHousing..NashvilleHousingData
SET SaleDate=CONVERT(Date,SaleDate)

Select SaleDate
From NashvilleHousing..NashvilleHousingData

-- If it doesn't Update properly

Alter Table NashvilleHousing..NashvilleHousingData
Add SalesDateConverted Date

Update NashvilleHousing..NashvilleHousingData
SET SalesDateConverted = CONVERT(Date,SaleDate)

Select SalesDateConverted,CONVERT(Date,SaleDate)
From NashvilleHousing..NashvilleHousingData

-- Populate Property Address data

Select PropertyAddress
From NashvilleHousing..NashvilleHousingData

Select a.ParcelId,a.PropertyAddress,b.ParcelID,b.PropertyAddress,IsNull (a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing..NashvilleHousingData as a
Join NashvilleHousing..NashvilleHousingData as b
On a.ParcelID=b.ParcelID And a.[UniqueID ]<>b.[UniqueID ]

Update a
SET PropertyAddress=IsNull (a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing..NashvilleHousingData as a
Join NashvilleHousing..NashvilleHousingData as b
On a.ParcelID=b.ParcelID And a.[UniqueID ]<>b.[UniqueID ]

Select *
From NashvilleHousing..NashvilleHousingData
Where PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing..NashvilleHousingData

Select 
Substring(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1)) as Address,
SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1),LEN(PropertyAddress)) as Address
From NashvilleHousing..NashvilleHousingData

ALTER TABLE NashvilleHousing..NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing..NashvilleHousingData
Set PropertySplitAddress =Substring(PropertyAddress,1,(CHARINDEX(',',PropertyAddress)-1))

Select PropertyAddress,PropertySplitAddress
From NashvilleHousing..NashvilleHousingData

ALTER TABLE NashvilleHousing..NashvilleHousingData
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing..NashvilleHousingData
SET PropertySplitCity=SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1),LEN(PropertyAddress))

Select PropertyAddress,PropertySplitAddress,PropertySplitCity
From NashvilleHousing..NashvilleHousingData

Select OwnerAddress,
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
From NashvilleHousing..NashvilleHousingData

ALTER TABLE NashvilleHousing..NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing..NashvilleHousingData
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing..NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing..NashvilleHousingData
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing..NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing..NashvilleHousingData
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1)

Select OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
From NashvilleHousing..NashvilleHousingData

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing..NashvilleHousingData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case
When SoldAsVacant='Y' Then 'Yes'
When SoldAsVacant='N' Then 'No'
Else SoldAsVacant
End 
From NashvilleHousing..NashvilleHousingData

Update NashvilleHousing..NashvilleHousingData
Set SoldAsVacant = Case
When SoldAsVacant='Y' Then 'Yes'
When SoldAsVacant='N' Then 'No'
Else SoldAsVacant
End 

Select SoldAsVacant
From NashvilleHousing..NashvilleHousingData
Where SoldAsVacant in ('Y','N')

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing..NashvilleHousingData
Group by SoldAsVacant
Order by 2

-- Remove Duplicates

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

From NashvilleHousing..NashvilleHousingData
)
Select *
From RowNumCTE
Where row_num > 1 
Order by PropertyAddress

