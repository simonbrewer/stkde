library(sparr)
data(burk)
burkcas <- burk$cases

burkden1 <- spattemp.density(burkcas,tres=128)
summary(burkden1)


hlam <- LIK.spattemp(burkcas,tlim=c(400,5900),verbose=FALSE)
burkden2 <- spattemp.density(burkcas,h=hlam[1],lambda=hlam[2],tlim=c(400,5900),tres=256)
summary(burkden2)
tims <- c(1000,2000,3500)
par(mfcol=c(2,3))
for(i in tims){ 
  plot(burkden2,i,override.par=FALSE,fix.range=TRUE,main=paste("joint",i))
  plot(burkden2,i,"conditional",override.par=FALSE,main=paste("cond.",i))
}


## Slice examples
data(fmd)
fmdcas <- fmd$cases
fmdcon <- fmd$controls

f <- spattemp.density(fmdcas,h=6,lambda=8)
g <- bivariate.density(fmdcon,h0=6)
rho <- spattemp.risk(f,g,tolerate=TRUE) 

f$tlim # requested slices must be in this range

# slicing 'stden' object
f.slice1 <- spattemp.slice(f,tt=50) # evaluation timestamp
f.slice2 <- spattemp.slice(f,tt=150.5) # interpolated timestamp
par(mfrow=c(2,2))
plot(f.slice1$z$'50')
plot(f.slice1$z.cond$'50')
plot(f.slice2$z$'150.5')
plot(f.slice2$z.cond$'150.5')

# slicing 'rrst' object
rho.slices <- spattemp.slice(rho,tt=c(50,150.5))
par(mfrow=c(2,2))
plot(rho.slices$rr$'50');tol.contour(rho.slices$P$'50',levels=0.05,add=TRUE)
plot(rho.slices$rr$'150.5');tol.contour(rho.slices$P$'150.5',levels=0.05,add=TRUE)
plot(rho.slices$rr.cond$'50');tol.contour(rho.slices$P.cond$'50',levels=0.05,add=TRUE)
plot(rho.slices$rr.cond$'150.5');tol.contour(rho.slices$P.cond$'150.5',levels=0.05,add=TRUE)
