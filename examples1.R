## Examples from sparr

library(sparr)

data(burk)
burkcas <- burk$cases

## Calculate space-time density using default settings
## tres is the temporal resolution for the output (factor of 2?)
burkden1 <- spattemp.density(burkcas,tres=128) 
summary(burkden1)

## Estimate the bandwidths using cross-validated likelihood:
hlam <- LIK.spattemp(burkcas,tlim=c(400,5900),verbose=FALSE)
print(hlam)

## Gives two bandwidths:
## h = spatial bandwidth
## lambda = temporal bandwidth
## tlim gives the bounds for temporal interpolation
burkden2 <- spattemp.density(burkcas,h=hlam[1],lambda=hlam[2], 
                             tlim=c(400,5900),tres=256)

## Plot output
## Shows difference between joint and conditional estimates. See: 
## Fernando, W.T.P.S. and Hazelton, M.L. (2014), 
## Generalizing the spatial relative risk function, 
## Spatial and Spatio-temporal Epidemiology, 8, 1-10.

tims <- c(1000,2000,3500)
par(mfcol=c(2,3))
for(i in tims){ 
  plot(burkden2,i,override.par=FALSE,fix.range=TRUE,main=paste("joint",i))
  plot(burkden2,i,"conditional",override.par=FALSE,main=paste("cond.",i))
}

