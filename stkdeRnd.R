## Space-time kernel based on randomly sampled dates

set.seed(1234)

library(rgdal)
library(rgeos)
library(spatstat)
library(sparr)
library(maptools)
library(rts)
library(Bchron)

## How many samples?
nbit = 100

## Window for analysis
cnty = readOGR("ut_counties/Counties.shp")
# plot(cnty)
sj.sp = cnty[cnty$NAME =="SAN JUAN",]
# sj.sp = gSimplify(sj.sp, tol=0.01)
plot(sj.sp)

## Data
dat = read.csv("data/SJco_14C_Dates_Draft_012419.csv")
str(dat)
coordinates(dat) <- ~Easting+Northing
plot(dat, add=TRUE)

## Dates
load("caldates.RData")

## Sample dates
caldates.rnd = sampleAges(caldates, n=nbit)

# First convert boundary to owin object
y <- as(sj.sp, "SpatialPolygons")
# Then convert SpatialPolygons to owin class
sj.owin <- as(y, "owin")

# Now get site coordinates
dat.x <- coordinates(dat)[,1]
dat.y <- coordinates(dat)[,2]

# Finally make up ppp object using coordinates and owin
sj.ppp <- ppp(dat.x, dat.y,
                   window=sj.owin)

## Space-time slices:
tims <- seq(500,10500, by=500)
ntims = length(tims)

## Parameters for kernel
hlam <- c(2e4, 1e3)

for (i in 1:nbit) {
  sj.den2 <- spattemp.density(sj.ppp, tt = caldates.rnd[i,],
                              h = hlam[1], lambda = hlam[2], 
                              tlim = c(0,12000), tres = 256)
  sj.slice <- spattemp.slice(sj.den2,tt=tims)
  
  stop()
}


stop()
## Space time density with default settings
sj.den1 <- spattemp.density(sj.ppp,tres=500) 

## Plot and compare 
tims <- c(2000,4000,6000)
par(mfcol=c(2,3))
for(i in tims){ 
  plot(sj.den1,i,override.par=FALSE,fix.range=TRUE,main=paste("joint",i))
  plot(sj.den1,i,"conditional",override.par=FALSE,main=paste("cond.",i))
}

## Likelihood based parameter estimates
hlam <- LIK.spattemp(sj.ppp,tlim=c(0,11000),verbose=FALSE)
print(hlam)
sj.den2 <- spattemp.density(sj.ppp,h=hlam[1],lambda=hlam[2], 
                            tlim=c(0,11000),tres=256)

## Modified parameters for visualization
sj.den2 <- spattemp.density(sj.ppp,h=2e4,lambda=1000, 
                            tlim=c(0,11000),tres=256)

tims <- c(2000,4000,6000,8000,10000)
par(mfcol=c(2,3))
for(i in tims){ 
  plot(sj.den2,i,"conditional",override.par=FALSE,main=paste("cond.",i))
}

## Space-time slices:
tims <- seq(500,10500, by=500)
ntims = length(tims)
f.slice <- spattemp.slice(sj.den2,tt=tims)

## Output to netcdf (not working brilliantly if I'm honest)
for(i in 1:ntims){   
  dens.r = raster(f.slice$z.cond[[i]])
  if (i == 1) {
    dens.stk = stack(dens.r)
  } else {
    dens.stk = stack(dens.stk, dens.r)
  }
}

writeRaster(dens.stk, "dens.nc", format="netCDF", 
            varname = "lambda", overwrite=TRUE, bylayer=FALSE)
save(sj.den2, file="sj.den2.RData")
# writeRaster(dens.stk, "dens.grd")
