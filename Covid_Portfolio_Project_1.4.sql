Select *
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4



-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1,2




-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like 'Greece%'
and continent is not null
order by 1,2




--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population) * 100 as InfectedPercentage
From PortfolioProject1..CovidDeaths
--Where location like 'Greece%'
order by 1,2



-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as 
	PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like 'Greece%'
Group by Location, Population
order by PercentPopulationInfected desc



-- Showing Countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like 'Greece%'
Where continent is not null
Group by Location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY  CONTINENT 



--Showing continents woth the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like 'Greece%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
	as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like 'Greece%'
where continent is not null
--Group by date
order by 1,2



--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location ,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date  = vac.date
where dea.continent is not null
order by 2,3



--USE CTE

With PopvsvVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location ,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date  = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsvVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location ,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date  = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location ,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date  = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated



