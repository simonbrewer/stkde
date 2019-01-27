## Attempt at plotting 3D volume of space-time kernel
## Not working very well ATM

library(plot3D)
library(raster)

tims <- seq(500,10500, by=500)
ntims = length(tims)

for(i in 1:ntims){   
  r = raster("dens.nc", varname=paste0("Band",i))
  if (i == 1) {
    dens.stk = stack(r)
  } else {
    dens.stk = stack(dens.stk, r)
  }
}


stop()
## Example code from plot3D library
par(mfrow = c(1, 2))
x <- y <- z <- seq(-4, 4, by = 0.2)
M <- mesh(x, y, z)
R <- with (M, sqrt(x^2 + y^2 +z^2))
p <- sin(2*R)/(R+1e-3)
slice3D(x, y, z, colvar = p,
        xs = 0, ys = c(-4, 0, 4), zs = NULL)
isosurf3D(x, y, z, colvar = p, level = -0.2, col = "red")
