# Actuarial-Modelling
Complete this sheet using R code
# Before answering this question, the ‘markovchain’ R package should be loaded
# into R using the following code:
#install.packages ("markovchain")
#library (markovchain)
#A three-state Markov chain model consisting of healthy (‘H’), sick (‘S’), and dead
#(‘D’) states has the following weekly transition probabilities:
#𝑝𝐻𝐻 = 0.97
#𝑝𝐻𝑆 = 0.029
#𝑝𝐻𝐷 = 0.001
#𝑝𝑆𝑆 = 0.7
#𝑝𝑆𝐻 = 0.25
#𝑝𝑆𝐷 = 0.05
#(i) Construct a ‘markovchain’ object for the transition matrix for the above
#Markov chain model. [2]
#(ii) Calculate the probability that, given a life is healthy now, the life will be sick
#at time 3 weeks. [3]
#(iii) Calculate the probability that, given a life is healthy now, the life will be sick
# at some point in the next 52 weeks. [3]
#(iv) Calculate the probability that, given a life is healthy now, the life will remain
# healthy for the entire year. [1]
#A new, disease has become prevalent, and it is proposed that the HSD model above be
#amended to model the effects of this disease. Lives become ill for a period of time
#and then either recover or die. Once recovered, a life is deemed immune and cannot
#become ill again.
#It has been decided to use a Markov jump model instead of a chain model. The
#Markov model consists of four states: healthy (‘H’), sick (‘S’), recovered (‘R’) and
#dead (‘D’) state. The following daily transition rates have been estimated:
#𝜇𝑆𝐷 = 5%
#𝜇𝑆𝑅 = 14%
#The rate from healthy to infected, 𝜇𝐻𝑆, is equal to b multiplied by 𝑖𝑡where b is a
#constant and 𝑖𝑡
#is the proportion of lives in the sick state at time t. All other transition
#rates are zero.
#(v) Explain why it may be preferable to set 𝜇𝐻𝑆 = 𝑏𝑖𝑡
#(as above), rather than
# using a constant value (as has been done for the other rates). [1]
#Page 4
#(vi) Give an example of a scenario that would be expected to result in a
# particularly high value of b. [2]
#The proposed value of b is 0.35, and it is assumed that at time 0, 1% of the population
#are in the sick state and the remaining 99% are in the healthy state.
#(vii) Using this revised model and a step length of 0.01 days, calculate the
# occupancy probabilities in each of the four states from t = 0.01 to t = 100 days
# inclusive. You should output your answers for each value of t to successive
# rows of a matrix. [12]
# (viii) Plot a graph showing the probabilities in part (vii) with suitably labelled axes
# and making clear which plot components correspond to which state. [5]
# (ix) Calculate the probability that a life that is healthy at time 0 is sick after:

(a) 6 days.

(b) 25 days. [4]
 (x) Calculate the expected present value of a daily rate of €1 payable while sick
 using a force of interest of 5% p.a. 
