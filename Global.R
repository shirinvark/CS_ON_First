# .libPaths()
# .libPaths("C:/Users/SHVAR1/AppData/Local/Programs/R/R-4.4.1/library")
# remove.packages("Require")
#install.packages("remotes")
#devtools::install_github("PredictiveEcology/climateData", ref = "development", dependencies = TRUE) 
#devtools::install_github("PredictiveEcology/reproducible", ref = "development", dependencies = TRUE,force=TRUE) 
#devtools::install_github("ianmseddy/PSPclean", ref = "development", dependencies = TRUE,force=TRUE)
#devtools::install_github("PredictiveEcology/SpaDES.core", ref = "development", dependencies = TRUE,force=TRUE)
#devtools::install_github("ianmseddy/LandR.CS", ref = "development", dependencies = TRUE,force=TRUE)
#devtools::install_github("PredictiveEcology/SpaDES.project", ref = "development", dependencies = TRUE,force=TRUE) 
#devtools::install_github("PredictiveEcology/Require", ref = "development", dependencies = TRUE,force=TRUE) 

# be carefull start with a new project
#this is a function that will check and update package,
getOrUpdatePkg <- function(p, minVer, repo) {
  if (!isFALSE(try(packageVersion(p) < minVer, silent = TRUE) )) {
    if (missing(repo)) repo = c("predictiveecology.r-universe.dev", getOption("repos"))
    install.packages(p, repos = repo)
  }
}
getOrUpdatePkg("SpaDES.project", "0.0.8.9040")

library(SpaDES.project)
out <- SpaDES.project::setupProject(
  updateRprofile = TRUE,
  Restart = TRUE,
  require = c("googledrive"),
  paths = list(projectPath = "CS_ON_First",
               modulePath = file.path("modules"),
               cachePath = file.path("cache"),
               scratchPath = file.path("scratch"),
               inputPath = file.path("inputs"),
               outputPath = file.path("outputs")
  ),
  modules = c(
    "PredictiveEcology/Biomass_speciesData@development",
    "PredictiveEcology/Biomass_borealDataPrep@development",
    "PredictiveEcology/Biomass_speciesParameters@manual",
    "PredictiveEcology/Biomass_core@development",
     "PredictiveEcology/canClimateData@development",
    "ianmseddy/gmcsDataPrep@development"
  ),
  options = list(spades.allowInitDuringSimInit = TRUE,
                 LandR.assertions = FALSE,
                 reproducible.objSize = FALSE,
                 reproducible.useCache = "overwrite",
                 reproducible.shapefileRead = "terra::vect", #required if gadm is down as terra:projct won't work on sf
                 spades.recoveryMode = 1,
                 spades.moduleCodeChecks = FALSE
  ),
  times = list(start = 2011, end = 2021),
  params = list(
    .globals = list(.studyAreaName = "OntarioFirst",
                    dataYear = 2011,
                    sppEquivCol = 'LandR',
                    .Plots = "png"),
    Biomass_borealDataPrep = list(
      overrideAgeInFires = FALSE
    ),
    Biomass_speciesParameters = list(
      PSPdataTypes = c("NFI","ON","NB", "QC")
    ),
    gmcsDataPrep = list(
      PSPdataTypes =  c("NFI", "ON", "NB", "QC"),
      doPlotting = TRUE
    )
  ),
  functions = "results/CS_ON_First@main/R/Study_area_fun.R", #Make SURE THIS IS WHERE YOU SAVED THE FUNCTIONS FILE!
  studyArea = studyAreaFun()$studyArea,
  rasterToMatch = studyAreaFun()$rasterToMatch,
  studyAreaLarge = studyAreaLargeFun()$studyAreaLarge,
  rasterToMatchLarge = studyAreaLargeFun()$rasterToMatchLarge,
  studyAreaPSP =  studyAreaPSPFun(),
  studyAreaANPP = studyAreaANPPFun(),
  sppEquiv = shirinSppEquivFun(),
  useGit = TRUE
)

out$params$gmcsDataPrep$growthModel <- quote(nlme::lme(growth ~ logAge*(ATA + CMI),
                                                       random = ~1 | OrigPlotID1,
                                                       weights = varFunc(~plotSize^0.5 * periodLength),
                                                       data = PSPmodelData))
out$params$gmcsDataPrep$nullGrowthModel <- quote(nlme::lme(growth ~ logAge,
                                                           random = ~1 | OrigPlotID1,
                                                           weights = varFunc(~plotSize^0.5 * periodLength),
                                                           data = PSPmodelData))





historical_prd <- c("1951_1980", "1981_2010")
historical_yrs <- c("1991_2022")

projected_yrs <- c(2011:2051)

out$climateVariables <- list(
  historical_CMI_normal = list(
    vars = "historical_CMI_normal",
    fun = quote(calcCMInormal),
    .dots = list(historical_period = historical_prd, historical_years = historical_yrs)
  ),
  projected_ATA = list(
    vars = c("future_MAT", "historical_MAT_normal"),
    fun = quote(calcATA),
    .dots = list(historical_period = historical_prd, future_years = projected_yrs)
  ),
  projected_CMI = list(
    vars = "future_CMI",
    fun = quote(calcAsIs),
    .dots = list(future_years = projected_yrs)
  )
)



test <- do.call(SpaDES.core::simInitAndSpades, out)

#ss
# 
# # 
# # #some codes that after copleting the run should be checked
#  test$gcsModel
# x11()
# plot(test$climateVariables)(test)
# plot(test$gcsModel)
