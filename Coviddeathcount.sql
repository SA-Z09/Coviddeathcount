--Checking both the tables
select *
from Covid . .[Covid death]
select *
from Covid . .Cowidvaccination
ORDER BY 3,4 

--Checking specific column and data 
Select location, date, total_cases, new_cases, total_deaths, population
from Covid.. [Covid death]
order by 1,2 

-- Checking Total cases VS Total Deaths
Select location, date, total_cases total_deaths, (total_Deaths/total_cases)*100 as Death_percentage
from Covid.. [Covid death]
order by 1,2

-- checking death percentages of India   
Select location, date, total_cases, total_deaths, (total_Deaths/total_cases)*100 as Death_percentage
from Covid.. [Covid death]
where location like '%india%'
order by 1,2

-- Checking Total cases VS Population 
-- Getting insights on % of population getting Covid 
Select location, date, population, total_cases,(total_cases/population)*100 as Perc_population_infected
from covid.. [Covid death]
where location like '%india%'
order by 1,2

-- checking highest infected rate campared to population arranging by Desc order
Select Location population, max(total_cases) as Highest_Infection_Rate, max((total_cases/population))*100 as percentage_population_infected
from Covid.. [Covid death]
Group by Location, population
order by  percentage_population_infected desc

--Showing countries showing highest death count per population
Select Location, Max(cast(total_deaths as int)) as total_Death_Count
from Covid.. [Covid death]
where continent is not null
Group by Location
order by total_Death_Count desc

--Highest death count continent wise
Select location, Max(cast(total_deaths as int)) as total_Death_Count
from Covid..[Covid death]
where continent is null
Group by location
order by total_Death_Count desc

--looking at the bigger picture 
Select date, sum(new_cases) -- (total_Deaths/total_cases)*100 as Death_percentage
from Covid.. [Covid death]
where continent is not null 
group by date
order by 1,2

-- Death % across the world
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int))/sum(new_cases)  as Death_percentage
from Covid.. [Covid death]
where continent is not null 
group by date
order by 1,2


-- Total cases, deaths and death percentages 
Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from Covid.. [Covid death]
where continent is not null 
order by 1,2

--Joining tables together by using common tables Location and Date
select *
from Covid..[Covid death] DEA -- dea as a shortcut to use in the place of covid death table
JOIN  Covid..Cowidvaccination vac -- vac a shortcut to use in the place of covid vaccination table
on DEA.location = vac.location
and dea.date = vac.date

--Total population VS Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Covid..[Covid death] DEA 
JOIN  Covid..Cowidvaccination vac 
on DEA.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2


--CTE
WITH Pop_VS_Vacc (continent, location, date, population,new_vaccinations, people_vaccination) as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as people_vaccination
from Covid..[Covid death] DEA 
JOIN  Covid..Cowidvaccination vac 
on DEA.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
--order by 2,3
select* , (people_vaccination/population)*100
from Pop_VS_Vacc

-- Temp table -- 
DROP TABLE IF EXISTS #Percent_population_vacc --Easy to make alteration

create table #Percent_population_vacc
(continent nvarchar(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
population numeric, 
new_vaccination numeric,
people_vaccination NUMERIC)

insert into #Percent_population_vacc
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as people_vaccination
from Covid..[Covid death] DEA 
JOIN  Covid..Cowidvaccination vac 
on DEA.location = vac.location
and dea.date = vac.date
where dea.continent is not null
select* , (people_vaccination/population)*100
FROM #Percent_population_vacc

-- Creating a sample view 
drop view if exists percent_population_vacc

Create view 
Percent_population_vacc as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as people_vaccination
from Covid..[Covid death] DEA 
JOIN  Covid..Cowidvaccination vac 
on DEA.location = vac.location
and dea.date = vac.date
where dea.continent is not null



--Queries used for Tableau Project--




-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From COVID..[Covid death]
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
From Covid..[Covid death]
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid..[Covid death]
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid..[Covid death]
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc