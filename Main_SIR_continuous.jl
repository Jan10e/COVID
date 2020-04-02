
# packages
using Distributions
using StatsPlots
# using Pkg
# Pkg.pin(PackageSpec(name="StatsPlots", version="0.10.0"))
using DataFrames
using CSV

# functions
include("SIR_continous.jl")

import Random
Random.seed!(1234)
randn(42)

sir_out = sir_ct(0.1/1000,0.05,1000,999,1,0,200);
head(sir_out)

@df sir_out plot(:time, [:S :I :R], xlabel="Time",ylabel="Number")
