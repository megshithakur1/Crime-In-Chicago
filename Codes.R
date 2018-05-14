Codes

#read data
chi21.df=read.csv("Chicag.dat")
class(chi21.df)
head(chi21.df)

#change Chicag.dat data into ts object
chi21.ts=ts(chi21.df,start=c(2012,1),end=c(2016,9),frequency=12)
class(chi21.ts)
head(chi21.ts)
#plotting time series graph
plot(chi21.ts)

#Model 1
#Moving average decomposition, we will check for both multiplicative
#and additive.
chi21.da=decompose(chi21.ts,type='additive')
chi21.dm=decompose(chi21.ts,type='multiplicative')

#for additive part
predda=chi21.da$trend+chi21.da$seasonal
layout(1:1)
#plotting additive graph
plot(chi21.ts,lwd=2)
lines(predda,col='red',lwd=2)

#for multiplicative part
preddm=chi21.dm$trend+chi21.dm$seasonal
layout(1:1)
#plotting multiplicative graph
plot(chi21.ts,lwd=2)
lines(preddm,col='red',lwd=2)

#Model1 Part1
#check for the best fit using RMSE
#calculating RMSE for additive part 
chidaresid=window(chi21.da$random, start=c(2012,7),end=c(2016,3))
rmseda=sqrt(sum(chidaresid^2)/length(chidaresid))
cat("RMSE decomposition additive: ",rmseda)

#calculating RMSE for multiplicative part
chidmresid=window(chi21.dm$random, start=c(2012,7),end=c(2016,3))
rmsedm=sqrt(sum(chidmresid^2)/length(chidmresid))
cat("RMSE decomposition additive: ",rmsedm)

#Model1 Part2
#creating trend line graph to smoothed deseasonalized series
tr1=window(chi21.dm$trend, start=c(2012,7), end=c(2016,3))
tim1=time(tr1)
ti1=unclass(tim1)
#linear regression
trreg1=lm(tr1~ti1)
plot(tr1,lwd=2)
lines(ti1,fitted(trreg1),col='red',lwd=2)

#Model1 Part3
#predicting value using multiplicative part
predtime=c(2016.250,2016.333)
predtime
preddata=predict(trreg1,data.frame(ti1=predtime),se.fit=TRUE)
preddata$fit

# ACCURACY : Calculating accuracy
predti=c(2016.250)
prD=predict(trreg1,data.frame(ti1=predti),se.fit=TRUE)
prD$fit
predti1=c(2016.333)
prD1=predict(trreg1,data.frame(ti1=predti1),se.fit=TRUE)
prD1$fit
pred=data.frame(cbind(actuals=bdata1[52],predicteds=prD$fit))
pred
pred1=data.frame(cbind(actuals=bdata1[53],predicteds=prD1$fit))
pred1
corr=cor(pred)
head(pred)
min_max_accuracy1 <- mean(apply(pred, 1, min) / apply(pred, 1, max))  
 min_max_accuracy1
 min_max_accuracy2 <- mean(apply(pred1, 1, min) / apply(pred1, 1, max))
 min_max_accuracy2

#Model2 : Loess decomposition
chi21.stla=stl(chi21.ts,s.window='periodic')
str(chi21.stla)

class(chi21.stla$time.series[,'seasonal'])
plot(chi21.stla)

pred1=chi21.stla$time.series[,'seasonal'] + chi21.stla$time.series[,'trend']
plot(chi21.ts,lwd=2)
lines(pred1,col='red',lwd=2)
#multiplicative model
logchi.ts=log(chi21.ts)
plot(logchi.ts,ylab='log(Chicago_crime)')

chi21.stlm=stl(logchi.ts,s.window='periodic')
plot(chi21.stlm)

pred2=chi21.stlm$time.series[,'seasonal']+chi21.stlm$time.series[,'trend']
layout(1:1)
plot(logchi.ts,lwd=2)
lines(pred2,col='red',lwd=2)

#Model2 Part1
#Again calculating RMSE to find the best fit
#plotting remainder
plot(chi21.stla$time.series[,'remainder'],ylab='Remainder')
rmsed=sqrt(sum(chi21.stla$time.series[,'remainder']^2)/length(chi21.stla$time.series[,'remainder']))
rmsed

#plotting remainder
plot(chi21.stlm$time.series[,'remainder'],ylab='Remainder')
rmsedm=sqrt(sum(chi21.stlm$time.series[,'remainder']^2)/length(chi21.stlm$time.series[,'remainder']))
rmsedm

#Model2 Part2
#creating trend line graph to smoothed deseasonalized series

tr2=chi21.stlm$time.series[,'trend']
tim2=time(tr2)
ti2=unclass(tim2)
#perform linear regression
trreg2=lm(tr2~ti2)
plot(tr2,lwd=2)
lines(ti2,fitted(trreg2),col='red',lwd=2)

