/*
Cleaning Data in SQL Queries */
Select *
From PortfolioProject.dbo.NashvilleHousing



--Standardize Date Format
--look at the time data and see that it has time at the end so trying to remove the time and just get the date 
Select SaleDateConverted, CONVERT (Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing
-- this one does work some time and may not work sometime so use alter then update it and run the original query
--Update NashvilleHousing 
--SET SaleDate = CONVERT (Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT (Date, SaleDate)

--Populate Property Address Data 
Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null 
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b. ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
 From PortfolioProject.dbo.NashvilleHousing a
 Join PortfolioProject.dbo.NashvilleHousing b
	 on a. ParcelID=b. ParcelID
	 And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
 From PortfolioProject.dbo.NashvilleHousing a
 Join PortfolioProject.dbo.NashvilleHousing b
	 on a. ParcelID=b. ParcelID
	 And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Breaking out Address into individual Columns(Address, City, State)
--delimiter or separator over here is comma
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID


--charindex is specifying the positon and doing -1 gives the value without the comma sign
--its going to the commma then going 1 back to the comma
Select 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,---1 removes the comma sign after the data 
SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address--+1 removes the comma sign before the data 
From PortfolioProject.dbo.NashvilleHousing

Alter TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertysplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 
 

Select *
From PortfolioProject.dbo.NashvilleHousing

--looking at the owner address
--it contains city and state all in one column
--trying to separete using easier method ie parsename
--Parsename does the thing in backward than we expect 
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

--with this it gives back state , as Parsename works backward
Select 
Parsename(Replace (OwnerAddress,',','.'),3)
,Parsename(Replace (OwnerAddress,',','.'),2)
,Parsename(Replace (OwnerAddress,',','.'),1) 
From PortfolioProject.dbo.NashvilleHousing

Alter TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace (OwnerAddress,',','.'),3)

Alter TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = Parsename(Replace (OwnerAddress,',','.'),2)

Alter TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename(Replace (OwnerAddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing

--Change Y and N to YEs and no in "Solid as Vacant" Field
Select DISTINCT(SoldAsVacant), count( SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant='Y' THEN 'YES'
       When SoldAsVacant='N' THEN 'NO'
	   Else SOldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update NashVilleHousing
SET SoldAsVacant = CASE When SoldAsVacant='Y' THEN 'YES'
       When SoldAsVacant='N' THEN 'NO'
	   Else SOldAsVacant
	   END

--Remove Duplicates 
--look more into rank and rank number,row number
--these are basically duplicates that we need to delete them
WITH RowNumCTE AS (
Select *, 
 ROW_NUMBER() OVER (
 Partition by ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER By 
				  UniqueID
				  )row_num
From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num >1
--Order by PropertyAddress
--so there are 104 duplicates in here so we need to delete them
--use this statement with CTE to delete

Delete
From RowNumCTE
Where row_num >1--got rid of the duplicates

-- Delete unused Columns
Select *
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress,TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate


--