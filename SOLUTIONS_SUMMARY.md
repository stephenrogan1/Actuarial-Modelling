# MTH1000 Class Test Solutions - Summary

This repository contains complete R code solutions for the MTH1000 Class Test (18 November 2025).

## File Structure

- `class_test_solutions.R` - Main R script with all solutions
- `MTH1000 Class Test 2025 - 2026.pdf` - Original test questions
- `markov_jump_model_plot.png` - Visualization for Question 4 Part (viii)

## How to Run

```r
# Run the complete solution file
Rscript class_test_solutions.R
```

## Solutions Summary

### Question 1: AM92 Mortality Table
- Implemented function to calculate μₓ using the AM92 formula
- Calculated curtate expectation of life: **e₃₅ = 43.91 years**

### Question 2: Weibull Distribution
- Simulated 10,000 values from W(0.00002, 3.6)
- Estimated **P(T₄₀ > 10) = 0.9232**
- Calculated **P(T₅₀ > 10) = 0.4124**
- Analysis shows decreasing survival probability with age (β > 1)

### Question 3: Cox Proportional Hazards Models
- Created data frame with 10 army recruits
- Model 1 (sex only): **β₁ = 0.638** (females 89% higher hazard)
- Model 2 (sex + age): **β₁ = 0.208, β₂ = 0.129**
- Likelihood ratio test: **p = 0.299** (Model 2 not significant improvement)

### Question 4: Markov Chain/Jump Models

#### Markov Chain (Parts i-iv):
- **P(sick at 3 weeks | healthy now) = 0.0614**
- **P(sick sometime in 52 weeks | healthy now) = 0.768**
- **P(healthy entire year | healthy now) = 0.697**

#### Markov Jump Model (Parts v-x):
- Implemented epidemic model with states: H, S, R, D
- Used Euler method with dt = 0.01 days for 100 days
- **P(sick at 6 days) = 0.0248**
- **P(sick at 25 days) = 0.131**
- **Expected Present Value of sick benefit = €1.13**
- Generated visualization showing state transitions over time

## Key Features

1. **Comprehensive Coverage**: All parts of all 4 questions answered
2. **Proper R Functions**: Modular, reusable functions for calculations
3. **Detailed Output**: Clear explanations and interpretations
4. **Visualization**: Professional plot for Markov jump model
5. **Statistical Analysis**: Cox models fitted using survival package

## Dependencies

The script requires:
- Base R (version 4.0+)
- `survival` package (for Cox models)

Note: The `markovchain` package was specified in the test but implemented manually due to installation constraints.

## Author

Solutions prepared for MTH1000 Actuarial Modelling coursework.
