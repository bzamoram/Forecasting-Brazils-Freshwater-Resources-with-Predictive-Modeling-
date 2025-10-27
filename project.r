---
title: "Final_Project"
author: "Bryan Z"
date: "2023-11-25"
output:  
  bookdown::html_document2:
    toc: true
    fig_caption: true
---

```{r echo=FALSE, warning=FALSE, message=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(fpp3)
library(dplyr)
library(tidyr)
library(tidyxl)
library(tsibble)
library(tsibbledata)
library(fable)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(forecast)
library(fabletools)
library(feasts)
library(urca)
library(ldsr)
```

## Introduction 

James is a junior data analyst working in the sustainability analyst team at Clarkston Consulting, a consulting company in Rio, Brazil. Moreno (director of his floor) requests a forecast report on the Renewable Internal Freshwater Resources of Brazil for the next 10 years.

James is sent to Morticia for the data he will use. Then, he is provided a dataset titled: "Renewable internal freshwater resources per capita (cubic meters)" from the website "Our World in Data". He is left with a forecast report but not with the variables he could use to produce it. 

After doing some research, he finds out that renewable internal freshwater resources (cubic meters) is the internal renewable resources in the country, such as internal river flows and groundwater from rainfall. Besides, he realizes that accounting for this is important for assessing a region's water security, for sustainable agriculture practices or for early detection of drought conditions since climate change is all over the news nowadays. 

James realizes that he should not consider population count for this report since the company requesting the consulting service does not need the forecast based on the population but rather on the consumption on water withdrawals from industrial and agricultural processes. 

In order to conduct the forecast, James needs to do some feature engineering for the dataset provided by Morticia. He goes ahead and gets the worldwide population data from the World Bank in order to obtaining the Renewable Internal Freshwater Resources of Brazil without counting capita. Based on the initial dataset, he filters the now ready Renewable Internal Freshwater Resources of Brazil for the years 1989 to 2019 since these are the years stored for Brazil in the dataset provided. 

### Feature Engineering for Renewable Internal Freshwater Resources (cubic meters)

```{r, echo=FALSE}
#Population Data
population = read.csv('world-population.csv', header = TRUE, skip = 4)
#view(population) 
#print(names(population))
view(population)

population_long <- population |>
  pivot_longer(cols=-c('Country.Name', 'Country.Code',	'Indicator.Name',	'Indicator.Code'),
               names_to = "Year",
               values_to = "Population") |>
  mutate(Year = as.integer(str_remove(Year, "X")))
view(population_long)

filtered_population_long <- population_long |>
  filter(Country.Name == "Brazil" & Year >= 1989 & Year <= 2019) |>
  select(Year, Population)
# filtered_population_long

# str(filtered_population_long) 
```

```{r, echo=FALSE}
#Renewable Freshwater Data
renew_h2o = read.csv('renewable-water-resources-per-capita.csv', header = TRUE)
#view(renew_h2o) 

filtered_renew_h2o <- renew_h2o |>
  filter(Entity == "Brazil" & Year >= 1989 & Year <= 2019) |>
  select(Year, Renewable.internal.freshwater.resources.per.capita..cubic.meters.)
#filtered_renew_h2o

#str(filtered_renew_h2o)
```

```{r, echo=FALSE}
#Pure Feature Engineering
joined_data <- left_join(filtered_population_long, filtered_renew_h2o, by = "Year")
#joined_data

renew_h2o_clean <- joined_data %>%
  mutate(Renewable.internal.freshwater.resources..cubic.meters = 
           Renewable.internal.freshwater.resources.per.capita..cubic.meters. / Population) |>
  select(-Population, -Renewable.internal.freshwater.resources.per.capita..cubic.meters.)

ttsibble_data <- as_tsibble(renew_h2o_clean, index = Year)
ttsibble_data |> autoplot() +
  ggtitle("Renewable Internal Freshwater Resources Over Time") +
  xlab("Year") +
  ylab("Renewable Internal Freshwater Resources (cubic meters)")
ttsibble_data

# Calculate the annual percentage decrease
initial_count <- 0.0002584340
final_count <- 0.0001262151
initial_year <- 1989
final_year <- 2019

annual_percentage_decrease <- ((final_count / initial_count)^(1 / (final_year - initial_year)) - 1) * -100
#print(paste("Annual Percentage Decrease: ", round(annual_percentage_decrease, 2), "%"))

```

