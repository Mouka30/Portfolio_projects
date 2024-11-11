SELECT *
FROM PortfolioProject..CovidDeaths
Order By 3, 4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order By 3, 4

---Select Data I will need

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order By 1, 2

--- Check Total Cases Vs Tota Deaths in BENIN
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%enin%'
Order By 5 DESC

---Likelihood of dying of Covid in Africa
SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_likelihood
FROM PortfolioProject..CovidDeaths
WHERE continent LIKE '%frica%'
ORDER BY 5 DESC


---Total Cases vs POpulation 
--Shows what percentage of the African population got Covid
SELECT continent, date, total_cases, population, (total_cases/population)*100 infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent LIKE '%frica%'
ORDER BY 5 DESC
--Countries with Higher infection rate
SELECT location, MAX(total_cases) highest_infection_count, population, MAX((total_cases/population)*100) max_infection_rate
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY 4 DESC

--Countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as INT)) highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
group by location
order by 2 desc

--Break Things Down By continent
SELECT continent, MAX(CAST(total_deaths AS INT))highest_death_count_by_continent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--Global Numbers
SELECT 
    date, 
    SUM(new_cases) AS sum_new_cases, 
    SUM(CAST(new_deaths AS INT)) AS casted_new_deaths, 
    (SUM(new_cases) / NULLIF(SUM(CAST(new_deaths AS INT)), 0)) * 100 AS global_death_percentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    date, sum_new_cases;

	--Total Population VS Vaccinations
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated,
    (SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) / dea.population) * 100 AS percentage_rolling_people_vaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac 
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    dea.location, dea.date;

	--USE CTE
WITH POPvsVAC AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac 
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)

SELECT *,(rolling_people_vaccinated/population) *100
FROM 
    POPvsVAC



	--TEMP Table
DROP TABLE if EXISTS #percent_population_vaccinated
	CREATE TABLE #percent_population_vaccinated
	(
	Continent nvarchar (255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
	)
INSERT INTO #percent_population_vaccinated
	SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac 
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL

SELECT *,(rolling_people_vaccinated/population) *100
FROM #percent_population_vaccinated


--Create View to store data for later visualizations
DROP VIEW IF EXISTS percent_population_vaccinated;
GO

CREATE VIEW percent_population_vaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac 
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;
GO
