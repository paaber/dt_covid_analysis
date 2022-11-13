create view covid_death_ as 
SELECT iso_code, NULLIF(continent,'') as continent, location, convert(date,[date]) as date, population, total_cases, new_cases, new_cases_smoothed, 
total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million, 
total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million, reproduction_rate, icu_patients, 
icu_patients_per_million, hosp_patients, hosp_patients_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million, 
weekly_hosp_admissions, weekly_hosp_admissions_per_million
FROM dt_analysis..covid_deaths


create view covid_vacinations_ as
SELECT iso_code,  NULLIF(continent,'') as continent, location,  convert(date,[date]) as date, total_tests, new_tests, total_tests_per_thousand, new_tests_per_thousand, new_tests_smoothed, 
new_tests_smoothed_per_thousand, positive_rate, tests_per_case, tests_units, total_vaccinations, people_vaccinated, people_fully_vaccinated, 
total_boosters, new_vaccinations, new_vaccinations_smoothed, total_vaccinations_per_hundred, people_vaccinated_per_hundred, 
people_fully_vaccinated_per_hundred, total_boosters_per_hundred, new_vaccinations_smoothed_per_million, new_people_vaccinated_smoothed,
new_people_vaccinated_smoothed_per_hundred, stringency_index, population_density, median_age, aged_65_older, aged_70_older,
gdp_per_capita, extreme_poverty, cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities,
hospital_beds_per_thousand, life_expectancy, human_development_index, excess_mortality_cumulative_absolute, excess_mortality_cumulative, 
excess_mortality, excess_mortality_cumulative_per_million
FROM dt_analysis..covid_vacinations;



SELECT  location,date,total_cases,total_deaths,population from covid_death_
where continent is not null
order by 1,2

--SELECT * from cd
--order by 3,4;
--
--SELECT * from dt_analysis..covid_vacinations
--order by 3,4

SELECT continent , location,date,total_cases,total_deaths,new_deaths ,population from covid_death_
where continent is not null
order by 1,2,3

-- looking at total cases  vs total deaths
--  shows likelihood of dying if covid is contacted in selected country. 

SELECT  location,date,total_cases,total_deaths,(cast(total_deaths as float) /total_cases) * 100 as death_percentage from covid_death_ cd
where continent is not null
order by 1,2 desc

-- looking at total cases  vs population
--  shows what percentage of population got covid . 
--  likelihood of contacting covid in nigeria

SELECT  location,date,population,total_cases,(cast(total_cases as float) /population) * 100 as affected_percentage from covid_death_ cd
where location like '%nigeria%'
order by 1,2 desc


-- looking at country with highest infection rate compared to pupolation

SELECT  location,population,MAX(total_cases) as highestInfected,MAX((cast(total_cases as float) /population))  * 100 as affected_percentage from covid_death_ cd
where continent is not null
GROUP by location,population
order by affected_percentage DESC 

-- showing continent with highest death count per population.
-- breakig down by continent
SELECT  continent,MAX(total_deaths) as highestDeathCount from covid_death_ cd
where continent is not null
GROUP by continent
order by highestDeathCount DESC 

 
--SELECT  location ,MAX(total_deaths) as highestDeathCount from covid_death_ cd
--where continent is null
--GROUP by location
--order by highestDeathCount DESC 

--global numbers


SELECT date,sum(new_cases) as total_cases,sum(new_deaths) as total_death,(cast(sum(new_deaths) as float) /sum(new_cases)) * 100 as death_percentage 
from covid_death_ cd
where continent is not null
group by date
order by 1,2

--total sum of cases in the world as compared to total death
SELECT sum(new_cases) as total_cases,sum(new_deaths) as total_death,(cast(sum(new_deaths) as float) /sum(new_cases)) * 100 as death_percentage 
from covid_death_ cd
where continent is not null 
order by 1,2

select cd.continent,cd.location, cd.date,cd.population,NULLIF(cv.new_vaccinations,'') as new_vaccinations,
SUM(convert(int,cv.new_vaccinations)) over (partition by cd.location Order by cd.location, cd.date) as rolling_sum_of_vaccination 
FROM covid_death_ cd
join covid_vacinations_ cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3

--using a CTE

with PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingSumOfVaccination)
as (
		select cd.continent,cd.location, cd.date,cd.population,NULLIF(cv.new_vaccinations,'') as new_vaccinations,
		SUM(convert(int,cv.new_vaccinations)) over (partition by cd.location Order by cd.location, cd.date) as rolling_sum_of_vaccination 
		FROM covid_death_ cd
		join covid_vacinations_ cv 
		on cd.location = cv.location
		and cd.date = cv.date
		where cd.continent is not null
--		order by 2,3
		
	)
select *,(RollingSumOfVaccination * 1.0/Population) * 100 as vacinated_population from PopvsVac order by 2,3


--using table

-- total death count by continent

SELECT  cd.location  as Continent , SUM(cd.new_deaths) as TotalDeathCount from covid_death_ cd 
WHERE cd.continent is null and cd.location not in ('International','Low income','European Union','High income', 'Lower middle income','World','Upper middle income')
GROUP BY cd.location ORDER BY cd.location 

SELECT  cd.continent As Continent, SUM(cd.new_deaths) AS TotalDeathCount  from covid_death_ cd 
WHERE cd.continent  is not NULL 
GROUP BY cd.continent ORDER  BY cd.continent 


