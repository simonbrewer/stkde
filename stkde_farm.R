## Make up and visualize a ST ppp object

library(rgdal)
library(rgeos)
library(spatstat)
library(maptools)
library(rts)
library(sparr)
library(dplyr)

## Window for analysis
cnty = readOGR("ut_counties/Counties.shp")
# plot(cnty)
# sj.sp = cnty[cnty$NAME =="SAN JUAN",]
# sj.sp = gSimplify(sj.sp, tol=0.01)
# plot(sj.sp)

## Data
dat = read.csv("data/DatesAssociatedWithFarming_040119.csv")
str(dat)
dat = dat %>% 
  filter(!is.na(UTMNorthing))

coordinates(dat) <- ~UTMEasting+UTMNorthing
plot(dat)
plot(cnty, add=TRUE)

# First convert boundary to owin object
y <- as(sj.sp, "SpatialPolygons")
# Then convert SpatialPolygons to owin class
# sj.owin <- as(y, "owin")
sj.owin <- owin(xrange = c(228000,620000), yrange = c(4090000,4450000))

# Now get site coordinates
dat.x <- coordinates(dat)[,1]
dat.y <- coordinates(dat)[,2]

# Finally make up ppp object using coordinates, tree names and owin
sj.ppp <- ppp(dat.x, dat.y,
                   window=sj.owin, marks=dat$CalBPMed)
plot(sj.ppp)
## Space time density with default settings
sj.den1 <- spattemp.density(sj.ppp,tres=500) 

## Plot and compare 
tims <- c(1000,1500,2000)
par(mfcol=c(2,3))
for(i in tims){ 
  plot(sj.den1,i,override.par=FALSE,fix.range=TRUE,main=paste("joint",i))
  plot(sj.den1,i,"conditional",override.par=FALSE,main=paste("cond.",i))
}

## Likelihood based parameter estimates
hlam <- LIK.spattemp(sj.ppp,tlim=c(0,3200),verbose=FALSE)
print(hlam)
# sj.den2 <- spattemp.density(sj.ppp,h=hlam[1],lambda=hlam[2], 
#                             tlim=c(500,2500),tres=128)

## Modified parameters for visualization
sj.den2 <- spattemp.density(sj.ppp,h=20000,lambda=250, 
                            tlim=c(0,3200),tres=64)

tims <- seq(500,2500,by=100)
par(mfcol=c(2,3))
for(i in tims){ 
  plot(sj.den1,i,"conditional",override.par=FALSE,main=paste("cond.",i))
}

## Space-time slices:
tims <- seq(0,3200, by=25)
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

writeRaster(dens.stk, "farm.dens.nc", format="netCDF", 
            varname = "lambda", overwrite=TRUE, bylayer=FALSE)
save(sj.den1, file="farm.den1.RData")
# writeRaster(dens.stk, "dens.grd")
