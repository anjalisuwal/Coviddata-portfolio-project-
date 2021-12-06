Select * 
From PortfolioProject..CovidDeaths
WHERE Continent is not null
Order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--select data that we are going to be using 
Select Location,date ,total_cases,new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at the Total Cases VS Total Deaths
--shows the likelihood of dying in United States
Select Location, date, total_cases, total_deaths ,(total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order By 1,2

--looking at the Total Cases Vs total Deaths In Nepal
--shows the likelihood of dying in Nepal
Select Location, date, total_cases, total_deaths ,(total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Nepal'
and continent is not null
Order By 1,2

--Looking at the total cases Vs the population
--Shows what percentage of population has gotten covid
Select Location, date, total_cases, Population ,(total_cases/Population)* 100 as PercentPoulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order By 1,2

--looking at what country has the highest infection rate compare to the population 
Select Location, Population,MAX(total_cases)as HighestInfectionCount,Max((total_cases/population))*100 as PercentPoulationInfected
From PortfolioProject..CovidDeaths 
Where continent is not null
Group by Location,Population
Order by PercentPoulationInfected desc

--showing the country with highest death count per population 
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--breaking things down based on continent 
 Select continent, Max(cast(Total_deaths as bigint)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null 
 Group by continent 
 Order by TotalDeathCount desc

 --this is showing the continent with the highest death count 
 Select continent, Max(cast( total_death as bigint)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group by continent
 Order by TotalDeathCount desc


 --Looking at Global numbers
 Select date , total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 where continent is not null
 Group By date
 order by 1,2 

 --Death percentage all over the world
 Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group By date
Order By 1,2

--Looking ath total populatio vs vaccinations
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 2,3

--Use CTE 
With PopvsVac(Continent,location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)* 100
From PopvsVac

--Temp table
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--creating view to store data for later visualizaations
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated 