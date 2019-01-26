## Make up and visualize a ppp object

library(rgdal)
library(rgeos)
library(spatstat)
library(maptools)
library(rts)

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

# First convert boundary to owin object
y <- as(sj.sp, "SpatialPolygons")
# Then convert SpatialPolygons to owin class
sj.owin <- as(y, "owin")

# Now get site coordinates
dat.x <- coordinates(dat)[,1]
dat.y <- coordinates(dat)[,2]

# Finally make up ppp object using coordinates, tree names and owin
sj.ppp <- ppp(dat.x, dat.y,
                   window=sj.owin, marks=dat$median)

sj.den1 <- spattemp.density(sj.ppp,tres=500) 

tims <- c(2000,4000,6000)
par(mfcol=c(2,3))
for(i in tims){ 
  plot(sj.den1,i,override.par=FALSE,fix.range=TRUE,main=paste("joint",i))
  plot(sj.den1,i,"conditional",override.par=FALSE,main=paste("cond.",i))
}

tims <- c(2000,4000,6000,8000,10000)
par(mfcol=c(2,3))
for(i in tims){ 
  plot(sj.den1,i,"conditional",override.par=FALSE,main=paste("cond.",i))
}

## Likelihood based parameter estimates
hlam <- LIK.spattemp(sj.ppp,tlim=c(0,11000),verbose=FALSE)
print(hlam)
sj.den2 <- spattemp.density(sj.ppp,h=hlam[1],lambda=hlam[2], 
                            tlim=c(0,11000),tres=256)
sj.den2 <- spattemp.density(sj.ppp,h=1.5e4,lambda=500, 
                            tlim=c(0,11000),tres=256)

tims <- c(2000,4000,6000,8000,10000)
par(mfcol=c(2,3))
for(i in tims){ 
  plot(sj.den2,i,"conditional",override.par=FALSE,main=paste("cond.",i))
}


tims <- seq(500,10500, by=500)
ntims = length(tims)
f.slice <- spattemp.slice(sj.den1,tt=tims)

for(i in 1:ntims){   
  dens.r = raster(f.slice$z.cond[[i]])
  if (i == 1) {
    dens.stk = stack(dens.r)
  } else {
    dens.stk = stack(dens.stk, dens.r)
  }
}

dens.stk = setZ(brick(dens.stk), tims)
names(dens.stk) <- paste0("time_",tims)
writeRaster(dens.stk, "dens.nc", format="netCDF", 
            varname = "lambda", overwrite=TRUE)
