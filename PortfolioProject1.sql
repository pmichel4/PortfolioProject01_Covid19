Select *
FROM portfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4


--Select the data that we are going to be using

--Select Location, date, total_cases, new_cases, total_deaths, population
--From portfolioProject..CovidDeaths
--Order By 1,2




--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country


--select location, date, total_cases, total_deaths, (cast(total_deaths as bigint))/cast(total_cases as bigint)*100 as deathpercentage
FROM portfolioproject..coviddeaths
WHERE total_deaths IS NOT NULL 
	AND total_cases IS NOT NULL
	AND location like '%states%'
	order by 1,2


-- looking at total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as Infectionpercentage
FROM portfolioproject..coviddeaths
WHERE total_deaths IS NOT NULL 
	AND total_cases IS NOT NULL
	--AND location like '%spain%'
	order by 1,2


--Looking at countries with Hightes Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfolioproject..coviddeaths
WHERE total_deaths IS NOT NULL 
	AND total_cases IS NOT NULL
	--AND location like '%spain%'
Group By Location, Population
Order by PercentPopulationInfected desc


--Showing Countries with the hightest Death count per population
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioproject..coviddeaths
WHERE continent is not null
	AND total_deaths IS NOT NULL 
	AND total_cases IS NOT NULL
	--AND location like '%spain%'
Group By Location
Order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT

--Showing the continents with the highest death count
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM portfolioproject..coviddeaths
WHERE continent is null
	--AND total_deaths IS NOT NULL 
	--AND total_cases IS NOT NULL
	--AND location like '%spain%'
Group By location
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
AND new_deaths!=0
AND new_cases!=0
--GROUP BY date
ORDER BY 1,2




-- looking at total population vs vaccinaation 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN portfolioproject..Covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


--USE CTE

With PopvsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN portfolioproject..Covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac
Order By 2,3



--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN portfolioproject..Covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

CREATE VIEW		PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN portfolioproject..Covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated