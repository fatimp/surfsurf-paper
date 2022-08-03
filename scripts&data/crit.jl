#!/usr/bin/env julia

using PyPlot
using CorrelationFunctions
using Random
using Distributions
include("spheres.jl")

centers = gencenters1(700)
x = 100:100:4000
c = [gendisks1(n, centers, 0.02) |> lowfreq_energy_ratio for n in x]

figure(figsize = (10, 8), dpi = 300)
rc("font", size = 18)
plot(collect(x) / 4000, c, "b.")
xlabel("Resize ratio")
ylabel(raw"$C_{0.5}$")
savefig("../images/plot-criterion.png")
