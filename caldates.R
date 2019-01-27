## Calibrate radiocarbon dates

library(Bchron)
library(ggplot2)

## Data
dat = read.csv("data/SJco_14C_Dates_Draft_012419.csv")
ndat = dim(dat)[1]
str(dat)

caldates = BchronCalibrate(dat$Date, dat$Error,
                           calCurves=rep('intcal13',ndat),
                           ids=paste0('Date-',1:ndat))
save(caldates, file="caldates.RData")

## Sample plot
plot.df = data.frame(ages = caldates$`Date-1`$ageGrid,
                     density = caldates$`Date-1`$densities)
ggplot(plot.df, aes(x=ages, y=density)) + geom_line() + theme_bw()
