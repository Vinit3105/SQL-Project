select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,Total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- shows likelihood of dying if you contract in your country
select location,date,total_cases,Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2


-- looking at total cases vs population
-- shows what ppercentage of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationAffected
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount ,max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, Population
order by PercentPopulationInfected desc

--showing the countries with highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount  desc

--showing the continent with highest death count per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount  desc


--golbal numbers
select date,sum(new_cases) as Total_cases, sum(cast(new_deaths as int))as Total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date

--looking at total population vs vaccinations  

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations as NewVaccinations
,sum(convert(int,vac.new_vaccinations ))  over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location 
     and dea.date=vac.date
where dea.continent is not null
order by 2,3



--USE CTE

with PopvsVac (continent,location,date,population,NewVaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations as NewVaccinations
,sum(convert(int,vac.new_vaccinations ))  over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location 
     and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from PopvsVac



--Temp Table
 
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations as NewVaccinations
,sum(convert(int,vac.new_vaccinations ))  over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location 
     and dea.date=vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations as NewVaccinations
,sum(convert(int,vac.new_vaccinations ))  over (partition by dea.location order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location 
     and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated








