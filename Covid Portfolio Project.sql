select * from CovidDeaths$
where continent is not null
order by  3, 4

select location, date ,
total_cases, new_cases, total_deaths, 
population from CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Death
-- Shows likelihood of dying if you contract covid in your country
select location, date ,
total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage 
from CovidDeaths$
where location like '%Uzbekistan%'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date ,
total_cases, population, (total_cases/population) *100 as PopulationInfectedPercentage 
from CovidDeaths$
order by 1,2

--Looking at Countries with Highest Infesction rate compared to population

select location,
Max(total_cases) as HighestInfectionRate, 
population, Max(total_cases/population) *100  as CovidPercentage 
from CovidDeaths$
group by location, population
order by CovidPercentage  desc


--Showing Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break thing down by continent

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is null
Group by location
order by TotalDeathCount desc

--Showing continent with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL Numbers

select  SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/ sum(new_cases) * 100 as DeathPercentage from CovidDeaths$
Where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location,
dea.date, dea.population,vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ as dea
join CovidVaccinations$ as vac 
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE

with PopvsVac ( Continent, Location, date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,
dea.date, dea.population,vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ as dea
join CovidVaccinations$ as vac 
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) * 100 from PopvsVac

-- Temp table

Drop table if exists #PCTpopulationVaccinated
create table #PCTpopulationVaccinated
(Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric)

insert into #PCTpopulationVaccinated
Select dea.continent, dea.location,
dea.date, dea.population,vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ as dea
join CovidVaccinations$ as vac 
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null

select * from #PCTpopulationVaccinated

-- Creating view to store data for later visualizations

create view  PCTpopulationVaccinated as
Select dea.continent, dea.location,
dea.date, dea.population,vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ as dea
join CovidVaccinations$ as vac 
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null

Select * from PCTpopulationVaccinated