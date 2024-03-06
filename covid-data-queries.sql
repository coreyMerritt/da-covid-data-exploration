-- The visualization that goes along with this can be found here:    https://public.tableau.com/app/profile/corey.merritt5468/viz/COVIDData_17090071351950/Dashboard
-- Thanks for your time!

-- All data in covid_deaths.
SELECT *
FROM covid_information..covid_deaths
ORDER BY 4;

-- All data in covid_vaccinations.
SELECT *
FROM covid_information..covid_vaccinations
ORDER BY 3, 4;

-- All data in both tables.
SELECT *
FROM covid_information..covid_deaths dea
JOIN covid_information..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

-- Likelihood that one will die if they contract COVID in the United States over various points in time.
CREATE VIEW united_states_death_percentage AS
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases) * 100, 2) AS death_percentage
FROM covid_information..covid_deaths
WHERE location = 'United States' AND total_deaths IS NOT NULL;
--ORDER BY 1, 2

-- Percentage of the population that has had COVID in the United States over various points in time.
CREATE VIEW united_states_infection_percentage AS
SELECT location, date, population, total_cases, ROUND((total_cases / population) * 100, 2) AS infection_percentage
FROM covid_information..covid_deaths
WHERE location = 'United States';
--ORDER BY 1, 2

-- Countries with the highest infection rate relative to the population.
CREATE VIEW infection_rate_by_country AS
SELECT location, population, MAX(total_cases) AS highest_infection_count, ROUND(MAX((total_cases / population) * 100), 2) AS infection_percentage
FROM covid_information..covid_deaths
GROUP BY location, population;
-- ORDER BY infection_percentage DESC

-- Countries with the highest death rate relative to the population.
CREATE VIEW death_rate_by_country AS
SELECT location, population, MAX(total_deaths) AS highest_death_count, ROUND(MAX((total_deaths / population) * 100), 2) AS death_percentage
FROM covid_information..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY death_percentage DESC;

-- Deaths by continent.
SELECT continent, MAX(total_deaths) AS highest_death_count
FROM covid_information..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;

-- Global death percentage week by week.
SELECT date, 
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths, 
	SUM(new_deaths) / SUM(new_cases) * 100 AS death_percentage
FROM covid_information..covid_deaths
WHERE continent IS NOT NULL AND new_cases != 0
GROUP BY date
ORDER BY 1, 2;

-- Global death percentage as of 2024-02-10.
SELECT SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths, 
	SUM(new_deaths) / SUM(new_cases) * 100 AS death_percentage
FROM covid_information..covid_deaths
WHERE continent IS NOT NULL AND new_cases != 0
ORDER BY 1, 2;

-- Shows the date that new vaccinations happened, how many people are vaccinated, and the percentage vaccinated by country.
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS (
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_information..covid_deaths dea
JOIN covid_information..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (rolling_people_vaccinated / population) * 100 AS percentage_vaccinated
FROM pop_vs_vac;


CREATE VIEW rolling_vaccinations AS
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_information..covid_deaths dea
JOIN covid_information..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