James quickly realizes that the renewable internal freshwater resources of Brazil have been declining over the years, especially since 1989 these resources had a value of 0.0002584340 cubic meters and for 2019 the number shrunk to 0.0001262151	cubic meters. This reflects an annual percentage decrease of 2.36 %. 

To continue, James realizes that two of the time series he will explore for the forecast report will be "Number of Cattle" and "Annual freshwater withdrawals" since these time series align with the requirements. 

The "Number of Cattle" dataset was extracted from "Our World in Data" and it indicates the number of animals of the species present in the country at the time of enumeration. It includes animals raised either for draft purposes or for meat, eggs and dairy production or kept for breeding. 

### Annual Cattle Number 

```{r, echo=FALSE}
cattle_heads = read.csv('cattle-livestock-count-heads.csv', header = TRUE)
#view(cattle_heads)

filtered_cattle_heads <- cattle_heads |>
  filter(Entity == "Brazil" & Year >= 1989 & Year <= 2019) |>
  select(Year, Cattle...00000866....Stocks...005111....animals)

ttsibble_data <- as_tsibble(filtered_cattle_heads, index = Year)
ttsibble_data |> autoplot()+
  ggtitle("Cattle Livestock Count in Brazil (1989-2019)") +
  xlab("Year") +
  ylab("Cattle Livestock Count")
ttsibble_data

# Calculate the annual percentage increase
initial_count <- 144154096
final_count <- 215008960
initial_year <- 1989
final_year <- 2019

annual_percentage_increase <- ((final_count / initial_count)^(1 / (final_year - initial_year)) - 1) * 100
#print(paste("Annual Percentage Increase: ", round(annual_percentage_increase, 2), "%"))
```

James reflects on the increasing cattle number in Brazil since 1989 to 2019. In 1989 the cattle count was 144154096 and for 2019 it counted for 215008960, meaning an annual percentage increase of 1.34 %.

The other time series,"Annual freshwater withdrawals", refers to total water withdrawals. It also includes water from desalination plants, agriculture (irrigation and livestock production), industry (cooling thermoelectric plants) and domestic uses (drinking water, municipal use or supply, use for public services, commercial establishments, and homes). 

### Annual Freshwater Withdrawals

```{r, echo=FALSE}
fresh_h2o = read.csv('annual-freshwater-withdrawals.csv', header = TRUE)
#view(fresh_h2o)

filtered_fresh_h2o <- fresh_h2o |>
  filter(Entity == "Brazil" & Year >= 1989 & Year <= 2019) |>
  select(Year, Annual.freshwater.withdrawals..total..billion.cubic.meters.)

ttsibble_data <- as_tsibble(filtered_fresh_h2o, index = Year)
ttsibble_data |> autoplot()+
  ggtitle("Annual Freshwater Withdrawals in Brazil (1989-2019)") +
  xlab("Year") +
  ylab("Annual Freshwater Withdrawals (billion cubic meters)")
ttsibble_data

# Calculate the annual percentage increase
initial_count <- 39446667000
final_count <- 70430000000
initial_year <- 1989
final_year <- 2019

annual_percentage_increase <- ((final_count / initial_count)^(1 / (final_year - initial_year)) - 1) * 100
#print(paste("Annual Percentage Increase: ", round(annual_percentage_increase, 2), "%"))
```

James reflects on the increasing freshwater withdrawals in Brazil since 1989 to 2019. In 1989 the water withdrawal was 39446667000 cubic meters and for 2019 it was 70430000000 cubic meters, meaning an annual percentage increase of 1.95 %.

Down below, the dataset that James creates with all the time series for his forecast report on the Renewable Internal Freshwater Resources of Brazil for the next 10 years.

## Joining Variables

```{r, echo=FALSE}
ultimate_joined_data <- left_join(renew_h2o_clean, filtered_cattle_heads, by = "Year")

#Creating the three datasets into a joined one
definitive_joined_data <- left_join(ultimate_joined_data, filtered_fresh_h2o, by = "Year")

#Making it a tsible object
ttsibble_data <- as_tsibble(definitive_joined_data, index = Year)
# ttsibble_data |> autoplot()
ttsibble_data
```

Once being ready, James decides on using Dynamic Regression with ARIMA Errors for his forecast report. 

## Dynamic Regression

To start off, he checks for the time series if they are stationary and finds out that they certainly are. 

#### Stationarity 

```{r, echo=FALSE}
ur.kpss(diff(diff(ttsibble_data$Renewable.internal.freshwater.resources..cubic.meters,lag = 1),lag = 1)) |> summary()
```

The test statistic (0.9723) is less than the critical values at all significance levels. Therefore, he fails to reject the null hypothesis stating that the time series is stationary, or, in other words, he accepts that the time series is stationary.

```{r, echo=FALSE}
ur.kpss(diff(diff(ttsibble_data$Cattle...00000866....Stocks...005111....animals,lag = 1),lag = 1)) |> summary()
```

The test statistic (0.045) is less than the critical values at all significance levels, which again, he fails to reject the null hypothesis indicating that the time series is stationary, or, in other words, he accepts that the time series is stationary.

```{r, echo=FALSE}
ur.kpss(diff(diff(ttsibble_data$Annual.freshwater.withdrawals..total..billion.cubic.meters.,lag = 1),lag = 1)) |> summary()
```

Once again, the test statistic (0.1532) is less than the critical values at all significance levels. Thus, he fails to reject the null hypothesis suggesting that the time series for Annual Freshwater Withdrawals is stationary. 

Now, it is time for James to fit the models and create forecasts for the future 10 years.

#### Model #1

```{r, echo=FALSE}
#Dynamic Regression with ARIMA Errors for Renewable Internal Freshwater and Cattle Number
fit_ren_fresh<- ttsibble_data |>
  model(ARIMA(Renewable.internal.freshwater.resources..cubic.meters ~ Cattle...00000866....Stocks...005111....animals)) |>
  report(fit_ren_fresh)
```

James modeled the time series "Renewable.internal.freshwater.resources..cubic.meters" using an ARIMA model with an external regressor, specifically the variable "Cattle...00000866....Stocks...005111....animals." The ARIMA component of the model was specified as ARIMA(0,0,0).

James, then, proceeded to evaluate the residuals as follows to provide insights into the model's performance.

```{r, echo=FALSE}
fit_ren_fresh |> augment() |>
  autoplot(.fitted,color = 'blue') +
  autolayer(ttsibble_data)+
  ggtitle("Fitted vs Observed - Renewable Internal Freshwater Resources") +
  xlab("Year") +
  ylab("Renewable Internal Freshwater Resources (cubic meters)")

fit_ren_fresh |> gg_tsresiduals()+
  labs(title = "Time Series Residuals",
       x = "Time",
       y = "Residuals")
augment(fit_ren_fresh) |> features(.innov, ljung_box, lag=14)
augment(fit_ren_fresh)
```

He founded that the model residuals have a normal distribution with mean of 0 and a very or almost none consistent variance since the points, on the top plot, does not reveal any variance. Ultimately, James sees no autocorrelation in the ACF since the fact that when running a Ljung-Box test he does not find significant autocorrelation (p-value is greater than the 0.05). There is a good performance from the model chosen. 

##### 10-Year Projection for Renewable Internal Freshwater Resources based on Cattle Numbers 

```{r, echo=FALSE}
##Forecast the next 10 years of data using the previous model
ren_fresh_arima <- ttsibble_data |>
  model(ARIMA(box_cox(Renewable.internal.freshwater.resources..cubic.meters,-0.8999)))

myLambda = guerrero(renew_h2o_clean$Renewable.internal.freshwater.resources..cubic.meters)
#myLambda

ren_fresh_arima |>
  forecast(h = "10 years") |> hilo()
```

James generated the 10-year forecast for "Renewable Internal Freshwater Resources" using an ARIMA model. He had to use a Box-Cox transformation with a lambda value of -0.8999 to stabilize variance and achieve a more normally distributed series. 

```{r}
ren_fresh_arima |>
  forecast(h = "10 years") |>
  autoplot(ttsibble_data, level = NULL) + labs(title = "10 years Forecast") +
  theme(plot.title = element_text(hjust = 0.5))
```

The forecasted values are visualized in the "10 years Forecast" plot above. The blue line represents the forecasted values, extending from 2020 to 2029. The shaded area around the line provides an indication of the uncertainty. 

James can now say that it is forecasted a gradual decrease in "Renewable Internal Freshwater Resources" over the next 10 years, with expected values ranging from 0.0001243450 in 2020 to 0.0001098164 in 2029. 

#### Model #2

```{r, echo=FALSE}
#Dynamic Regression with ARIMA Errors for renewable internal freshwater vs annual freshwater withdrawals 
fit_dyn_withdrawals = ttsibble_data |>
  model(ARIMA(Renewable.internal.freshwater.resources..cubic.meters ~ Annual.freshwater.withdrawals..total..billion.cubic.meters.)) |>
  report(fit_dyn_withdrawals)
```

