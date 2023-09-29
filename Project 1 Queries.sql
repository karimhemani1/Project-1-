--select *
--FROM CovidDeaths$
--Order by 3,4

select *
From CovidVaccinations$
Where continent is not null
Order by 3,4

--Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Order by 1,2

--Looking at total Cases vs Total Deaths 
--Shows likelihood of dying if you contract covid in your country
--Select location, date, total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
--From CovidDeaths$
--Where location = 'United States'
--Order by 1,2 DESC

--Looking at the total cases vs the population
--Shows what percentage of population got covid
--Select location, date,population, total_cases,total_deaths,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentOfPopulationInfected
--From CovidDeaths$
--Where location = 'United States'
--Order by 1,2 DESC

--Looking at which countries have the highest infection rate compared to population
Select location,population, MAX(total_cases) as HighestInfectionCount , (CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0))*100 as CasesPercentage
From CovidDeaths$
Group by location, population
Order by CasesPercentage DESC

--Looking at which countries have the highest death count compared to population
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount 
From CovidDeaths$
Where continent is not null
Group by location
Order by HighestDeathCount DESC

--Lets break things down by continent
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount 
From CovidDeaths$
Where continent is not null
Group by continent
Order by HighestDeathCount DESC

--Global numbers 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidDeaths$
Where continent is not null
Group by date
Order by 1, 2

--Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
From CovidDeaths$ as dea
Join CovidVaccinations$ as vac
	ON dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
From CovidDeaths$ as dea
Join CovidVaccinations$ as vac
	ON dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table 
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
From CovidDeaths$ as dea
Join CovidVaccinations$ as vac
	ON dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations 

Create View #HighestDeathCount
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount 
From CovidDeaths$
Where continent is not null
Group by location
Order by HighestDeathCount DESC
