using DifferentialEquations

function seir_ode(dY,Y,p,t)
 dY[1] = p[4]-p[1]*Y[1]*Y[3]-p[4]*Y[1]
 dY[2] = p[1]*Y[1]*Y[3]-(p[2]+p[4])*Y[2]
 dY[3] = p[2]*Y[2] - (p[3]+p[4])*Y[3]
end

par=[520/365,1/60,1/30,774835/(65640000*365)]
init=[0.8,0.1,0.1]
tspan=(0.0,365.0)

seir_prob = ODEProblem(seir_ode,init,tspan,par)

sol=solve(seir_prob);

using Plots

R=ones(1,size(sol,2))-sum(sol,1);

plot(sol.t,[sol',R'],xlabel="Time",ylabel="Proportion")