James modeled the time series "Renewable.internal.freshwater.resources..cubic.meters" using an ARIMA model with an external regressor, specifically the variable "Annual.freshwater.withdrawals..total..billion.cubic.meters." The ARIMA component of the model was specified as ARIMA(0,0,0).

James, then, proceeded to evaluate the residuals as follows to provide insights into the model's performance.

```{r, echo=FALSE}
fit_dyn_withdrawals |> augment() |>
  autoplot(.fitted,color = 'blue') +
  autolayer(ttsibble_data)+
  ggtitle("Fitted vs Observed - Renewable Internal Freshwater Resources") +
  xlab("Year") +
  ylab("Renewable Internal Freshwater Resources (cubic meters)")

fit_dyn_withdrawals |> gg_tsresiduals()+
  labs(title = "Time Series Residuals",
       x = "Time",
       y = "Residuals")
augment(fit_dyn_withdrawals) |> features(.innov, ljung_box, lag=14)
augment(fit_dyn_withdrawals)

```

He founded that the model residuals have a normal distribution skewed to the left with mean of 0 and a very or almost none consistent variance since the points, on the top plot, does not reveal any variance. Ultimately, James sees no autocorrelation in the ACF since the fact that when running a Ljung-Box test he does not find significant autocorrelation (p-value is greater than the 0.05). There is a good performance from the model chosen.


##### 10-Year Projection for Renewable Internal Freshwater Resources based on Cattle Numbers 

```{r, echo=FALSE}
# ##Forecast the next 10 years of data using the previous model 
fit_dyn_withdrawals <- ttsibble_data |>
  model(ARIMA(box_cox(Renewable.internal.freshwater.resources..cubic.meters,-0.5)))

# ttsibble_data |> mutate(BC = box_cox(Annual.freshwater.withdrawals..total..billion.cubic.meters.,-0.5))|> ggplot(aes(x = Year, y = BC)) + geom_line() + ggtitle("Annual.freshwater.withdrawals with lambda of -0.5")

fit_dyn_withdrawals |> 
  forecast(h = "10 years") |> hilo()
``` 

James generated the 10-year forecast for "Renewable Internal Freshwater Resources" using an ARIMA model. He had to use a Box-Cox transformation with a lambda value of -0.5 to stabilize variance and achieve a more normally distributed series. 

```{r, echo=FALSE}
fit_dyn_withdrawals |>
  forecast(h = "10 years") |>
  autoplot(ttsibble_data, level = NULL) + labs(title = "10 years Forecast") +
  theme(plot.title = element_text(hjust = 0.5))
``` 

The forecasted values are visualized in the "10 years Forecast" plot above. The blue line represents the forecasted values, extending from 2020 to 2029. The shaded area around the line provides an indication of the uncertainty. 

James can now say that it is forecasted a gradual decrease in "Renewable Internal Freshwater Resources" over the next 10 years, with expected values ranging from 0.0001243533 in 2020 to 0.0001101646 in 2029. 
  
#### Scenarios 

##### Cattle Scenarios

James wonders what will happen if climate action efforts increases in Brazil over the years since CO2 levels are to be reduced. He creates forecasts for 2%, 5% and 10% decrease in cattle numbers for the next 3 years and shows the results down below: 

```{r, echo=FALSE}
# Calculating the numbers for the next 5 years with an increase of 3%
initial_value <- 215008960
percentage_increase <- 0.03
years <- 6

new_values_increase <- numeric(years)
new_values_increase[1] <- initial_value  

for (i in 2:years) {
  new_values_increase[i] <- new_values_increase[i - 1] * (1 + percentage_increase)
}
new_values_increase

#Future Scenarios with higher cattle numbers
future_scenarios = scenarios(
  StagnantCattle = new_data(ttsibble_data,5) |>
    mutate(Cattle...00000866....Stocks...005111....animals = c(221459229,228103006,234946096,241994479,249254313)),
  names_to = "Scenario")

fc = fit_ren_fresh |> forecast(new_data = future_scenarios, bootstrap = TRUE)
ttsibble_data |>
  autoplot(Renewable.internal.freshwater.resources..cubic.meters) +
  autolayer(fc)
fc
```

James learns that if the cattle numbers increase by 3% every year in the future, then the renewable freshwater will decrease in a great extent.

