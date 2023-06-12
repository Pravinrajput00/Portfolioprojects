/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
from [portfolio project]..CovidDeaths
where continent is not null
order by location,date

--select data that we are going to be starting with

select location, date, total_cases, new_cases,total_deaths, population
from [portfolio project]..CovidDeaths
where continent is not null
order by location,date

--total cases vs death
select location, date, total_cases,total_deaths,((total_deaths/total_cases)*100) as Deathinfectionpercentage
from [portfolio project]..CovidDeaths
where continent is not null
order by location,date

--shows lilelyhood of dying if you contract covid in india
select location, date, total_cases,total_deaths,((total_deaths/total_cases)*100) as Deathinfectionpercentage
from [portfolio project]..CovidDeaths
where location like '%india%'
and continent is not null
order by location,date

--Total cases vs population
--shows what percentage of population is infected iwith covid
select location, date,population, total_cases,((total_cases/population)*100) as Infectionpopulationpercentage 
from [portfolio project]..CovidDeaths
order by location,date

--shows what percentage of population of india is infected iwith covid
select location, date,population, total_cases,((total_cases/population)*100) as Infectionpopulationpercentage 
from [portfolio project]..CovidDeaths
where location like '%india%'
order by location,date

--looking at countries with highest infection rate as compared with population
select location,population, max(total_cases) as highestinfectioncount,(max(total_cases/population)*100) as Infectionpopulationpercentage 
from [portfolio project]..CovidDeaths
group by location,population
order by Infectionpopulationpercentage desc


--showing the countries with highest death counts per population
select location, max(cast(total_deaths as int) )as highestdeathcount
from [portfolio project]..CovidDeaths
Where continent is not null
group by location
order by highestdeathcount desc


-- Showing contintents with the highest death count per population
select continent, max(cast(total_deaths as int) )as highestdeathcount
from [portfolio project]..CovidDeaths
Where continent is not  null
group by continent
order by highestdeathcount desc

--showing the countries with highest death counts per population
select location,population, max(total_deaths) as highestdeathcount,(max(total_deaths/population)*100) as deathpopulationpercentage 
from [portfolio project]..CovidDeaths
group by population,location
order by deathpopulationpercentage desc




-- GLOBAL NUMBERS
select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as percentagetotaldeathandtotalcases
from [portfolio project]..CovidDeaths
where continent is not null
order by percentagetotaldeathandtotalcases desc 


--looking at total population and vaccination
--Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location, dea.population, dea.date, dea.population, 
vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingsum
--(rollingsum/population)*100 as percentagepopulationvaccinated
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by dea.location,dea.date

---- Using CTE to perform Calculation on Partition By in previous query
with popvsvac (continent,location,population,date,new_vaccinations,rollingsum)
as
(
select dea.continent,dea.location, dea.population, dea.date, 
vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingsum
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *, (rollingsum/population)*100 as percentagepopulationvaccinated from popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query
drop table  if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
population numeric,
date datetime,
new_vaccinations numeric,
rollingsum numeric
)
insert into #percentagepopulationvaccinated
select dea.continent,dea.location, dea.population, dea.date, 
vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingsum
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


select *, (rollingsum/population)*100 as percentagepopulationvaccinated from #percentagepopulationvaccinated


-- Creating View to store data for later visualizations
create view percentagepopulationvaccinated 
as
select dea.continent,dea.location, dea.population, dea.date, 
vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingsum
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

 
 select * from percentagepopulationvaccinated