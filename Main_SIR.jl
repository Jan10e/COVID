# Title: SIR model example, looking at dynamics over days
#
# Name: Jantine Broek
# Date: March 20
##############################################################

# working directory
cd("//Users/jantinebroek/Documents/03_prog_comp/02_collab/COVID")

# Loads packages

# Functions
include("updateSIR.jl")

# parameters
dt = 0.5
λ = 1/200
γ = 1/10

# input
s, i, r = 1000., 10., 20.   # multiple assignments
pop_vec = [s i r]

# call function
(S_up, I_up, R_up) = updateSIR(pop_vec)
