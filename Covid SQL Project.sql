Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY location,date

--Select *
--FROM PortfolioProject..CovidVaccination
--ORDER BY location,date

--Select data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY location, date

-- Looking at total case vs total deaths (likelihood to die if you contract the disease in Indo)
SELECT Location, date, total_cases, total_deaths, ((CONVERT(float, total_deaths))/(CONVERT(float, total_cases)))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Indonesia%' and continent is not NULL
ORDER BY location, date

--Total cases vs Population (percentage of pop have afflicted by covid)
SELECT Location, date, population, total_cases, ((CONVERT(float, total_cases))/(CONVERT(float, population)))*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Indonesia%' and continent is not NULL
ORDER BY location, date

--Countries with highest percentage got infected
SELECT Location, population, MAX(total_cases) as HighestCount, ((CONVERT(float, MAX(total_cases)))/(CONVERT(float, population)))*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY InfectedPercentage desc

--Countries with highest death percentage
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeaths desc

--Group by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths
Where continent is NULL and location not like '%income%'
Group BY location
Order BY TotalDeaths desc

--Global numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(NULLIF(new_cases, 0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY date

-- POP that has been vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVacCount

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY location, date

With POPvsVAC (Continent, Location, Date, Population, NewVaccination, RollingVacCount)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVacCount

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
)

SELECT *, (RollingVacCount/Population)*100
FROM POPvsVAC

CREATE VIEW PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVacCount

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
