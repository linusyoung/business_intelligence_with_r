#####################################################################
# Business Intelligence with R
# Dwight Barry
# Chapter 4 Code: Know Thy Data (EDA)
#
# https://github.com/Rmadillo/business_intelligence_with_r/blob/master/manuscript/code/BIWR_Chapter_4_Code.R
#
######################################################################

require(ggplot2)
require(scales)

# Useful ggplot2 websites
# http://www.rstudio.com/wp-content/uploads/2015/12/ggplot2-cheatsheet-2.0.pdf
# http://www.cookbook-r.com/Graphs/
# http://www.computerworld.com/article/2935394/business-intelligence/my-ggplot2-cheat-sheet-search-by-task.html
# http://zevross.com/blog/2014/08/04/beautiful-plotting-in-r-a-ggplot2-cheatsheet-3/


# Acquire the bike share data and set factor levels
download.file("http://archive.ics.uci.edu/ml/machine-learning-databases/00275/Bike-Sharing-Dataset.zip", "Bike-Sharing-Dataset.zip")

bike_share_daily = read.table(unz("Bike-Sharing-Dataset.zip", "day.csv"), colClasses=c("character", "Date", "factor", "factor", "factor", "factor", "factor", "factor", "factor", "numeric", "numeric", "numeric", "numeric", "integer", "integer", "integer"), sep=",", header=TRUE)

levels(bike_share_daily$season) = c("Winter", "Spring", "Summer", "Fall")

levels(bike_share_daily$workingday) = c("No", "Yes")

levels(bike_share_daily$holiday) = c("No", "Yes")

bike_share_daily$mnth = ordered(bike_share_daily$mnth, 1:12)

levels(bike_share_daily$mnth) = c(month.abb)

levels(bike_share_daily$yr) = c(2011, 2012)


## Creating summary plots

### Everything at once: ggpairs

require(GGally)

ggpairs(data=bike_share_daily, columns=c(14:15, 10, 13, 3, 7), title="Daily Bike Sharing Data", axisLabels="show", mapping=aes(color = season, alpha=0.3))


### Create histograms of all numeric variables in one plot

require(psych)

multi.hist(bike_share_daily[,sapply(bike_share_daily, is.numeric)])


### A better "pairs" plot

pairs.panels(bike_share_daily[,sapply(bike_share_daily, is.numeric)], ellipses=FALSE, pch=".", las=2, cex.axis=0.7, method="kendall")


### Mosaic plots: "Scatterplots" for categorical data

require(vcd)

pairs(Titanic, highlighting=2)


## Plotting univariate distributions

### Histograms and density plots

ggplot(bike_share_daily, aes(casual)) +
  geom_density(col="blue", fill="blue", alpha=0.3) +
  xlab("Casual Use") +
  theme_bw()

ggplot(bike_share_daily, aes(casual)) +
  geom_histogram(col="blue", fill="blue", alpha=0.3) +
  xlab("Casual Use") +
  theme_bw()

ggplot(bike_share_daily, aes(casual)) +
  ylab("density and count") +
  xlab("Casual Use") +
  geom_histogram(aes(y=..density..), col="blue", fill="blue", alpha=0.3) +
  geom_density(col="blue", fill="blue", alpha=0.2) +
  theme_bw() +
  theme(axis.ticks.y = element_blank(), axis.text.y = element_blank())


### Bar and dot plots

ggplot(bike_share_daily, aes(weathersit)) +
  geom_bar(col="blue", fill="blue", alpha=0.3) +
  xlab("Weather Pattern") +
  scale_x_discrete(breaks=c(1, 2, 3), labels=c("Clear",
  "Cloudy/Rainy", "Stormy")) +
  theme_bw()

ggplot(bike_share_daily, aes(x=weathersit, y=..count..)) +
  geom_bar(stat="count", width=0.01) +
  geom_point(stat = "count", size=4, pch=21, fill="darkblue") +
  xlab("Weather Pattern") +
  scale_x_discrete(breaks=c(1, 2, 3), labels=c("Clear", 
  "Cloudy/Rainy", "Stormy")) +
  coord_flip() +
  theme_bw()


### Plotting multiple univariate distributions with faceting

