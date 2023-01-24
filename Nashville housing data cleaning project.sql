select * 
from PortfolioProject.dbo.NashvilleHousing

-- Changing the date format

select sale_date_converted, CONVERT(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashvilleHousing
add sale_date_converted date;

update NashvilleHousing
set sale_date_converted = CONVERT(date, SaleDate)



-- populate Property Address



select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking Address into individual columns (Address, City, State)



select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
, SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add property_address nvarchar(255);

update NashvilleHousing
set property_address = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table NashvilleHousing
add property_city nvarchar(255);

update NashvilleHousing
set property_city = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 



select *
from PortfolioProject.dbo.NashvilleHousing



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select
PARSENAME(replace(OwnerAddress, ',', '.'),3) -- for address
,PARSENAME(replace(OwnerAddress, ',', '.'), 2) -- for city
,PARSENAME(replace(OwnerAddress, ',', '.'), 1)  -- for state
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add owner_address nvarchar(255);

update NashvilleHousing
set owner_address = PARSENAME(replace(OwnerAddress, ',', '.'),3)


alter table NashvilleHousing
add owner_city nvarchar(255);

update NashvilleHousing
set owner_city = PARSENAME(replace(OwnerAddress, ',', '.'),2)


alter table NashvilleHousing
add owner_state nvarchar(255);

update NashvilleHousing
set owner_state = PARSENAME(replace(OwnerAddress, ',', '.'),1)




-- Change the Y and N in Sold as Vacant column to YES and NO



select distinct SoldAsVacant, COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by COUNT(SoldAsVacant)


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing 
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end



-- Removing Duplicates
-- by using CTE


with row_num_cte as(
select *,
     ROW_NUMBER() over(
	 partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  order by 
				      UniqueID
					  ) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
from row_num_cte
where row_num > 1
order by PropertyAddress



with row_num_cte as(
select *,
     ROW_NUMBER() over(
	 partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  order by 
				      UniqueID
					  ) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
delete 
from row_num_cte
where row_num > 1
--order by PropertyAddress




-- Deleting Unused Columns


select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate



