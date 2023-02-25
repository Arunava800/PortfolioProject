SELECT * FROM portfolioproject..CovidDeaths$;
--SELECT * FROM portfolioproject..CovidVaccinations$;

SELECT location,date,total_cases, new_cases, total_deaths, population
FROM portfolioproject..CovidDeaths$
ORDER BY 1,2;

--Total cases vs Total Deaths
SELECT location,date,total_cases,  total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM portfolioproject..CovidDeaths$
WHERE location = 'India'
ORDER BY 1,2;

--Total cases vs Population
SELECT location,date,total_cases,  population, (total_cases/population)*100 as case_percent
FROM portfolioproject..CovidDeaths$
WHERE location = 'India'
ORDER BY 1,2;


--Countries with Highest Infection rate Vs Population

SELECT location,MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population)*100)  as population_infected
FROM portfolioproject..CovidDeaths$
GROUP BY location, population
ORDER BY population_infected desc;

-- Highest Death count per population
SELECT location,MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM portfolioproject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc;

-- Visualization with continent
SELECT continent,MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM portfolioproject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc;

-- Global Numbers
SELECT date,SUM(new_cases) as total_cases,
SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS total_deaths
FROM portfolioproject..CovidDeaths$
WHERE continent is not null and 
new_cases is not null
GROUP BY date
ORDER BY 1,2;

--Total cases vs total deaths all over the world
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) AS total_deaths,
SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS deaths_percentage
FROM portfolioproject..CovidDeaths$
WHERE continent is not null and 
new_cases is not null
ORDER BY 1,2;

--COVID VACCINATIONS TABLES
 SELECT * FROM portfolioproject..CovidDeaths$ dea
 JOIN portfolioproject..CovidVaccinations$ vac ON
 dea.location = vac.location and dea.date = vac.date;

 --TOTAL POPULATION VS VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population,dea.new_vaccinations,
SUM(CAST(dea.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS
RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths$ dea JOIN portfolioproject..CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null and dea.new_vaccinations is not null
ORDER BY 1,2,3;

--USING CTE
WITH PopVsVac(continent, location, date, population,New_vaccinations,RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population,dea.new_vaccinations,
SUM(CAST(dea.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS
RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths$ dea JOIN portfolioproject..CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null and dea.new_vaccinations is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPeopleVaccinated
(Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,dea.new_vaccinations,
SUM(CAST(dea.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS
RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths$ dea JOIN portfolioproject..CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null and dea.new_vaccinations is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPeopleVaccinated;


CREATE VIEW PercentPopulationVaccinatedUS AS
SELECT dea.continent, dea.location, dea.date, dea.population,dea.new_vaccinations,
SUM(CAST(dea.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS
RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths$ dea JOIN portfolioproject..CovidVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null;


