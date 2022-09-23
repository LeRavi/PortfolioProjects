Select *
From PortfolioProject..covidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select data that we are going to be using

--Select location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..covidDeaths
--order by 1,2



--Looking at Total Cases vs Total Deaths
--datatype nvarchar need to be converted to float, 

ALTER TABLE covidDeaths
ALTER COLUMN total_cases float;


ALTER TABLE covidDeaths
ALTER COLUMN total_deaths float;

ALTER TABLE covidDeaths
ALTER COLUMN population float;



-- Shows likelihood of dying in Denmark if you get corona
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject..covidDeaths
Where location like '%Denmark'
where continent is not null
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases / population)*100 as populationInfectedPercent
From PortfolioProject..covidDeaths
--Where location like '%Denmark'
where continent is not null
order by 1,2

-- What countries has the higest infection rate

Select location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as 
HighestInfectionRate
From PortfolioProject..covidDeaths
--Where location like '%Denmark'
where continent is not null
Group by location, population
order by HighestInfectionRate desc

--what countries has the higest death count per population


Select location, MAX(total_deaths) as TotalDeathCount 
From PortfolioProject..covidDeaths
--Where location like '%Denmark'
where continent is not null
Group by location
order by TotalDeathCount desc

--Lets break things down by continent


--Select location, MAX(total_deaths) as TotalDeathCount 
--From PortfolioProject..covidDeaths
----Where location like '%Denmark'
--where continent is null
--Group by location
--order by TotalDeathCount desc


-- showing continent with higest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount 
From PortfolioProject..covidDeaths
--Where location like '%Denmark'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, 
sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as GlobalDeathPercentage
From PortfolioProject..covidDeaths
--Where location like '%Denmark'
where continent is not null
--Group by date
order by 1,2


-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
, SUM(cast(new_vaccinations_smoothed as float)) OVER (Partition by dea.location order by dea.location
, dea.date) as rollingVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


select SUM(cast(new_vaccinations_smoothed as float))
From PortfolioProject..CovidVaccinations



---- USE CTE

--With PopvsVac (continet,location, date, population, vac.new_vaccinations_smoothed, rolling_ppl_Vaccinated) 
--as
--(
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
--, SUM(cast(new_vaccinations_smoothed as float)) OVER (Partition by dea.location order by dea.location
--, dea.date) as rolling_ppl_Vaccinated
--From PortfolioProject..covidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
--)

-- temp table

DROP table if exists #percentPopulationVaccinated
Create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations_smoothed numeric,
rollingVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
, SUM(cast(new_vaccinations_smoothed as float)) OVER (Partition by dea.location order by dea.location
, dea.date) as rollingVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (rollingVaccinated/population)*10 as roll_vac_pop_percent
from #percentPopulationVaccinated


-- Creating view to store data for later visualization

Create View percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed
, SUM(cast(new_vaccinations_smoothed as float)) OVER (Partition by dea.location order by dea.location
, dea.date) as rollingVaccinated
From PortfolioProject..covidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from percentPopulationVaccinated
