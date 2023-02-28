select * from CovidDeaths
order by 3, 4

select * from covidvaccinations
order by 3, 4

-- select the data that we are going to use for this project

select Location, Date, total_cases, new_cases, total_deaths, population
from CovidDeaths order by 1,2;

-- Looking at Total cases vs total deaths
select 
	Location, Date, total_cases, total_deaths, round(((total_deaths/total_cases)*100),2) as Deathpercentage
from CovidDeaths 
where location like '%states%'
order by 1,2;

-- Looking at Total cases vs population
-- shows what percentage of poplulation got covid.
select 
	Location, Date, total_cases, population, round(((total_cases/population)*100),2) as Covidpercentage
from CovidDeaths 
where location like '%states%'
order by 1,2;

-- Looking at countries with highest infection rate compared to population
select 
	Location, population, max(total_cases) as highestinfectedcount, round((max(total_cases/population)*100),2) as Covidpercentage
from CovidDeaths 
group by location, population
order by Covidpercentage desc

-- Showing countries with highest death count per poplulation

select 
	continent, max(cast(total_deaths as int)) as highestdeathcount
from CovidDeaths
where continent is not null
group by continent
order by highestdeathcount desc

-- lets break down by continent
select 
	Location, max(cast(total_deaths as int)) as highestdeathcount
from CovidDeaths
where continent is null
group by location
order by highestdeathcount desc

-- Global case status(death percentages) in each day
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, round(sum(cast(new_deaths as int))/sum(new_cases),2)*100 as deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

-- Global case status total
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, round(sum(cast(new_deaths as int))/sum(new_cases),2)*100 as deathpercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2

-- looking for total population vs vaccinations, cumulative total
select cd.continent, cd.location, cd.date, cd.population, cov.new_vaccinations,
 sum(convert(int, cov.new_vaccinations)) over(partition by cd.location order by cd.location, cd.date)
 as cumulativetotalvaccinated
from CovidDeaths cd
join CovidVaccinations cov
on cd.location = cov.location
and cd.date = cov.date
where cd.continent is not null
order by 2,3

-- use CTE because we want to calculate the vaccinated percentage from cumulative total vaccinated numbers

with popvsvac (continent, location, date, population, new_vaccinations, cumulativetotalvaccinated)
as
(select cd.continent, cd.location, cd.date, cd.population, cov.new_vaccinations,
 sum(convert(int, cov.new_vaccinations)) over(partition by cd.location order by cd.location, cd.date)
 as cumulativetotalvaccinated
from CovidDeaths cd
join CovidVaccinations cov
on cd.location = cov.location
and cd.date = cov.date
where cd.continent is not null)

select * ,(cumulativetotalvaccinated/population)*100
from popvsvac

--TEMP table
Drop table if exists #percentpoplulationvaccinated
Create table #percentpoplulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativetotalvaccinated numeric)

insert into #percentpoplulationvaccinated
select cd.continent, cd.location, cd.date, cd.population, cov.new_vaccinations,
 sum(convert(int, cov.new_vaccinations)) over(partition by cd.location order by cd.location, cd.date)
 as cumulativetotalvaccinated
from CovidDeaths cd
join CovidVaccinations cov
on cd.location = cov.location
and cd.date = cov.date
where cd.continent is not null

select * ,(cumulativetotalvaccinated/population)*100
from #percentpoplulationvaccinated

-- creating view to store data for later visualizations
create view percentpoplulationvaccinated as
select cd.continent, cd.location, cd.date, cd.population, cov.new_vaccinations,
 sum(convert(int, cov.new_vaccinations)) over(partition by cd.location order by cd.location, cd.date)
 as cumulativetotalvaccinated
from CovidDeaths cd
join CovidVaccinations cov
on cd.location = cov.location
and cd.date = cov.date
where cd.continent is not null

select * from percentpoplulationvaccinated