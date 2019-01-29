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
nbit = 10

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
tims <- seq(500, 10500, by=500)
ntims = length(tims)

## Parameters for kernel: 1: spatial; 2: temporal
hlam <- c(2e4, 1e3) ## Smooth
hlam <- c(1e4, 500) ## Simplify

## Parameters for kernel: 1: spatial; 2: temporal
tims2 <- seq(500, 10500, by=50)
tdens = matrix(NA, nrow = length(tims2), ncol = nbit)

for (i in 1:nbit) {
  print(paste("IT:",i))
  sj.den2 <- spattemp.density(sj.ppp, tt = caldates.rnd[i,],
                              h = hlam[1], lambda = hlam[2], 
                              tlim = c(0,12000), tres = 256)
  tdens[,i] <- approx(sj.den2$temporal.z$x, sj.den2$temporal.z$y, tims2)$y
  
  ## Get time slices
  sj.slice1 <- spattemp.slice(sj.den2, tt=tims)
  
  if (i == 1) {
    sj.slice = sj.slice1$z.cond
  } else {
    for (j in 1:ntims) {
      sj.slice[[j]] = sj.slice[[j]] + sj.slice1$z.cond[[j]]
    }
  }
  
}

stop()