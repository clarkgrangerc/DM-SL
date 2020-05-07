### SIR Model TEXAS 

data=read.csv("texas.csv")


###### Fittting the SIR model
SIR <- function(time, state, parameters) {
  par <- as.list(c(state, parameters))
  with(par, {
    dS <- -beta * I * S / N
    dI <- beta * I * S / N - gamma * I
    dR <- gamma * I
    list(c(dS, dI, dR))
  })
}

sir_start_date <- "2020-03-05"
sir_end_date <- "2020-04-10"

Infected = t(data[44:80,2])

Day <- 1:(length(Infected))

# now specify initial values for N, S, I and R
N <- 20000000 #### Population of Texas
init <- c(
  S = N - Infected[1],
  I = Infected[1],
  R = 0
)

# define a function to calculate the residual sum of squares
# (RSS), passing in parameters beta and gamma that are to be
# optimised for the best fit to the incidence data
RSS <- function(parameters) {
  names(parameters) <- c("beta", "gamma")
  out <- ode(y = init, times = Day, func = SIR, parms = parameters)
  fit <- out[, 3]
  sum((Infected - fit)^2)
}

# now find the values of beta and gamma that give the
# smallest RSS, which represents the best fit to the data.
# Start with values of 0.5 for each, and constrain them to
# the interval 0 to 1.0
# install.packages("deSolve")

Opt <- optim(c(0.5, 0.5),
             RSS,
             method = "L-BFGS-B",
             lower = c(0, 0),
             upper = c(1, 1)
)


# check for convergence
Opt$message

##### Optimal values of beta and gamma
Opt_par <- setNames(Opt$par, c("beta", "gamma"))
Opt_par

# time in days for predictions
t <- 1:as.integer(ymd(sir_end_date) + 1 - ymd(sir_start_date))

# get the fitted values from our SIR model
fitted_cumulative_incidence <- data.frame(ode(
  y = init, times = t,
  func = SIR, parms = Opt_par
))


rmse(t(Infected),fitted_cumulative_incidence$I)

























###### Prediciton ######### 60 + days
# time in days for predictions
t <- 1:70

# get the fitted values from our SIR model
fitted_cumulative_incidence <- data.frame(ode(
  y = init, times = t,
  func = SIR, parms = Opt_par
))

##### NEW GRAPH #### 
# add a Date column and join the observed incidence data
fitted_cumulative_incidence <- fitted_cumulative_incidence %>%
  mutate(
    Date = ymd(sir_start_date) + days(t - 1),
    state = "Texas",
    cumulative_incident_cases = c(Infected, rep(NA, length(t) - length(Infected)))
  )

# plot the data
fitted_cumulative_incidence %>%
  ggplot(aes(x = Date)) +
  geom_line(aes(y = I, colour = "red")) +
  geom_point(aes(y = cumulative_incident_cases,colour = "blue")) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    y = "Persons",
    title = "COVID-19 fitted vs observed cumulative cases, Texas"
  ) +
  scale_colour_manual(
    name = "",
    values = c(red = "red", blue = "blue"),
    labels = c("Observed", "Forecast")
  ) +
  theme_minimal()
