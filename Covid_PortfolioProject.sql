/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM Covid_Deaths
WHERE continent is not null 
ORDER BY 3,4


-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths
WHERE continent is not null 
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths as FLOAT)/CAST(total_cases as FLOAT))*100 as DeathPercentage
FROM Covid_Deaths
WHERE location like 'India'
and continent is not null 
ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths as FLOAT)/CAST(total_cases as FLOAT))*100 as DeathPercentage
FROM Covid_Deaths
WHERE location like '%states%'
and continent is not null 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (CAST(total_cases as FLOAT)/population)*100 as PercentPopulationInfected
FROM Covid_Deaths
WHERE location like 'India'
ORDER BY 1,2

SELECT Location, date, Population, total_cases,  (CAST(total_cases as FLOAT)/population)*100 as PercentPopulationInfected
FROM Covid_Deaths
WHERE location like '%states%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((CAST(total_cases as FLOAT)/population))*100 as PercentPopulationInfected
FROM Covid_Deaths
WHERE location like 'India'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((CAST(total_cases as FLOAT)/population))*100 as PercentPopulationInfected
FROM Covid_Deaths
WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Covid_Deaths
--Where location like '%states%'
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Covid_Deaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(New_Cases)*100 as DeathPercentage
FROM Covid_Deaths
WHERE continent is not null 
order by 1,2


-- Total Population vs Vaccinations
-- Shows the Rolling Sum of Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


-- Use CTE

WITH RpcVSPop (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM RpcVSPop


-- TEMP Table

DROP TABLE if exists #temp_table
CREATE TABLE #temp_table (
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)


INSERT INTO #temp_table
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent is not null 
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #temp_table


-- Creating View

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY 2,3


SELECT * FROM PercentPopulationVaccinated
