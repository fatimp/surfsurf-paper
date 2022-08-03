#!/usr/bin/env julia

using PyPlot
using CorrelationFunctions
using Images
using FileIO
using Statistics
using Interpolations

im1 = load("../resize-effects/disks-small.png") .|> Bool
im2 = load("../resize-effects/disks-big.png") .|> Bool
im3 = imresize(im1, (4000, 4000); method = BSpline(Linear()))

ss1 = Directional.surfsurf(im1, identity; periodic = true) |> mean
ss2 = Directional.surfsurf(im2, identity; periodic = true) |> mean
ss3 = Directional.surfsurf(im3, identity; periodic = true) |> mean

figure(figsize = (10, 8), dpi = 300)
rc("font", size = 18)
plot(range(1, 2000, length(ss1)), ss1 * (300/4000)^2, linewidth = 2.0)
plot(ss3, linewidth = 2.0)
plot(ss2, linewidth = 2.0)
xlim([100, 2000])
ylim([0, 0.0001])
legend([raw"$300\times 300$", raw"$4000 \times 4000$ (magnified)", raw"$4000 \times 4000$ (digitized)"])
xlabel(raw"$ar$")
ylabel(raw"$a^2F_{ss}(ar)$")
ticklabel_format(scilimits = (0, 0))
savefig("../resize-effects/surfsurf.png")
