# Code from: https://github.com/timueh/PandemicModeling
#
##############################################################

# packages
using DifferentialEquations,            # to solve DEs
      SparseArrays,                     # sparse arrays stores data to save space and increase execution time (compare)
      PolyChaos,                        # package to implement Polynomial Chaos Expansion (PCE)
      BenchmarkTools,                   # to make performance tracking in Julia code easy
      PyPlot,                           # plotting packages
      LaTeXStrings                      # nice axis, labels, etc in LaTeX

# functions
include("SEIR-L-IN_uncertain_setup.jl")

# deterministic setup
N = 80000000                            # total population
E_0, I_0, R_0 = 40000.0, 10000.0, 0.0   # init vals for E, I and R
S_0 = N - E_0 - I_0 - R_0               # init val for S

lag_0 = 10          # lag period from I to IN (infected > ICU)
IN_0 = 0            # init val ICU patients
x0 = [S_0, E_0, I_0, R_0, lag_0, IN_0]
tspan = (0.0, 365)  # one year

# probabilistic setup (for polynomial chaos expansion)
degree, Nrec = 5, 20                                # degree and N for constructing polynomials
op1, op2 = GaussOrthoPoly(degree; Nrec = Nrec),     # construct orthogonal polynomials with Gaussian random variables
    Uniform01OrthoPoly(degree; Nrec = Nrec)         # construct orthogonal polynomials with uniform random variables
mop = MultiOrthoPoly([op1, op2], degree)            # multivariate (univariate = AbstractOrthoPoly)
T2, T3, T4 = [Tensor(i, mop) for i = 2:4]           # build tensor (generalisation of scalars and vectors)
x0_pce = build_initial_condition(x0, dim(mop))

R0_pce = assign2multi(convert2affinePCE(1.5, 0.1, op1), 1, mop.ind) # basic reproduction number
percentage_pce = assign2multi(convert2affinePCE(0.02, 0.06, op2), 2, mop.ind) # uncertainty for the percentage of people in need of intensive care as a uniform random variable

# add all parameters to SEIR model and the DEs for intensive care
seir_pars, int_care_pars = SEIR(R0_pce, 5.5, 3.0),
    Intensive_care(percentage_pce, 20.0, 10.0)

# solve Galerkin-projected ODE
problem = ODEProblem(
    seir_model!,
    x0_pce,
    tspan,
    [seir_pars, int_care_pars, mop, T2, T3, T4],
)
sol = solve(problem, save_at = 0.5)

# post-processing
inds = build_indices(length(x0), dim(mop))
mean_inds = [ind[1] for ind in inds]

mean_sols = vcat([u[mean_inds] for u in sol.u]'...)
std_sols = vcat([[std(u[ind], mop) for ind in inds] for u in sol.u]'...)

# plot and store in figures folder (folder is indicated in SEIR-L-IN_uncertain_setup.jl)
# make sure you have a folder called "figures"
plot_results(sol.t, mean_sols, std_sols, save = true)
