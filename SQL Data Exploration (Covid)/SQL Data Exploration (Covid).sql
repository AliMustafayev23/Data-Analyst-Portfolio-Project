
--Select data we are going to be using

Select location, date, total_cases, new_cases, total_deaths,population
From Covid..CovidDeaths
Order by 1,2

--Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths , 
Case
When total_deaths is not null Then Concat(Round((total_deaths/total_cases)*100,2),'%')
When total_deaths is null Then '0%'
End as DeathPercentage
From Covid..CovidDeaths
Where location like '%Azer%'
Order by 1,2

--Looking at total cases vs population

Select location, date, total_cases, population , 
Case
When total_cases is not null Then Concat(Round((total_cases/population)*100,2),'%')
When total_cases is null Then '0%'
End as PercentPopulationInfection
From Covid..CovidDeaths
Where location like '%Azer%'
Order by 1,2

--Looking at Countries with High Infetcion Rate compared to Population

SELECT location, MAX(cast(total_cases as int)) as MaximumInfection, population,
CONCAT(
CASE
WHEN MAX(total_cases) IS NOT NULL THEN MAX(ROUND((cast(total_cases as int)/population)*100, 2))
WHEN MAX(total_cases) IS NULL THEN 0
END,'%') AS PercentPopulationInfection
FROM Covid..CovidDeaths
GROUP BY population, location
ORDER BY PercentPopulationInfection Desc;

--Showing Countries with highest death

SELECT location, population, MAX(cast(total_deaths as int)) as Deaths
FROM Covid..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Deaths DESC;

--Showing Countries with highest Death count compared to Population

SELECT location, Max(cast(total_deaths as int)) as Deaths , population ,
CONCAT(
CASE
WHEN MAX(total_deaths) IS NOT NULL THEN MAX(ROUND((cast(total_deaths as int)/population)*100, 2))
WHEN MAX(total_deaths) IS NULL THEN 0
END,'%') AS PercentPopulationDeath
FROM Covid..CovidDeaths
WHERE continent is not null
GROUP BY population, location
Order by PercentPopulationDeath Desc

--Showing Continent with highest death

SELECT continent, MAX(cast(total_deaths as int)) as Deaths
FROM Covid..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Deaths DESC;

--Global numbers

Select 
SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
Concat((Round((SUM(cast(new_deaths as int))/SUM(New_Cases)*100),2)),'%') as DeathPercentage
From Covid..CovidDeaths
where continent is not null 
order by 1,2

--Looking at total population vs vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From Covid..CovidDeaths as dea
Join Covid..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
Order by 2,3

--Use CTE

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From Covid..CovidDeaths as dea
Join Covid..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null)
Select *,
Case
When RollingPeopleVaccinated is null then '0%'
When RollingPeopleVaccinated is not null then Concat(Round(((cast(RollingPeopleVaccinated as int)/Population)*100),2),'%')
End
From PopvsVac
Order by 2,3

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From Covid..CovidDeaths as dea
Join Covid..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

SELECT *,
  CASE
    WHEN RollingPeopleVaccinated IS NOT NULL THEN 
      --ROUND((CAST(RollingPeopleVaccinated AS int) / NULLIF(Population, 0)) * 100, 2)
	  Concat((Substring(Convert(varchar(100),Round(((RollingPeopleVaccinated/Population)*100),2)),1,4)),'%')
    ELSE
      '0%'
  END AS PercenatagePopulationVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2, 3;

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From Covid..CovidDeaths as dea
Join Covid..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated