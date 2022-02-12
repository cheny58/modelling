# using packages
# 在julia repl里用] 然后add packagename比如add DifferentialEquations
# shift enter 执行一行
# alt enter执行整个
using Distributions, DifferentialEquations, Plots
using BenchmarkTools
using DiffEqBase.EnsembleAnalysis
# define parameters
T = 8000000
p1 = Normal(10,1)
p2 = Normal(20,1.5)
# define ode function
function f(du,u,p,t)
    p1,p2 = p
    T = u[1]
    du[1] = (-p1*T + p2*T)/365
end
# define ode problem
p = [p1,p2] 
u0 = [T] #initial parameters
tspan = (0.0,50.0) # elapsed time
prob = ODEProblem(f,u0,tspan,p)

# 因为有probability所以要变成EnsembleProblem
function prob_func(prob,i,repeat)
    remake(prob,p=rand.(p))
end
ensemble_prob = EnsembleProblem(prob, prob_func=prob_func)

# solve ode
# AutoTsit5(Rodas5()) 跟RK差不多，但更好
trajectories = 300
sol = solve(ensemble_prob,AutoTsit5(Rodas5()), EnsembleThreads(), trajectories = trajectories)

# plot结果
plot(EnsembleSummary(sol),xaxis = "years",yaxis = "plastic number")