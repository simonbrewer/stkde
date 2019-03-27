## Plot density slices
library(dplyr)
library(animation)
library(sparr)
library(rgdal)
library(raster)
library(classInt)
library(RColorBrewer)

load("benm.den2.RData")

## Window for analysis
cnty = readOGR("ut_counties/Counties.shp")
# plot(cnty)
sj.sp = cnty[cnty$NAME =="SAN JUAN",]
# sj.sp = gSimplify(sj.sp, tol=0.01)
plot(sj.sp)

## Get DEM
dem = raster("data/BENM_DEM.tif")

## Data
dat = read.csv("data/BENM_SiteSummary_032319.csv")
str(dat)
dat = dat %>% 
  filter(!is.na(UTM_N))

coordinates(dat) <- ~UTM_E+UTM_N
pdf("benm_dem_sites.pdf")
plot(dem)
plot(dat, add=TRUE, pch=16, cex=0.5)
plot(sj.sp, add=TRUE)
dev.off()

## Upscale the DEM to 100m
dem.c = aggregate(dem, fact=4)

## Hill shade
slope <- terrain(dem.c, opt='slope')
aspect <- terrain(dem.c, opt='aspect')
hill <- hillShade(slope, aspect, 40, 270)
plot(hill, col=grey(0:100/100), legend=FALSE)

tims2 <- seq(500,2500, by=25)
ntims2 = length(tims2)
f.slice <- spattemp.slice(sj.den2,tt=tims2)

# dens.stk = stack("benm.dens.nc")
# dens.stk = dens.stk * 1e6 ## Scale to km2

slice.r = raster(f.slice$z.cond[[1]]) #* 1e6
brks = classIntervals(c(getValues(dens.stk)), n = 9, style="kmeans", dataPrecision = 4)
my.palette <- brewer.pal(n = 9, name = "OrRd")

colcode <- findColours(brks, my.palette, digits = 3)
plot(hill, col=grey(0:100/100), legend=FALSE)
plot(slice.r, col = my.palette, breaks=brks$brks, 
     main=paste("Time:",tims2[1]),
     legend=FALSE, alpha=0.35, add=TRUE)
legend("topleft", legend = names(attr(colcode,"table")),
       fill = attr(colcode, "palette"), cex=0.8)
# stop()
saveGIF( {
  for (i in ntims2:1) {
    # for (i in 1:ntims2) {
    slice.r = raster(f.slice$z.cond[[i]]) #* 1e6
    slice.r = resample(slice.r, hill)
    plot(hill, col=grey(0:100/100), main=paste("Time:",tims2[i]),
         legend=FALSE)
    plot(slice.r, col = my.palette, breaks=brks$brks, 
         legend=FALSE, alpha=0.45, add=TRUE)
    # plot(sj.sp, add=TRUE)
    # legend("topleft", legend = names(attr(colcode,"table")),
    #        fill = attr(colcode, "palette"), cex=0.8)
  }
}, movie.name = "benm_dem_stkde.gif", interval = 0.25 )
