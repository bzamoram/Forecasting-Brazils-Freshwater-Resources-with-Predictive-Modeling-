# Forecasting Brazil's Freshwater Resources with Predictive Modeling

Time series forecasting analysis of Brazil's renewable internal freshwater resources using dynamic regression with ARIMA errors and scenario-based policy modeling.

## 🔗 Live Analysis Report

**[📊 View Full Interactive Report](https://bzamoram.github.io/YOUR-REPO-NAME/Forecasting-Brazils-Freshwater-Resources-with-Predictive-Modeling.html)**

## 🎯 Project Overview

This comprehensive forecasting project analyzes 31 years of historical data (1989-2019) to predict Brazil's renewable freshwater resources through 2029 and evaluate the impact of various cattle management policies on water sustainability.

### Key Findings

- **Historical Decline**: Brazil experienced a **51% decline** in renewable freshwater resources from 1989-2019 (-2.36% annually)
- **Business as Usual**: Continuing current trends would lead to a **22.5% additional decline** by 2029
- **Policy Impact**: A 3% annual cattle reduction could achieve **+42% resource recovery** by 2024
- **Optimal Strategy**: Aggressive cattle management can restore resources to mid-1990s levels within 5 years

## 📊 Analysis Highlights

### Dynamic Regression Modeling
- **Model 1** (Cattle Predictor): Successfully captured relationship between cattle populations and water resources
- **Model 2** (Withdrawals Predictor): Tested but deemed unreliable due to poor diagnostics
- **Technique**: ARIMA with external regressors for incorporating policy variables

### Scenario Analysis
Four policy scenarios were developed and forecasted:

| Scenario                    | Cattle Change | 2024 Impact | Outcome           |
|-----------------------------|---------------|-------------|-------------------|
| **Business as Usual**       | +1.34%/year   | -10.01%     | Continued decline |
| **Modest Reduction**        | -1.0%/year    | +19.12%     | Stabilization     |
| **Aggressive Reduction** ⭐ | -3.0%/year    | +41.92%    |  strong recovery  |  
| **Climate Action**          | -5.0%/year    | +62.92%     | Dramatic recovery |

### Interactive Visualizations
- Time series decomposition and trend analysis
- Scenario comparison plots with confidence intervals
- Geographic and temporal pattern exploration
- Executive-ready summary dashboards

## 🛠️ Technical Stack

**Time Series Analysis:**
- `fpp3` - Forecasting framework
- `forecast` - ARIMA modeling
- `tsibble` - Time series data structures
- `fable` - Tidy forecasting
- `feasts` - Feature extraction and statistics

**Data Manipulation:**
- `tidyverse` - Data wrangling (dplyr, tidyr, ggplot2)
- `lubridate` - Date/time handling

**Statistical Testing:**
- `urca` - Unit root tests (KPSS)
- Ljung-Box autocorrelation tests
- Residual diagnostics

**Visualization:**
- `ggplot2` - Statistical graphics
- `plotly` - Interactive plots
- `patchwork` - Multi-panel layouts

**Reporting:**
- R Markdown - Reproducible analysis
- `knitr` - Dynamic document generation
- `kableExtra` - Publication-quality tables

## 🚀 Reproducibility

### Prerequisites

```r
# Install required packages
install.packages(c(
  "fpp3", "forecast", "tsibble", "fable", "feasts", 
  "tidyverse", "lubridate", "urca", "plotly", 
  "knitr", "kableExtra", "patchwork"
))
```

```r
# Open R Markdown file
file.edit("Forecasting-Brazils-Freshwater-Resources-with-Predictive-Modeling.Rmd")

# Knit to HTML
rmarkdown::render("Forecasting-Brazils-Freshwater-Resources-with-Predictive-Modeling.Rmd")
```

📈 Methodology

Data Sources
  - World Bank: Global population data
  - Our World in Data:
    - Renewable freshwater resources per capita
    - Cattle livestock counts
    - Annual freshwater withdrawals

Feature Engineering

Created Renewable.internal.freshwater.resources..cubic.meters by:

```{r}
Resources = Resources_per_capita / Population
```
This removes population growth effects to isolate absolute resource changes.

Modeling Approach
1. Stationarity Testing: KPSS unit root tests on differenced series
2. Dynamic Regression: ARIMA models with external predictors

```{r}
ARIMA(freshwater ~ cattle_numbers)
```
3. Model Validation: Residual diagnostics, Ljung-Box tests, AIC comparison
4. Scenario Forecasting: Future cattle projections feed into freshwater predictions
5. Uncertainty Quantification: 80% and 95% prediction intervals

Key Techniques Demonstrated
✅ Time series decomposition and trend analysis
✅ Dynamic regression with external regressors
✅ ARIMA model selection and validation
✅ Scenario-based forecasting
✅ Policy impact quantification
✅ Statistical hypothesis testing
✅ Data storytelling and visualization

💡 Business Impact
Problem: Brazil faces accelerating freshwater depletion (-51% over 30 years) threatening water security, agriculture, and economic stability.

Solution: Quantified the relationship between cattle management and water resources, enabling evidence-based policy decisions.

Value Delivered:
  - Identified that 3% annual cattle reduction can reverse three decades of decline within 5 years
  - Provided decision-ready scenarios with quantified outcomes
  - Demonstrated that environmental recovery is achievable, not just theoretical
  - Created framework for monitoring policy effectiveness

🏆 Project Outcomes

This analysis demonstrates:
  - Technical depth: Advanced time series modeling with multiple validation approaches
  - Business acumen: Translating statistical findings into actionable policy recommendations
  - Communication skills: Creating accessible reports for technical and executive audiences
  - Problem-solving: Identifying Model 2 flaws and adapting methodology
  - Impact focus: Quantifying real-world outcomes of policy interventions