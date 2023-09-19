
-- Select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

select Location, Date, Total_Cases, Total_Deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'Argentina'
order by 1,2


-- Looking at cases vs population


select Location, Date, Population, Total_Cases, (Total_Cases / population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'Argentina'
order by 1,2


-- Looking at Country with Highest Infection Rate compared to Population

select Location, Population, MAX(Total_Cases) as HighestInfectionCount, MAX(Total_Cases / population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
order by CasesPercentage DESC



-- Showing Countries with Highest Death Counter per Population

select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY Location
order by TotalDeathCount DESC


-- Showing Total Death Percentage for Covid (Total_Cases vs Total_Deaths)

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

AND dea.location = 'Argentina'
order by 2,3


-- USE CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

AND dea.location = 'Argentina'

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
From #PercentPopulationVaccinated



-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



Select *
From PercentPopulationVaccinated