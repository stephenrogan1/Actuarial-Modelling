# MTH1000 Class Test 2025-2026 Solutions
# Actuarial Modelling
# Date: 18 November 2025

# ============================================================================
# QUESTION 1: AM92 Mortality Table
# ============================================================================

cat("\n=== QUESTION 1 ===\n")

# Part (i): Function to calculate μx
calculate_mu_x <- function(x) {
  # Constants
  a0 <- 0.00005887
  a1 <- -0.0004988  # Note: PDF shows a0 again but should be a1
  b0 <- -4.363378
  b1 <- 5.544956
  b2 <- -0.620345
  
  # Calculate t
  t <- (x - 70) / 50
  
  # Calculate μx
  mu_x <- a0 + a1 * t + exp(b0 + b1 * t + b2 * (2 * t^2 - 1))
  
  return(mu_x)
}

# Test the function
cat("\n(i) Testing calculate_mu_x function:\n")
cat("μ_35 =", calculate_mu_x(35), "\n")
cat("μ_70 =", calculate_mu_x(70), "\n")

# Part (ii): Calculate curtate expectation of life e_35
# Given: q_x ≈ 1 - exp(-μ_(x+1/2))

calculate_q_x <- function(x) {
  mu_x_half <- calculate_mu_x(x + 0.5)
  q_x <- 1 - exp(-mu_x_half)
  return(q_x)
}

# Calculate e_35
calculate_curtate_expectation <- function(start_age, max_age = 120) {
  e_x <- 0
  l_x <- 1  # Start with l_35 = 1
  
  for (age in start_age:(max_age - 1)) {
    q_age <- calculate_q_x(age)
    p_age <- 1 - q_age
    l_x <- l_x * p_age
    e_x <- e_x + l_x
  }
  
  return(e_x)
}

cat("\n(ii) Curtate expectation of life:\n")
e_35 <- calculate_curtate_expectation(35)
cat("e_35 =", e_35, "\n")


# ============================================================================
# QUESTION 2: Weibull Distribution and Hazard Functions
# ============================================================================

cat("\n=== QUESTION 2 ===\n")

# Part (i)(a): Generate sample of T_40 from Weibull distribution
# W(α, β) where α = 0.00002, β = 3.6
set.seed(100)
alpha <- 0.00002
beta <- 3.6
sims <- rweibull(10000, shape = beta, scale = (1/alpha)^(1/beta))

cat("\n(i)(a) Generated 10,000 simulated values of T_40\n")
cat("First 10 values:", head(sims, 10), "\n")
cat("Mean:", mean(sims), "\n")
cat("Median:", median(sims), "\n")

# Part (i)(b): Estimate P(T_40 > 10)
prob_T40_gt_10 <- mean(sims > 10)
cat("\n(i)(b) Estimated P(T_40 > 10) =", prob_T40_gt_10, "\n")

# Part (ii)(a): Function to calculate μ_x for x ≥ 40
# μ_(40+t) = αβt^(β-1)
calculate_mu_x_weibull <- function(x, alpha = 0.00002, beta = 3.6) {
  if (x < 40) {
    stop("Age must be >= 40")
  }
  t <- x - 40
  mu_x <- alpha * beta * t^(beta - 1)
  return(mu_x)
}

cat("\n(ii)(a) Testing calculate_mu_x_weibull function:\n")
cat("μ_40 =", calculate_mu_x_weibull(40), "\n")
cat("μ_50 =", calculate_mu_x_weibull(50), "\n")

# Part (ii)(b): Calculate P(T_50 > 10)
# For Weibull distribution starting at age 40: S(t) = exp(-α*t^β)
# We need P(T_50 > 10) which is P(life aged 50 survives 10 more years)
# This equals P(T_40 > 20) / P(T_40 > 10) by the memoryless property adjustment
# Or we can integrate the hazard function

# Calculate using the cumulative hazard
# P(T_50 > 10) = exp(-integral from 10 to 20 of μ_(40+t) dt)
# = exp(-integral from 10 to 20 of α*β*t^(β-1) dt)
# = exp(-α*[t^β] from 10 to 20)
# = exp(-α*(20^β - 10^β))

prob_T50_gt_10 <- exp(-alpha * (20^beta - 10^beta))

cat("\n(ii)(b) Calculated P(T_50 > 10) =", prob_T50_gt_10, "\n")

# Part (iii): Comment
cat("\n(iii) Comment on results:\n")
cat("Estimated P(T_40 > 10) from simulation:", prob_T40_gt_10, "\n")
cat("Calculated P(T_50 > 10) from formula:", prob_T50_gt_10, "\n")
cat("\nComparison:\n")
cat("- P(T_40 > 10) ≈", round(prob_T40_gt_10, 4), 
    "(probability of surviving 10 years from age 40)\n")
