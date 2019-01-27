## Plot density slices
require(animation)
require(sparr)
require(rgdal)
library(raster)

load("sj.den2.RData")

## Window for analysis
cnty = readOGR("ut_counties/Counties.shp")
# plot(cnty)
sj.sp = cnty[cnty$NAME =="SAN JUAN",]
# sj.sp = gSimplify(sj.sp, tol=0.01)
plot(sj.sp)

tims2 <- seq(500,10500, by=100)
ntims2 = length(tims2)
f.slice <- spattemp.slice(sj.den2,tt=tims2)

slice.r = raster(f.slice$z.cond[[i]])
brks = classIntervals(c(getValues(dens.stk)), n = 9, style="kmeans")
my.palette <- brewer.pal(n = 9, name = "OrRd")
plot(slice.r, col = my.palette, breaks=brks$brks, main=paste("Time:",tims2[i]))

saveGIF( {
  for (i in ntims2:1) {
    # for (i in 1:ntims2) {
    slice.r = raster(f.slice$z.cond[[i]])
    plot(slice.r, col = my.palette, breaks=brks$brks, main=paste("Time:",tims2[i]))
    plot(sj.sp, add=TRUE)
  }
}, movie.name = "stkde2.gif", interval = 0.2 )