#Model2 Part3
#predicting the values for OCT & NOV 2016

predtime1=c(2016.250,2016.333)
predtime1
preddata1=predict(trreg2,data.frame(ti2=predtime),se.fit=TRUE)
preddata1
exp(preddata1$fit)

#ACCURACY
predti=c(2016.250)
prD=predict(trreg2,data.frame(ti2=predti),se.fit=TRUE)
exp(prD$fit)
predti1=c(2016.333)
prD1=predict(trreg2,data.frame(ti2=predti1),se.fit=TRUE)
exp(prD1$fit)
pred=data.frame(cbind(actuals=bdata1[52],predicteds=exp(prD$fit)))
pred
pred1=data.frame(cbind(actuals=bdata1[53],predicteds=exp(prD1$fit)))
pred1
corr=cor(pred)
head(pred)
min_max_accuracy1 <- mean(apply(pred, 1, min) / apply(pred, 1, max))  
 min_max_accuracy1
 min_max_accuracy2 <- mean(apply(pred1, 1, min) / apply(pred1, 1, max))
 min_max_accuracy2



#Model3: Regression Model

btime=unclass(time(chi21.ts))
bseas=cycle(chi21.ts)
bdata=coredata(chi21.ts)
chireg=lm(bdata~0+btime+factor(bseas))

boshat=fitted(chireg)
plot(chi21.ts,ylim=c(-5,550))
lines(btime,boshat,col='red')

#Model3 Part1
#use output and residual plot for checking fitness of model
ebos=resid(chireg)
plot(chireg)
hist(ebos)
acf(ebos)
AutocorTest(ebos,lag=1)
AutocorTest(ebos,lag=log(length(ebos)))

#Model1 Part2
#trying quadratic model, to check for assumptions
btime=unclass(time(chi21.ts))
chireg2=lm(bdata~0+btime+I(btime^2)+factor(bseas))
ebos2=resid(chireg2)
boshat2=fitted(chireg2)
plot(chi21.ts,ylim=c(-5,550))
lines(btime,boshat2,col='red')

plot(ebos2)
hist(ebos2)
#perform autocorrelation 
acf(ebos2)

AutocorTest(ebos2,lag=1)
AutocorTest(ebos2,lag=log(length(ebos2)))

plot(chireg2)
hist(ebos2)
acf(ebos2)
AutocorTest(ebos2,lag=1)
AutocorTest(ebos2,lag=log(length(ebos)))

#Model3 Part3
#predict the values 
predtime=c(2016.250,2016.333)
predseas=c(10,11)
predseas
preddata=predict(chireg2,data.frame(btime=predtime,bseas=predseas),se.fit=TRUE)
preddata$fit

##ACCURACY
predti=c(2016.250)
predseas1=c(10)
prD=predict(chireg2,data.frame(btime=predti,bseas=predseas1),se.fit=TRUE)
prD$fit
predti1=c(2016.333)
predseas2=c(11)
prD1=predict(chireg2,data.frame(btime=predti1,bseas=predseas2),se.fit=TRUE)
prD1$fit
pred=data.frame(cbind(actuals=bdata1[52],predicteds=prD$fit))
pred
pred1=data.frame(cbind(actuals=bdata1[53],predicteds=prD1$fit))
pred1
corr=cor(pred)
head(pred)
min_max_accuracy1 <- mean(apply(pred, 1, min) / apply(pred, 1, max))  
min_max_accuracy1
min_max_accuracy2 <- mean(apply(pred1, 1, min) / apply(pred1, 1, max))
min_max_accuracy2

#Model4 : Holt-Winter Model
hwmchi=HoltWinters(chi21.ts,seasonal='multiplicative')
hwmchi$fitted
plot(chi21.ts,lwd=2)
lines(hwmchi$fitted[,1],col='red',lwd=2)
#Check the residuals
plot(hwmchi,lyab='Residual')
#For addictive model
hwachi=HoltWinters(chi21.ts,seasonal='additive')
hwachi$fitted
plot(chi21.ts,lwd=2)
lines(hwachi$fitted[,1],col='red',lwd=2)

#Calculating RMSE
reshwmchi=chi21.ts-hwmchi$fitted[,'xhat']
rmse1=sqrt(sum(reshwmchi^2)/length(reshwmchi))
rmse1

reshwachi=chi21.ts-hwachi$fitted[,'xhat']
rmse2=sqrt(sum(reshwachi^2)/length(reshwachi))
rmse2

#Predicting the value for Oct and Nov 2016
p=predict(hwachi,n.ahead=2,prediction.interval=TRUE)
p
plot(hwachi,predicted.value=p)

