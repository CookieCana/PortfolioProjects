SELECT *
FROM PortfolioProject..COVIDDeaths
WHERE continent is not null
Order by 3,4

--SELECT *
--FROM PortfolioProject..COVIDVaccinations
--Order by 3,4

--Select data that we are going to be using - COVID Database

SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..COVIDDeaths
WHERE continent is not null
order by 1,2

--Total Cases vs Total Deaths (per country)
--to show likelihood of dying if you contract COVID 

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..COVIDDeaths
WHERE location = 'Jamaica'
order by 1,2

--Total Cases vs Population
--Percent of Population that contracted Covid
--switched to US as the rates are way higher than Jamaica

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CovidInfectionRate
FROM PortfolioProject..COVIDDeaths
WHERE location = 'United States'
order by 1,2

--Looking at countries with Highest Infection Rate vs Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..COVIDDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Looking at countries with the Highest Death Count per Population
SELECT Location, population, MAX(cast(total_deaths as bigint)) AS TotalDeathCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
  --changed total_deaths as bigint to account for the large number of deaths
FROM PortfolioProject..COVIDDeaths
WHERE continent is not null
GROUP BY location, population
Order by TotalDeathCount desc

-- Percent of the population that died

SELECT Location, population, MAX(cast(total_deaths as bigint)) AS TotalDeathCount, MAX(total_deaths/population)*100 AS TotalPercentDeaths
--changed total_deaths as bigint to account for the large number of deaths
FROM PortfolioProject..COVIDDeaths
WHERE continent is not null
GROUP BY location, population
Order by TotalDeathCount desc


--Seperating by CONTINENT

--Showing Continents with highest death count

SELECT location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..COVIDDeaths
WHERE continent is null
GROUP BY location
Order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2

--Joining both Tables
--Looking at Total Population vs Vaccinations

Select death.continent,death.location,death.date, death.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--order by death and date is used to give a running cumulative total by day
From PortfolioProject..COVIDDeaths death
Join PortfolioProject..COVIDVaccinations vac
   ON death.location=vac.location
   and death.date=vac.date
   where death.continent is not null
order by 2,3

--Using  a CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent,death.location,death.date, death.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--order by death and date is used to give a running cumulative total by day
From PortfolioProject..COVIDDeaths death
Join PortfolioProject..COVIDVaccinations vac
   ON death.location=vac.location
   and death.date=vac.date
   where death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From PopvsVac


--Using a Temp Table

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population  numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select death.continent,death.location,death.date, death.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--order by death and date is used to give a running cumulative total by day
From PortfolioProject..COVIDDeaths death
Join PortfolioProject..COVIDVaccinations vac
   ON death.location=vac.location
   and death.date=vac.date
   where death.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select death.continent,death.location,death.date, death.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--order by death and date is used to give a running cumulative total by day
From PortfolioProject..COVIDDeaths death
Join PortfolioProject..COVIDVaccinations vac
   ON death.location=vac.location
   and death.date=vac.date
   where death.continent is not null

Select *
From PercentPopulationVaccinated