cat("- P(T_50 > 10) ≈", round(prob_T50_gt_10, 4), 
    "(probability of surviving 10 years from age 50)\n")
if (prob_T50_gt_10 < prob_T40_gt_10) {
  cat("\nP(T_50 > 10) is LOWER than P(T_40 > 10) because:\n")
  cat("- The hazard increases with age in the Weibull model (β > 1)\n")
  cat("- Older lives (age 50) face higher mortality than younger lives (age 40)\n")
  cat("- With β = 3.6 > 1, the hazard function is increasing\n")
} else {
  cat("\nP(T_50 > 10) is HIGHER than P(T_40 > 10) which seems counterintuitive.\n")
  cat("This may indicate a calculation issue or unusual model behavior.\n")
}


# ============================================================================
# QUESTION 3: Cox Proportional Hazards Models
# ============================================================================

cat("\n=== QUESTION 3 ===\n")

# Part (i): Construct data frame
# Create data based on the table:
# Complete circuits | Males          | Females
# 1                 | 21, 20         |
# 2                 |                | 30
# 3                 |                | 24, 25
# 4                 | 18, 18, 17     | 19
# 5                 |                |
# 6                 | 21             |

recruits <- data.frame(
  Age = c(21, 20, 30, 24, 25, 18, 18, 17, 19, 21),
  Sex = c("Male", "Male", "Female", "Female", "Female", 
          "Male", "Male", "Male", "Female", "Male"),
  Circuits = c(1, 1, 2, 3, 3, 4, 4, 4, 4, 6),
  Status = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
)

# Create binary sex variable (0 for males, 1 for females)
recruits$z1 <- ifelse(recruits$Sex == "Female", 1, 0)

cat("\n(i) Data frame created:\n")
print(recruits)

# Install and load survival package for Cox models
if (!require(survival, quietly = TRUE)) {
  install.packages("survival", repos = "https://cloud.r-project.org")
  library(survival)
} else {
  library(survival)
}

# Part (ii): Fit Model 1
cat("\n(ii) Model 1: ln λ(t, z1) = ln λ0(t) + β1*z1\n")

# Create survival object
surv_obj <- Surv(time = recruits$Circuits, event = recruits$Status)

# Fit Model 1 (sex only)
model1 <- coxph(surv_obj ~ z1, data = recruits)
cat("\nModel 1 Summary:\n")
print(summary(model1))

beta1_model1 <- coef(model1)["z1"]
cat("\n(ii)(b) Estimated β1 =", beta1_model1, "\n")
cat("Interpretation: The coefficient is", beta1_model1, "\n")
cat("exp(β1) =", exp(beta1_model1), "\n")
cat("This suggests that females have a")
if (beta1_model1 > 0) {
  cat(" higher")
} else {
  cat(" lower")
}
cat(" hazard of dropping out compared to males.\n")
cat("The hazard ratio is", exp(beta1_model1), ", meaning females have a\n")
cat(abs(1 - exp(beta1_model1)) * 100, "% ", 
    ifelse(beta1_model1 > 0, "higher", "lower"), 
    " hazard of dropping out than males.\n")

# Part (iii): Fit Model 2
cat("\n(iii) Model 2: ln λ(t, z1, z2) = ln λ0(t) + β1*z1 + β2*z2\n")

# Fit Model 2 (sex and age)
model2 <- coxph(surv_obj ~ z1 + Age, data = recruits)
cat("\nModel 2 Summary:\n")
print(summary(model2))

beta1_model2 <- coef(model2)["z1"]
beta2_model2 <- coef(model2)["Age"]
cat("\n(iii)(b) Estimated β1 =", beta1_model2, "\n")
cat("Estimated β2 =", beta2_model2, "\n")
cat("\nInterpretation:\n")
cat("β1 (Sex): exp(β1) =", exp(beta1_model2), "\n")
cat("  After adjusting for age, females have a", 
    ifelse(beta1_model2 > 0, "higher", "lower"), 
    " hazard of dropping out.\n")
cat("β2 (Age): exp(β2) =", exp(beta2_model2), "\n")
cat("  For each additional year of age, the hazard of dropping out changes by\n")
cat("  a factor of", exp(beta2_model2), "\n")

# Part (iv): Compare models
cat("\n(iv) Model Comparison:\n")

# Likelihood ratio test
lr_test <- anova(model1, model2, test = "Chisq")
cat("\nLikelihood Ratio Test:\n")
print(lr_test)

