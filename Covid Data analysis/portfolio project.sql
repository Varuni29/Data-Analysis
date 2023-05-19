
select * from [Portfolio project]..covid_death where continent is not null order by 3,4

-- select * from [Portfolio project]..covid_vaccination order by 3,4

-- Select the data that we are going to use

use [Portfolio project]

select location,date,total_cases,new_cases,total_deaths,
population from covid_death order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths *100.0/total_cases) as deathpercentage
from covid_death where location like '%India%' order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid

select location,date,population,total_cases,(total_cases *100.0/population) as people_had_covid
from covid_death where location like '%India%' order by 1,2

-- looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestInfectionCount,max(total_cases *100.0/population) as percentpopulationinfected
from covid_death group by location,population order by percentpopulationinfected desc

-- showing countries with highest death count per population
select location,max(total_deaths) as TotalDeathCount
from covid_death where continent is not null 
group by location order by TotalDeathCount desc

-- let's see result by continent
-- showing the continent with highest death count per population

select continent,max(total_deaths) as TotalDeathCount
from covid_death where continent is not null 
group by continent order by TotalDeathCount desc

-- Global numbers

select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(new_deaths)*100.0/sum(new_cases) as deathpercentage
-- ,total_deaths,(total_deaths *100.0/total_cases) as deathpercentage
from covid_death where continent is not null order by 1,2

-- Looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevacination
from covid_death dea join covid_vaccination vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null order by 2,3

-- use cte
with PopvsVac (continent,location,date,population,new_vaccination,rollingpeoplevacination) as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevacination
from covid_death dea join covid_vaccination vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null)select *,(rollingpeoplevacination *100.0/population)as vaccinated_population from PopvsVac

-- Creating view to store data for later visualizations

create view Percentpopulationvaccinate as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevacination
from covid_death dea join covid_vaccination vac 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select * from Percentpopulationvaccinate


/*
Queries used for Tableau Project
*/
-- 1. 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))*100.0/SUM(New_Cases)as DeathPercentage
From covid_death
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location
--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2
-- 2. 
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covid_death
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc
-- 3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases*100.0/population)) as PercentPopulationInfected
From covid_death
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc
-- 4.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases*100.0/population)) as PercentPopulationInfected
From covid_death
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

