/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
SELECT * FROM covid_deaths LIMIT 20;
SELECT * FROM covid_vaccinations LIMIT 20;

-- Total Deaths vs Total Cases
-- Shows likelihood of dying if you contract covid in your country
SELECT 
	date, 
	total_cases, 
	total_deaths,
	ROUND(total_deaths / total_cases * 100.0, 2) AS death_rate
FROM covid_deaths
WHERE location = 'Indonesia'
ORDER BY 1;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT
	date,
	total_cases,
	population,
	ROUND(total_cases / population * 100.0, 2) AS infection_rate
FROM covid_deaths
WHERE location = 'Indonesia'
ORDER BY 1;


-- Countries with Highest Infection Rate compared to Population
SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	ROUND(MAX(total_cases/population) * 100.0, 2) AS population_infection_rate
FROM covid_deaths
GROUP BY 1, 2
HAVING MAX(total_cases/population) IS NOT NULL
ORDER BY 4 DESC;


-- Countries with Highest Death Count per Population
SELECT
	location,
	MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY 1
HAVING MAX(total_deaths/population) IS NOT NULL
ORDER BY 2 DESC;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
SELECT
	continent,
	SUM(new_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- GLOBAL NUMBERS
SELECT
	date,
	SUM(new_cases) AS global_new_cases,
	SUM(new_deaths) AS global_new_deaths,
	ROUND(SUM(new_deaths) / SUM(new_cases) * 100.0, 2) AS global_death_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT 
	cd.location, 
	cd.date,
	cd.population, 
	cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER(PARTITION by cd.location ORDER BY cd.location, cd.date) AS running_total_vaccinations
FROM covid_deaths cd 
	JOIN covid_vaccinations cv 
		ON cd.location = cv.location
			AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2;

-- Using CTE to perform Calculation on Partition By in previous query
WITH running_vac_total AS (
	SELECT 
		cd.location, 
		cd.date,
		cd.population, 
		cv.new_vaccinations,
		SUM(cv.new_vaccinations) OVER(PARTITION by cd.location ORDER BY cd.location, cd.date) AS running_total_vaccinations
	FROM covid_deaths cd 
		JOIN covid_vaccinations cv 
			ON cd.location = cv.location
				AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	ORDER BY 1,2
) SELECT
	location,
	date,
	population,
	running_total_vaccinations,
	ROUND(running_total_vaccinations/population * 100.0, 2) AS running_pct_vaccinations
FROM running_vac_total;

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
	continent varchar,
	location varchar,
	date date,
	population numeric,
	new_vaccinations numeric,
	running_total_vaccinations numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT 
	cd.continent,
	cd.location, 
	cd.date,
	cd.population, 
	cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER(PARTITION by cd.location ORDER BY cd.location, cd.date) AS running_total_vaccinations
FROM covid_deaths cd 
	JOIN covid_vaccinations cv 
		ON cd.location = cv.location
			AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3;

SELECT *, ROUND(running_total_vaccinations/population*100.0,2) AS running_pct_vaccinations
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW pct_population_vaccinated AS (
	SELECT 
	cd.continent,
	cd.location, 
	cd.date,
	cd.population, 
	cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER(PARTITION by cd.location ORDER BY cd.location, cd.date) AS running_total_vaccinations
FROM covid_deaths cd 
	JOIN covid_vaccinations cv 
		ON cd.location = cv.location
			AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3
);