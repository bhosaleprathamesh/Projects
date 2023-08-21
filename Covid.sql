SELECT *
FROM Project.dbo.CovidDeaths
where continent is not null 
ORDER BY 3, 4

SELECT *
FROM Project.dbo.CovidVaccinations 
ORDER BY 3, 4

--Data used
EXEC sp_help 'dbo.CovidDeaths';
ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_deaths decimal

--World's Death Percentage per Country
--total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM Project.dbo.CovidDeaths
--WHERE location = 'India'
ORDER BY 1,2

--total cases vs population
--% of population that got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as AffectedPopulationPercentage
FROM Project.dbo.CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as AffectedPopulationPercentage
FROM Project.dbo.CovidDeaths
--WHERE location = 'India'
GROUP BY location, population
ORDER BY AffectedPopulationPercentage desc

--Death Count Countries
SELECT location,MAX(total_deaths) as TotalDeathCount
FROM Project.dbo.CovidDeaths
--WHERE location = 'India'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Death Count Continent
SELECT continent,SUM(total_deaths) as TotalDeathCount
FROM Project.dbo.CovidDeaths
--WHERE location = 'India'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths
FROM Project.dbo.CovidDeaths
where continent is not null
Group By date
order by 1,2

--Total population vs vaccinations
--Joining both tables
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date, dea.location) as TotalVac
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Order by 2,3

--CTE
With PopvsVac (continent, location, date, population, new_vaccinations, TotalVac)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date, dea.location) as TotalVac
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'India'
--Order by 2,3
)
Select *, (TotalVac/population)*100
From PopvsVac
order by 2,3