```{r, echo=FALSE}
# Calculating the numbers for the next 5 years with an decrease of 3%
initial_value <- 215008960
percentage_decrease <- 0.03
years <- 6

new_values_decrease <- numeric(years)
new_values_decrease[1] <- initial_value 

for (i in 2:years) {
  new_values_decrease[i] <- new_values_decrease[i - 1] * (1 - percentage_decrease)
}
new_values_decrease

##Future Scenarios with lower cattle numbers 
future_scenarios = scenarios(
  StagnantCattle = new_data(ttsibble_data,5) |>
    mutate(Cattle...00000866....Stocks...005111....animals = c(208558691,202301930,196232873,190345886,184635510)),
  names_to = "Scenario")
future_scenarios

fcc = fit_ren_fresh |> forecast(new_data = future_scenarios, bootstrap = TRUE)
ttsibble_data |>
  autoplot(Renewable.internal.freshwater.resources..cubic.meters) +
  autolayer(fcc)
fcc
```

James learns that if the cattle numbers decrease by 3% every year in the future, then the renewable freshwater will increase.

##### Freshwater Withdrawals Scenarios

At the same time, he wonders what would happen if the people in Brazil reduce their water withdrawals or what would happen if there is not any reductions instead. He creates a 3% forecast yearly increase and decrease for the following 6 years, which is shown next:

```{r, echo=FALSE}
# Calculating the numbers for the next 5 years with an increase of 3%
old_value_2019 <- 70430000000
percentage_increase <- 0.03
years <- 6

new_values_increase <- numeric(years)
new_values_increase[1] <- old_value_2019 

for (i in 2:years) {
  new_values_increase[i] <- new_values_increase[i - 1] * (1 + percentage_increase)
}
new_values_increase

##Future Scenarios with more fresh water withdrawals (no reductions)
future_scenarios = scenarios(
  StagnantWithdrawals = new_data(ttsibble_data,5) |>
    mutate(Annual.freshwater.withdrawals..total..billion.cubic.meters. = c(72542900000,74719187000,76960762610,79269585488,81647673053)),
  names_to = "Scenario")


fb = fit_dyn_withdrawals |> forecast(new_data = future_scenarios,bootstrap = TRUE)
ttsibble_data |>
  autoplot(Renewable.internal.freshwater.resources..cubic.meters) +
  autolayer(fb, h = "auto")
fb
```

James learns that if the freshwater withdrawals increase by 3% every year in the future, then the renewable freshwater will decrease, as expected.

```{r, echo=FALSE}
# Calculating the numbers for the next 5 years with an decrease of 3%
old_value_2019 <- 70430000000
percentage_decrease <- 0.03
years <- 6

new_values <- numeric(years)
new_values[1] <- old_value_2019

for (i in 2:years) {
  new_values[i] <- new_values[i - 1] * (1 - percentage_decrease)
}
new_values

##Future Scenarios with less fresh water withdrawals (some reductions)
future_scenarios = scenarios(
  StagnantWithdrawals = new_data(ttsibble_data,5) |>
    mutate(Annual.freshwater.withdrawals..total..billion.cubic.meters. = c(68317100000,66267587000,64279559390,62351172608,60480637430)),
  names_to = "Scenario")

fbb = fit_dyn_withdrawals |> forecast(new_data = future_scenarios,bootstrap = TRUE)
ttsibble_data |>
  autoplot(Renewable.internal.freshwater.resources..cubic.meters) +
  autolayer(fbb, h = "auto")
fbb
```

James learns that if the freshwater withdrawals decrease by 3% every year in the future, then the renewable freshwater will increase or keep stable.

## Conclusions

James informs his manager about the results, and basically he concludes that renewable freshwater resources is a delicate resource that is most likely to reduce over time, and that even when there are measurements to stop the number of cattles or mitigations for water withdrawals, the numbers of renewable freshwater resources will not reflect a huge change since the scale in which this time series in presented is quite big. Besides, for the next 10 years is expected to decrease, which is expected. 


## References:

https://ourworldindata.org/grapher/renewable-water-resources-per-capita?time=earliest..2019&country=BRA~OWID_WRL~USA~ARE

https://ourworldindata.org/grapher/annual-freshwater-withdrawals?tab=chart&country=OWID_WRL~BRA~USA

https://data.worldbank.org/indicator/SP.POP.TOTL?end=2019&locations=BR&start=1989&view=chart 

https://ourworldindata.org/grapher/cattle-livestock-count-heads?tab=chart&country=BRA~OWID_WRL 