ggplot(bike_share_daily, aes(casual, fill=season)) +
  geom_histogram(aes(y = ..density..), alpha=0.2, color="gray50") +
  geom_density(alpha=0.5, size=0.5) +
  facet_wrap(~season) +
  theme_light() +
  xlab("Daily Bike Use Count") +
  ylab("") +
  theme(legend.position="none") +
  theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(),
  axis.title = element_text(size=9, face=2, color="gray30"),
  axis.title.x = element_text(vjust=-0.5))

ggplot(bike_share_daily, aes(weathersit, fill=season)) +
  geom_bar(alpha=0.5) +
  xlab("") +
  ylab("Number of Days") +
  scale_x_discrete(breaks=c(1, 2, 3), labels=c("Clear", "Cloudy/Rainy", "Stormy")) +
  coord_flip() +
  facet_wrap(~season, ncol=1) +
  theme_light()


## Plotting bivariate and comparative distributions

require(ggExtra)
require(vcd)
require(beanplot)


### Double density plots

ggplot(bike_share_daily, aes(casual, fill=workingday, color=workingday)) +
  geom_density(alpha=0.4) +
  theme_minimal() +
  xlab("Daily Casual Bike Use Count") +
  ylab("") +
  scale_fill_discrete(name="Work Day?") +
  scale_color_discrete(name="Work Day?") +
  theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(), 
  legend.position="top")


### Boxplots

ggplot(bike_share_daily, aes(mnth, casual, fill=workingday)) +
  xlab("Month") +
  ylab("Daily Casual Bike Use Count") +
  geom_boxplot() +
  theme_minimal() +
  scale_fill_discrete(name="Work Day?") +
  scale_color_discrete(name="Work Day?") +
  theme(legend.position="bottom")


### Beanplots

beanplot(casual ~ mnth, data = bike_share_daily, side="first", overallline="median", what=c(1,1,1,0), col=c("gray70", "transparent", "transparent", "blue"), xlab = "Month", ylab = "Daily Casual Bike Use Count")

beanplot(casual ~ mnth, data = bike_share_daily, side="second", overallline="median", what=c(1,1,1,0), col=c("gray70", "transparent", "transparent", "blue"), ylab = "Month", xlab = "Daily Casual Bike Use Count", horizontal=TRUE)


### Scatterplots and marginal distributions

bike_air_temp = ggplot(bike_share_daily, aes(x=atemp, y=casual)) +
  xlab("Daily Mean Normalized Air Temperature") +
  ylab("Number of Total Casual Bike Uses") +
  geom_point(col="gray50") +
  theme_bw()

bike_air_temp_mh = ggMarginal(bike_air_temp, type="histogram")

bike_air_temp_mh

bike_air_temp_md = ggMarginal(bike_air_temp, type="density")

bike_air_temp_md

bike_air_temp_mb = ggMarginal(bike_air_temp, type="boxplot")

bike_air_temp_mb


### Mosaic plots

mosaic(~ weathersit + season, data=bike_share_daily, shade=T, legend=F, labeling_args = list(set_varnames = c(season = "Season", weathersit = "Primary Weather Pattern"), set_labels = list(weathersit = c("Clear", "Cloudy/Rainy",  "Stormy"))))


### Multiple bivariate comparisons with faceting

ggplot(bike_share_daily, aes(casual, fill=workingday, color=workingday)) +
  geom_density(alpha=0.4) +
  theme_minimal() +
  xlab("Daily Casual Bike Use Count") +
  ylab("") +
  scale_fill_discrete(name="Work Day?") +
  scale_color_discrete(name="Work Day?") +
  facet_wrap(~season, ncol=2) +
  theme(axis.ticks.y = element_blank(), axis.text.y = element_blank(), 
  legend.position="top")


## Pareto charts

library(qcc)

Readmits = c(148, 685, 16, 679, 192, 8, 1601, 37, 269, 48)
Dx = c('Septicemia', 'Cancer', 'Diabetes', 'Heart disease', 'Stroke', 'Aortic aneurysm', 'Pneumonia', 'Chronic liver disease', 'Nephritis/nephrosis', 'Injury/poisoning') 

pareto.chart(xtabs(Readmits ~ Dx), main='Pareto Chart for Unplanned Readmissions')


## Plotting survey data

require(likert)

# Create a likert object
mathiness = likert(mass[2:15])

