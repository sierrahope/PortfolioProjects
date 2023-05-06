Select *
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Order By 3,4;

Select *
FROM PortfolioProject..CovidVaccinations$
Order By 3,4;

--select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

--looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Canada%' AND continent is not null
Order by 1,2

-- looking at total cases vs the population
-- show what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfect
From PortfolioProject..CovidDeaths$
Where location='Canada'
Order by 1,2
--from march 6, 2020 and onwards is correct, idk what was happening before

--looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group By Location, Population
Order by PercentPopulationInfected desc

--showing countries with higest death count per population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group By Location
Order by TotalDeathCount desc

--break down by continent and income class

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group By location
Order by TotalDeathCount desc


--showing continents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group By continent
Order by TotalDeathCount desc


-- global numbers

Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 1,2


--looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- temp table

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
	SUM(vac.new_vaccinations) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--if you want to change something

DROP Table if exists #PercentPopulationVaccinated --can just keep at top of query so that its easy to change
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
	SUM(vac.new_vaccinations) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--create view to store data for later visualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

--not in views folder this is how to see views
Select *
FROM PercentPopulationVaccinated