## Plot density slices
require(animation)
require(sparr)
require(rgdal)
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

tims2 <- seq(500,2500, by=25)
ntims2 = length(tims2)
f.slice <- spattemp.slice(sj.den2,tt=tims2)

# dens.stk = stack("benm.dens.nc")
# dens.stk = dens.stk * 1e6 ## Scale to km2

slice.r = raster(f.slice$z.cond[[1]]) * 1e6
brks = classIntervals(c(getValues(dens.stk)), n = 9, style="kmeans", dataPrecision = 4)
my.palette <- brewer.pal(n = 9, name = "OrRd")

colcode <- findColours(brks, my.palette, digits = 3)
plot(slice.r, col = my.palette, breaks=brks$brks, 
     main=paste("Time:",tims2[1]),
     legend=FALSE)
legend("topleft", legend = names(attr(colcode,"table")),
       fill = attr(colcode, "palette"), cex=0.8)

saveGIF( {
  for (i in ntims2:1) {
    # for (i in 1:ntims2) {
    slice.r = raster(f.slice$z.cond[[i]]) * 1e6
    plot(slice.r, col = my.palette, breaks=brks$brks, 
         main=paste("Time:",tims2[i]),
         legend=FALSE)
    plot(sj.sp, add=TRUE)
    legend("topleft", legend = names(attr(colcode,"table")),
           fill = attr(colcode, "palette"), cex=0.8)
  }
}, movie.name = "benm_stkde.gif", interval = 0.25 )