# Extract p-value safely
if (nrow(lr_test) > 1 && !is.na(lr_test$`Pr(>|Chi|)`[2])) {
  p_value <- lr_test$`Pr(>|Chi|)`[2]
  cat("\nP-value:", p_value, "\n")
  
  if (p_value < 0.05) {
    cat("Conclusion: Model 2 is a SIGNIFICANT improvement over Model 1 (p < 0.05).\n")
    cat("Age is an important predictor of dropping out after accounting for sex.\n")
  } else {
    cat("Conclusion: Model 2 is NOT a significant improvement over Model 1 (p >= 0.05).\n")
    cat("Age does not significantly improve the model after accounting for sex.\n")
  }
} else {
  cat("\nP-value could not be extracted from likelihood ratio test.\n")
  cat("Based on the chi-square statistic, we can assess model improvement.\n")
}


# ============================================================================
# QUESTION 4: Markov Chain Models
# ============================================================================

cat("\n=== QUESTION 4 ===\n")

# Note: Since the markovchain package is not available due to network restrictions,
# we'll implement the functionality manually using matrix operations

# Part (i): Construct transition matrix
cat("\n(i) Constructing transition matrix:\n")

# Transition matrix
transition_matrix <- matrix(c(
  0.97, 0.029, 0.001,   # From H to H, S, D
  0.25, 0.70,  0.05,    # From S to H, S, D
  0,    0,     1        # From D to D (absorbing)
), byrow = TRUE, nrow = 3)

colnames(transition_matrix) <- c("H", "S", "D")
rownames(transition_matrix) <- c("H", "S", "D")

cat("\nTransition Matrix:\n")
print(transition_matrix)

# Part (ii): Probability of being sick at time 3 weeks given healthy now
cat("\n(ii) Probability of being sick at time 3 weeks:\n")

# Initial state: healthy
initial_state <- c(1, 0, 0)
names(initial_state) <- c("H", "S", "D")

# State after 3 weeks: multiply by transition matrix 3 times
# P^3 = P * P * P
P3 <- transition_matrix %*% transition_matrix %*% transition_matrix

cat("\nTransition matrix after 3 weeks (P^3):\n")
print(P3)

# State after 3 weeks starting from H
state_after_3 <- initial_state %*% P3
prob_sick_at_3 <- state_after_3[1, "S"]

cat("\nP(Sick at week 3 | Healthy now) =", prob_sick_at_3, "\n")

# Part (iii): Probability of being sick at some point in next 52 weeks
cat("\n(iii) Probability of being sick at some point in next 52 weeks:\n")

# We calculate P(ever sick in 52 weeks) = 1 - P(never sick in 52 weeks)
# P(never sick) = P(only in H or D, never in S)

# To calculate this, we modify the transition matrix to make S absorbing
# and calculate the probability of being in S after 52 weeks
trans_S_absorbing <- transition_matrix
trans_S_absorbing["S", ] <- c(0, 1, 0)  # Make S absorbing
trans_S_absorbing["D", ] <- c(0, 0, 1)  # D already absorbing

# Calculate P^52 with S absorbing
P52_absorbing <- trans_S_absorbing
for (i in 1:51) {
  P52_absorbing <- P52_absorbing %*% trans_S_absorbing
}

state_after_52_absorbing <- initial_state %*% P52_absorbing
prob_ever_sick <- state_after_52_absorbing[1, "S"]

cat("P(Sick at some point in 52 weeks | Healthy now) =", prob_ever_sick, "\n")

# Part (iv): Probability of remaining healthy for entire year
cat("\n(iv) Probability of remaining healthy for entire year:\n")

# Calculate P^52
P52 <- transition_matrix
for (i in 1:51) {
  P52 <- P52 %*% transition_matrix
}

state_after_52 <- initial_state %*% P52
prob_healthy_all_year <- state_after_52[1, "H"]

cat("P(Healthy for all 52 weeks | Healthy now) =", prob_healthy_all_year, "\n")

# Part (v): Explain why μ_HS = b*i_t
cat("\n(v) Explanation for μ_HS = b*i_t:\n")
cat("Setting μ_HS = b*i_t (where i_t is the proportion of sick individuals) makes sense because:\n")
cat("- The rate of infection depends on the prevalence of the disease in the population\n")
cat("- More sick people means higher chance of contact and transmission\n")
cat("- This models contagion effects common in infectious diseases\n")
cat("- A constant rate would not capture the epidemic dynamics\n")
cat("- This is similar to SIR/SEIR epidemic models where transmission depends on contacts\n")
cat("- As the number of sick people increases, healthy people are more likely to become infected\n")