# Plot the likert object
plot(mathiness)

# Create likert object with a grouping factor
gender_math = likert(items=mass[,c(4,6,15), drop=FALSE], grouping=mass$Gender)

# Grouped plot
plot(gender_math, include.histogram=TRUE)


## Obtaining summary and conditional statistics

require(psych)

describe(bike_share_daily[10:16])
  
describeBy(bike_share_daily[10:16], bike_share_daily$holiday)
  
table(bike_share_daily$holiday)

prop.table(table(bike_share_daily$holiday))

describeBy(bike_share_daily[14:16], bike_share_daily$season == "Winter")
  
describeBy(bike_share_daily[10:13], bike_share_daily$casual <= 1000)

describeBy(bike_share_daily$casual, bike_share_daily$windspeed > mean(bike_share_daily$windspeed))

sum(bike_share_daily$cnt > 500, na.rm=T)
    
sum(bike_share_daily$workingday == 'Yes')
  
table(bike_share_daily[c(3,6:7)]) 

addmargins(table(bike_share_daily[c(3,6:7)]))
  
prop.table(table(bike_share_daily[c(3,9)]))

require(dplyr)
summarize(group_by(bike_share_daily, season, holiday, weekday), count=n())


## Finding local maxima/minima
bike_share_daily[which.min(bike_share_daily[,14]),]

# Calculate density of casual bike use
casual_dens = data.frame(casual = density(bike_share_daily$casual)$x, 
  density_value = density(bike_share_daily$casual)$y)

# Mode / maximum density
casual_dens[which.max(casual_dens[,2]),]

# Plot histogram and density with mode as a line
ggplot(bike_share_daily, aes(casual)) +
  ylab("density and count") +
  xlab("Casual Use") +
  geom_histogram(aes(y=..density..), col="blue", fill="blue", alpha=0.3) +
  geom_density(col="blue", fill="blue", alpha=0.2) +
  theme_bw() +
  theme(axis.ticks.y = element_blank(), axis.text.y = element_blank()) +
  geom_vline(xintercept = dens[which.max(dens[,2]),1], color = "yellow")

## Inference on summary statistics

### Confidence intervals

# Median | asbio::ci.median(x) 
# Mean | t.test(x)$conf.int 
# Proportion | binom.test(x, n)$conf.int
# Count | poisson.test(x)$conf.int 
# Rate | poisson.test(x, n)$conf.int

# 95% CI for median daily casual bike use
asbio::ci.median(bike_share_daily$casual) 

# 95% CI for mean daily casual bike use
t.test(bike_share_daily$casual)$conf.int

# 95% CI for proportion of casual bike use of all rentals
binom.test(sum(bike_share_daily$casual), sum(bike_share_daily$cnt))$conf.int

# Subset data to winter only
bike_share_winter = filter(bike_share_daily, season == "Winter")

# 95% CI for count of winter casual bike use
poisson.test(sum(bike_share_winter$casual))$conf.int

# 95% CI for count of winter casual bike use per 1000 rentals
poisson.test(sum(bike_share_winter$casual), sum(bike_share_winter$cnt)/1000)$conf.int


## Bootstrapping

require(boot)

# Create the boot function
sd_boot_function = function(x,i){sd(x[i])}

# Run the bootstrapping
sd_boot = boot(PlantGrowth$weight, sd_boot_function, R=10000)

# Bootstrapped sd
sd(PlantGrowth$weight)

# 95% CI for bootstrapped sd 
boot.ci(sd_boot, type="bca")$bca[4:5]

# Example for 75th percentile
q75_function = function(x,i){quantile(x[i], probs=0.75)}

q75_boot = boot(PlantGrowth$weight, q75_function, R=10000)

quantile(PlantGrowth$weight, 0.75)

boot.ci(q75_boot, type="bca")$bca[4:5]

# Mean | Bootstrapped CI | (fun.data = mean_cl_boot, fun.args = list(conf.int = 0.95), ...)
# Mean | Normal CI | (fun.data = mean_cl_normal, fun.args = list(conf.int = 0.95), ...)
# Mean | Standard deviation | (fun.data = mean_sdl, fun.args = list(mult = 2), ...)
# Median | Quantile | (fun.data = median_hilow, fun.args = list(conf.int = 0.5), ...)

