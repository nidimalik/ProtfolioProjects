use PortfolioProject

select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--SELECTING DATA WE ARE GOING TO BE USING 

select Location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by Location, date

-- Looking at Total Cases vs Total Deaths
-- Shows the likely hood of dying if someone contracts covid in India

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%India%'
order by Location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select Location, date, population, total_cases, (total_cases/population)*100 as covidpopulation
from PortfolioProject.dbo.CovidDeaths
where location like '%India%'
order by Location, date

-- Looking at the highest infection rate compared to the population

select Location, population, Max(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percent_population_infected
from PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
where continent is not null 
group by Location, population
order by percent_population_infected desc

-- Countries showing the highest death count per population

select Location, Max(cast(total_deaths as int)) as total_death_count
from PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
where continent is not null 
group by Location
order by total_death_count desc

-- Showing continents with highest death rate

select continent, Max(cast(total_deaths as int)) as total_death_count
from PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
where continent is not null 
group by continent
order by total_death_count desc

--select location, Max(cast(total_deaths as int)) as continent_total_death_count
--from PortfolioProject.dbo.CovidDeaths
----where location like '%India%'
--where continent is null 
--group by location
--order by continent_total_death_count desc


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid continent wise

select continent, date, population, total_cases, (total_cases/population)*100 as covidpopulation
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
order by continent, date

-- Looking at the highest infection rate compared to the population by continents

select continent, population, Max(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percent_population_infected
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
group by continent, population
order by percent_population_infected desc

-- Continents showing the highest death count per population

select continent, Max(cast(total_deaths as int)) as total_death_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
group by continent
order by total_death_count desc

-- Global numbers

select date, Sum(new_cases) as all_covid_cases, sum(cast(new_deaths as int)) as all_covid_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as all_deathpercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by date, all_covid_cases

select Sum(new_cases) as all_covid_cases, sum(cast(new_deaths as int)) as all_covid_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as all_deathpercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
where continent is not null
--group by date
order by all_covid_cases


-- Looking at Total Population vs Vaccinations

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, sum(convert(bigint,vaccine.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as rolling_people_vaccinations
from PortfolioProject.dbo.CovidDeaths death
join PortfolioProject.dbo.CovidVaccinations vaccine
    on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
order by death.location, death.date

-- Use CTE(common table expression)

with pop_vs_vac (continent, date, location, population, new_vaccinations, rolling_people_vaccinations)
as 
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, sum(convert(bigint,vaccine.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as rolling_people_vaccinations
from PortfolioProject.dbo.CovidDeaths death
join PortfolioProject.dbo.CovidVaccinations vaccine
    on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by death.location, death.date
)
select*, (rolling_people_vaccinations/population)*100 pop_vaccined_percentage
from pop_vs_vac



-- TEMP TABLE

drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinations numeric,
)

insert into #percent_population_vaccinated
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, sum(convert(bigint,vaccine.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as rolling_people_vaccinations
from PortfolioProject.dbo.CovidDeaths death
join PortfolioProject.dbo.CovidVaccinations vaccine
    on death.location = vaccine.location
	and death.date = vaccine.date
--where death.continent is not null
--order by death.location, death.date

select*, (rolling_people_vaccinations/population)*100 pop_vaccined_percentage
from #percent_population_vaccinated



-- Creating View to store data for later

create view percent_population_vaccinated as
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, sum(convert(bigint,vaccine.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as rolling_people_vaccinations
from PortfolioProject.dbo.CovidDeaths death
join PortfolioProject.dbo.CovidVaccinations vaccine
    on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by death.location, death.date


create view india_covid_death_data as
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%India%'
--order by Location, date


create view india_covid_population_percent as
select Location, date, population, total_cases, (total_cases/population)*100 as covidpopulation
from PortfolioProject.dbo.CovidDeaths
where location like '%India%'
--order by Location, date


create view percent_population_infected as
select Location, population, Max(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percent_population_infected
from PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
where continent is not null 
group by Location, population
--order by percent_population_infected desc


create view atual_continent_wise_deathcount as
select location, Max(cast(total_deaths as int)) as continent_total_death_count
from PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
where continent is null 
group by location
--order by continent_total_death_count desc

create view total_death_count as 
select continent, Max(cast(total_deaths as int)) as total_death_count
from PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
where continent is not null 
group by continent
--order by total_death_count desc


create view covidpopulation_continent_wise as
select continent, date, population, total_cases, (total_cases/population)*100 as covidpopulation
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
--order by continent, date



create view percent_population_infected_continentwise as
select continent, population, Max(total_cases) as highest_infection_count, Max((total_cases/population))*100 as percent_population_infected
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
group by continent, population
--order by percent_population_infected desc

create view total_death_count_continentwise as
select continent, Max(cast(total_deaths as int)) as total_death_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
group by continent
--order by total_death_count desc


create view all_death_precentage as
select date, Sum(new_cases) as all_covid_cases, sum(cast(new_deaths as int)) as all_covid_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as all_deathpercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
where continent is not null
group by date
--order by date, all_covid_cases



create view population_vs_vaccinations as
with pop_vs_vac (continent, date, location, population, new_vaccinations, rolling_people_vaccinations)
as 
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, sum(convert(bigint,vaccine.new_vaccinations)) OVER (partition by death.location order by death.location, death.date) as rolling_people_vaccinations
from PortfolioProject.dbo.CovidDeaths death
join PortfolioProject.dbo.CovidVaccinations vaccine
    on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null
--order by death.location, death.date
)
select*, (rolling_people_vaccinations/population)*100 pop_vaccined_percentage
from pop_vs_vac
