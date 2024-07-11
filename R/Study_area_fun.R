# Define the individual functions
studyAreaFun <- function() {
  studyArea <- reproducible::prepInputs(
    url = "https://drive.google.com/file/d/1MItAlDClThU4ve3gOb8FkvTEotFy8dYr/view?usp=drive_link",
    destinationPath = "inputs",
    overwrite = TRUE,
    purge = TRUE,
    fun = "terra::vect"
  )
  
  rasterToMatch <- LandR::prepInputsLCC(
    year = 2005,
    destinationPath = "inputs",
    writeTo = "inputs/rasterToMatch_LCC.tif",
    overwrite = TRUE,
    cropTo = studyArea,
    maskTo = studyArea,
    method = c("near"),
    fun = "terra::rast"
  )
  
  studyArea <- terra::project(studyArea, rasterToMatch)
  studyArea <- terra::aggregate(studyArea, by=NULL, dissolve=TRUE, fun="mean")
  terra::writeVector(studyArea, "inputs/studyArea.shp",overwrite=TRUE)
  
  return(list(rasterToMatch = rasterToMatch, studyArea = studyArea))
}

studyAreaLargeFun <- function() {
  studyAreaLarge <- reproducible::prepInputs(
    url =  "https://drive.google.com/file/d/1quNt_aXhLoxbbZG6GB42Jmgfwvd5WlVF/view?usp=drive_link",
    destinationPath = "inputs",
    overwrite = TRUE,
    purge = TRUE,
    fun = "terra::vect"
  )
  
  rasterToMatchLarge <- LandR::prepInputsLCC(
    year = 2005,
    destinationPath = "inputs",
    writeTo = "inputs/rasterToMatchLarge_LCC.tif",
    overwrite = TRUE,
    cropTo = studyAreaLarge,
    maskTo = studyAreaLarge,
    method = c("near"),
    fun = "terra::rast"
  )
  
  studyAreaLarge <- terra::project(studyAreaLarge, rasterToMatchLarge)
  studyAreaLarge <- terra::aggregate(studyAreaLarge, by=NULL, dissolve=TRUE, fun="mean")
  terra::writeVector(studyAreaLarge, "inputs/studyAreaLarge.shp",overwrite=TRUE)
  
  return(list(rasterToMatchLarge = rasterToMatchLarge, studyAreaLarge = studyAreaLarge))
}

studyAreaANPPFun <- function() {
  studyAreaANPP <- reproducible::prepInputs(
    url = "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lpr_000b16a_e.zip",
    destinationPath = "inputs",
    overwrite = TRUE,
    purge = TRUE,
    fun = "terra::vect"
  )
  
  studyAreaANPP <- studyAreaANPP[studyAreaANPP$PRUID %in% c(35, 24, 13),]
  terra::writeVector(studyAreaANPP, "inputs/studyAreaANPP.shp",overwrite=TRUE)
  
  return(studyAreaANPP=studyAreaANPP)
}

studyAreaPSPFun <- function() {
  studyAreaPSP <- reproducible::prepInputs(
    url = "https://drive.google.com/file/d/1NPTK44KQTdoi_ujdRlUaXnBALzk1Jm9W/view?usp=drive_link",
    destinationPath = "inputs",
    overwrite = TRUE,
    purge = TRUE,
    fun = "terra::vect"
  )
  terra::writeVector(studyAreaPSP, "inputs/studyAreaPSP.shp",overwrite=TRUE)
  return(studyAreaPSP=studyAreaPSP)
}

shirinSppEquivFun <- function() {
  speciesOfConcern <- c("Acer_rub","Betu_all","Abie_bal","Betu_pap")
  shirin <- LandR::sppEquivalencies_CA
  shirin <- shirin[LandR %in% speciesOfConcern,]
  write.csv(shirin, "inputs/shirinSppEquiv.CSV")
  
  return(shirin=shirin)
}