# Part (vi): High b scenario
cat("\n(vi) Example scenario with high b value:\n")
cat("A high value of b would be expected in scenarios such as:\n")
cat("- A highly contagious respiratory disease (like measles or COVID-19)\n")
cat("- Crowded living conditions (e.g., nursing homes, dormitories, cruise ships)\n")
cat("- Environments with high contact rates (schools, offices, public transport)\n")
cat("- Diseases with airborne transmission in enclosed spaces\n")
cat("- Lack of preventive measures (no masks, no social distancing, no ventilation)\n")
cat("- High population density areas with poor hygiene\n")

# Part (vii): Markov jump model - calculate occupancy probabilities
cat("\n(vii) Calculating occupancy probabilities for Markov jump model:\n")

# Parameters
b <- 0.35
mu_SD <- 0.05  # per day
mu_SR <- 0.14  # per day
dt <- 0.01  # step length in days
max_time <- 100  # days

# Initial conditions
# At t=0: 1% sick, 99% healthy
p_H <- 0.99
p_S <- 0.01
p_R <- 0.00
p_D <- 0.00

# Matrix to store results
n_steps <- max_time / dt
occupancy <- matrix(0, nrow = n_steps, ncol = 5)
colnames(occupancy) <- c("time", "H", "S", "R", "D")

# Calculate occupancy probabilities using Euler method
for (i in 1:n_steps) {
  t <- i * dt
  
  # Current proportion sick (for calculating mu_HS)
  i_t <- p_S
  mu_HS <- b * i_t
  
  # Calculate changes
  dp_H <- -mu_HS * p_H * dt
  dp_S <- (mu_HS * p_H - mu_SD * p_S - mu_SR * p_S) * dt
  dp_R <- mu_SR * p_S * dt
  dp_D <- mu_SD * p_S * dt
  
  # Update probabilities
  p_H <- p_H + dp_H
  p_S <- p_S + dp_S
  p_R <- p_R + dp_R
  p_D <- p_D + dp_D
  
  # Store results
  occupancy[i, ] <- c(t, p_H, p_S, p_R, p_D)
}

cat("Occupancy probabilities calculated from t =", dt, "to t =", max_time, "days\n")
cat("\nFirst 10 rows:\n")
print(head(occupancy, 10))
cat("\nLast 10 rows:\n")
print(tail(occupancy, 10))

# Part (viii): Plot the occupancy probabilities
cat("\n(viii) Plotting occupancy probabilities:\n")

png("markov_jump_model_plot.png", width = 800, height = 600)
plot(occupancy[, "time"], occupancy[, "H"], type = "l", col = "green", lwd = 2,
     xlab = "Time (days)", ylab = "Probability",
     main = "Markov Jump Model: State Occupancy Probabilities",
     ylim = c(0, 1))
lines(occupancy[, "time"], occupancy[, "S"], col = "red", lwd = 2)
lines(occupancy[, "time"], occupancy[, "R"], col = "blue", lwd = 2)
lines(occupancy[, "time"], occupancy[, "D"], col = "black", lwd = 2)
legend("right", legend = c("Healthy (H)", "Sick (S)", "Recovered (R)", "Dead (D)"),
       col = c("green", "red", "blue", "black"), lwd = 2)
grid()
dev.off()

cat("Plot saved to markov_jump_model_plot.png\n")

# Part (ix): Probabilities at specific times
cat("\n(ix) Probabilities of being sick:\n")

# Find indices for 6 days and 25 days
idx_6 <- which(abs(occupancy[, "time"] - 6) < dt/2)[1]
idx_25 <- which(abs(occupancy[, "time"] - 25) < dt/2)[1]

prob_sick_6 <- occupancy[idx_6, "S"]
prob_sick_25 <- occupancy[idx_25, "S"]

cat("(a) P(Sick after 6 days | Healthy at t=0) =", prob_sick_6, "\n")
cat("(b) P(Sick after 25 days | Healthy at t=0) =", prob_sick_25, "\n")

# Part (x): Expected present value
cat("\n(x) Expected present value of sick benefit:\n")

# EPV = sum over all time periods of: probability of being sick * daily benefit * discount factor
# Daily benefit = €1
# Force of interest = 5% p.a. = 0.05
# Discount factor at time t = exp(-δ*t) where δ = 0.05

delta <- 0.05
daily_benefit <- 1

epv <- 0
for (i in 1:n_steps) {
  t <- occupancy[i, "time"]
  p_sick <- occupancy[i, "S"]
  discount <- exp(-delta * t)
  # Add contribution from this time step
  epv <- epv + p_sick * daily_benefit * discount * dt
}

cat("Expected present value of €1 daily sick benefit = €", epv, "\n")

cat("\n=== ALL QUESTIONS COMPLETED ===\n")