require(gridExtra)

p1 = ggplot(PlantGrowth, aes(group, weight)) +
  ggtitle("Bootstrapped") +
  stat_summary(fun.data = mean_cl_boot, fun.args=list(conf.int = 0.95)) 

p2 = ggplot(PlantGrowth, aes(group, weight)) +
  ggtitle("Normal") +
  stat_summary(fun.data = mean_cl_normal, fun.args=list(conf.int = 0.95)) 

p3 = ggplot(PlantGrowth, aes(group, weight)) +
  ggtitle("2 SDs") +
  stat_summary(fun.data = mean_sdl, fun.args=list(mult=2)) 

p4 = ggplot(PlantGrowth, aes(group, weight)) +
  ggtitle("Median+IQR") +
  stat_summary(fun.data = median_hilow, fun.args=list(conf.int = 0.5)) 

grid.arrange(p1, p2, p3, p4, nrow=2)


### Tolerance intervals

require(tolerance)

commute_time = c(68, 42, 40, 69, 46, 37, 68, 68, 69, 38, 51, 36, 50, 37, 41, 68, 59, 65, 67, 42, 67, 62, 48, 52, 52, 44, 65, 65, 46, 67, 62, 66, 43, 58, 45, 65, 60, 55, 48, 46)

commute_time_npti = nptol.int(commute_time, alpha=0.05, P=0.75, side=2)

commute_time_npti
  
plottol(commute_time_npti, commute_time, side="two", plot.type="both")

par(mfrow=c(1,1))

# Percent | bintol.int(x, n, m, …)
# Count or Rate | poistol.int(x, n, m, side, …)
# Nonparametric | nptol.int(x, …)
# Continuous | normtol.int(x, side, …)
# Continuous | uniftol.int(x, …) 
# Lifetime/survival | exptol.int(x, type.2, …) 
# Score | laptol.int(x, …) 
# Indicies | gamtol.int(x, …) 
# Reliability, extreme values | extol.int(x, dist, …) 


## Dealing with missing data

### Visualizing missing data

require(VIM)

data(tao)

# Rename the Sea.Surface.Temp column to make label fit on plot
colnames(tao)[4] = "Sea.Temp"

# Look at the data, esp. NAs
summary(tao)

# Plot missings (you can ignore the error message)
matrixplot(tao)

# Missing value summary values and plot
tao_aggr = aggr(tao)

tao_aggr

# Two-variable missingness comparisons
histMiss(tao[5:6])

histMiss(tao[c(6,5)])

marginplot(tao[5:6])

marginmatrix(tao[4:6])


### Imputation for missing values

# Perform k Nearest Neighbors imputation
# Result is new dataframe with imputed values
tao_knn = kNN(tao)

marginplot(tao_knn[c(5:6, 13:14)], delimiter="_imp")

marginmatrix(tao_knn[c(4:6, 12:14)], delimiter="_imp")

# Perform standard Iterative Robust Model-based Imputation
tao_irmi = irmi(tao)

# Perform robust Iterative Robust Model-based Imputation
tao_irmi_robust = irmi(tao, robust=TRUE)

# Create a mean-imputed air temp variable
tao$tao_airtemp_mean = ifelse(is.na(tao$Air.Temp), mean(tao$Air.Temp, na.rm=TRUE), tao$Air.Temp)

# Make a data frame of each air temp result
tao_compare_airtemp = data.frame(tao=tao[,5], tao_knn=tao_knn[,5], tao_irmi=tao_irmi[,5], tao_irmi_robust=tao_irmi_robust[,5], mean=tao[,9])

# Melt the various air temp results into a long data frame
require(reshape2)
tao_compare_melt = melt(tao_compare_airtemp, value.name="Air.Temp")

# Plot density histograms of each option and 
# add black dotted line to emphasize the original data
ggplot(tao_compare_melt, aes(Air.Temp, color=variable)) +
  geom_density(lwd=1.25) + 
  geom_density(data=subset(tao_compare_melt, variable=="tao"), 
  aes(Air.Temp), lty=3, lwd=1.5, color="black") +
  theme_minimal()


# More imputation in R: other packages
# http://cran.r-project.org/web/views/OfficialStatistics.html


##### End of File #####
