USE [Portfolio Project]
GO


SELECT * FROM CovidDeaths$ ORDER BY 3,4



--SELECT Data to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$ ORDER BY 1,2

-- Total cases X total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE location LIKE 'Spain'
ORDER BY 1,2

-- Looking at cases x population (Percentage of the population affected)
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM CovidDeaths$
WHERE location LIKE 'Spain'
ORDER BY 1,2

--Highest Infection Rate by Population

SELECT location, MAX(total_cases) as HighesInfectionCount, population, MAX(total_cases/population)*100 as InfectedPercentage
FROM CovidDeaths$
--WHERE location LIKE 'Spain'
GROUP BY location, population
ORDER BY 4 DESC;

-- Highest Death Count and Population

SELECT location, MAX(cast(total_deaths AS INT)) AS HighesDeathCount, population, MAX(total_deaths/population)*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY 2 desc;

-- Highest Death Count By  Continent

SELECT continent, MAX(cast(total_deaths AS INT)) AS HighesDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY 2 desc;

-- Global Numbers

SELECT  SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
--GROUP BY  date
--ORDER BY 3 DESC

--Total population x vacination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION by dea.location ORDER BY dea.location, dea.date) AS Daily_VAC
FROM CovidDeaths$ dea
JOIN [dbo].[CovidVaccinations$] vac ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE

WITH PopvsVac (continent,location, date, population, New_Vaccinations, RollingPeopleVaccinated) as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null)

SELECT *, (RollingPeopleVaccinated/population)*100 FROM PopvsVac

--TEMP Table CREATION
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric,new_vaccinations numeric,  RollingPeopleVaccinated numeric)
INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population) *100 FROM #PercentagePopulationVaccinated

-- CREATE VIEWS FOR LATER VISUALIZATION

CREATE VIEW PercentagePopulationVaccinated AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN dbo.CovidVaccinations$ vac ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null