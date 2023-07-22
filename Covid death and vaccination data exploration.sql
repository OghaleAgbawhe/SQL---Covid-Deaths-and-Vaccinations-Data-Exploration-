
Select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


Select * 
from PortfolioProject..CovidVaccinations
order by 3,4

--Data for Exploration
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Exploring Total cases vs Total deaths 
-- Depicts the fatality rate or likelihood of dying by contracting Covid in all countries for each date 
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2


-- Depicts the fatality rate or likelihood of dying by contracting Covid in Canada for each date 
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Canada%' and continent is not null
order by 1,2

--Checking same fatality rate in the United states 
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'United States' and continent is not null
order by 1,2


-- Exploring Total cases vs Population 
--Depicts the percentage of the population that has contracted covid in the United States 
Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%States%' and continent is not null
order by 1,2


-- Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/Population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc 


--Depicting Countries with Highest death count per population 
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc 

--Zooming out to view on a larger scale - CATEGORIZING BY CONTINENT
--Depicting continents with Highest death count per population 
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc 


--GLOBAL NUMBERS

--Daily covid death percentages worldwide  
select date, sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths,
CASE
when sum(new_cases) = 0 then 0   -- If Total_Cases is 0, return 0 as DeathPercentage to avoid divide by zero error 
else sum(cast(New_deaths as int))/sum(New_Cases)*100
END as DeathPercentage
from PortfolioProject..CovidDeaths
where New_cases is not null 
group by date
order by 1,2


--Determining the total cases and deaths worldwide 
select sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths,
CASE
when sum(new_cases) = 0 then 0   -- If Total_Cases is 0, return 0 as DeathPercentage to avoid divide by zero error 
else sum(cast(New_deaths as int))/sum(New_Cases)*100
END as DeathPercentage
from PortfolioProject..CovidDeaths
where New_cases is not null 
--group by date
order by 1,2


--Exploring Total population vs vaccinations 
--i.e Determining the total number of people in the world that have been vaccinated

--Using Common Table Expression (CTE) 

With Popsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From Popsvac






--TEMPORARY TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 



Select *
from PercentPopulationVaccinated


