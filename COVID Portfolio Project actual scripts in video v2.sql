SELECT * FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 3,4


SELECT * FROM [dbo].[CovidVaccinations]
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Total Cases vs Population 
-- Shows what percentage of population infected with Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [dbo].[CovidDeaths]
WHERE location like '%states%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [dbo].[CovidDeaths]
GROUP BY Location,  population
ORDER BY PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT   SUM(new_cases) as total_cases ,SUM(CAST(new_deaths as int)) as total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as Deathpercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
where continent is not null
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,population,new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [dbo].[CovidVaccinations] dea
	JOIN [dbo].[CovidDeaths] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(select dea.continent,dea.location,dea.date,population,new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [dbo].[CovidVaccinations] dea
	JOIN [dbo].[CovidDeaths] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *,(RollingPeopleVaccinated/population)*100 FROM PopvsVac

-- Temp table
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,population,new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [dbo].[CovidVaccinations] dea
	JOIN [dbo].[CovidDeaths] vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT *,(RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,population,new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [dbo].[CovidVaccinations] dea
	JOIN [dbo].[CovidDeaths] vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated