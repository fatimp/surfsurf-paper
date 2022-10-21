module DifferentSizes
using Distributions
using PyPlot
using Statistics
using CorrelationFunctions
using ValueNoise
using Images
using FileIO
using Random
include("spheres.jl")

export produce_plots_with_disks!,
    produce_plots_with_noise!,
    produce_disks!,
    produce_noise!

function produce_disks!()
    Random.seed!(12342)
    centers = (5e-5 * 4096^2) |> Poisson |> rand |> gencenters1
    for n in [64, 256, 1024, 4096]
        img = gendisks1(n, centers, 0.015)
        save("surfsurf-paper/images/disks-0015-5e-5-$(n).png", img)
    end
end

function produce_noise!()
    fn(x, y, n) = value_noise(15x/n, 15y/n, 0, 3, 43432) < 0.5
    for n in [64, 256, 1024, 4096]
        img = [fn(x, y, n) for x in 1:n, y in 1:n]
        save("surfsurf-paper/images/noise-$(n).png", img)
    end
end

function produce_plots_with_disks!()
    img64   = load("surfsurf-paper/images/disks-0015-5e-5-64.png")   .|> Gray |> BitArray
    img256  = load("surfsurf-paper/images/disks-0015-5e-5-256.png")  .|> Gray |> BitArray
    img1024 = load("surfsurf-paper/images/disks-0015-5e-5-1024.png") .|> Gray |> BitArray
    img4096 = load("surfsurf-paper/images/disks-0015-5e-5-4096.png") .|> Gray |> BitArray

    ss64   = Directional.surfsurf(img64,   false; periodic = true) |> mean
    ss256  = Directional.surfsurf(img256,  false; periodic = true) |> mean
    ss1024 = Directional.surfsurf(img1024, false; periodic = true) |> mean
    ss4096 = Directional.surfsurf(img4096, false; periodic = true) |> mean

    sv64   = Directional.surfvoid(img64,   false; periodic = true) |> mean
    sv256  = Directional.surfvoid(img256,  false; periodic = true) |> mean
    sv1024 = Directional.surfvoid(img1024, false; periodic = true) |> mean
    sv4096 = Directional.surfvoid(img4096, false; periodic = true) |> mean

    ssth(x) = ss_theory(x, 0.015*4096, 5e-5)
    figure(figsize = (10, 8), dpi = 300)
    rc("font", size = 18)
    ticklabel_format(axis = "y", scilimits = (0, 0), useMathText = true)
    plot(range(0, 2048-1, length(ss64)),   ss64   * (64   / 4096)^2; linewidth = 2.0)
    plot(range(0, 2048-1, length(ss256)),  ss256  * (256  / 4096)^2; linewidth = 2.0)
    plot(range(0, 2048-1, length(ss1024)), ss1024 * (1024 / 4096)^2; linewidth = 2.0)
    plot(ss4096; linewidth = 2.0)
    plot(ssth.(0:(2048-1)); linewidth = 2.0)
    ylim([0, 0.0005])
    xlabel(raw"$ar$")
    ylabel(raw"$a^2F_{ss}(ar)$")
    legend(["64x64", "256x256", "1024x1024", "4096x4096", "Theory"])
    savefig("surfsurf-paper/images/plot-ss-balls.png")

    svth(x) = sv_theory(x, 0.015*4096, 5e-5)
    figure(figsize = (10, 8), dpi = 300)
    rc("font", size = 18)
    ticklabel_format(axis = "y", scilimits = (0, 0), useMathText = true)
    plot(range(0, 2048-1, length(sv64)),   sv64   * (64   / 4096); linewidth = 2.0)
    plot(range(0, 2048-1, length(sv256)),  sv256  * (256  / 4096); linewidth = 2.0)
    plot(range(0, 2048-1, length(sv1024)), sv1024 * (1024 / 4096); linewidth = 2.0)
    plot(sv4096; linewidth = 2.0)
    plot(svth.(0:(2048-1)); linewidth = 2.0)
    xlabel(raw"$ar$")
    ylabel(raw"$aF_{sv}(ar)$")
    legend(["64x64", "256x256", "1024x1024", "4096x4096", "Theory"])
    savefig("surfsurf-paper/images/plot-sv-balls.png")
end

function produce_plots_with_noise!()
    img64   = load("surfsurf-paper/images/noise-64.png")   .|> Gray |> BitArray
    img256  = load("surfsurf-paper/images/noise-256.png")  .|> Gray |> BitArray
    img1024 = load("surfsurf-paper/images/noise-1024.png") .|> Gray |> BitArray
    img4096 = load("surfsurf-paper/images/noise-4096.png") .|> Gray |> BitArray

    ss64   = Directional.surfsurf(img64,   false; periodic = true) |> mean
    ss256  = Directional.surfsurf(img256,  false; periodic = true) |> mean
    ss1024 = Directional.surfsurf(img1024, false; periodic = true) |> mean
    ss4096 = Directional.surfsurf(img4096, false; periodic = true) |> mean

    sv64   = Directional.surfvoid(img64,   false; periodic = true) |> mean
    sv256  = Directional.surfvoid(img256,  false; periodic = true) |> mean
    sv1024 = Directional.surfvoid(img1024, false; periodic = true) |> mean
    sv4096 = Directional.surfvoid(img4096, false; periodic = true) |> mean

    figure(figsize = (10, 8), dpi = 300)
    rc("font", size = 18)
    ticklabel_format(axis = "y", scilimits = (0, 0), useMathText = true)
    plot(range(0, 2048-1, length(ss64)),   ss64   * (64   / 4096)^2; linewidth = 2.0)
    plot(range(0, 2048-1, length(ss256)),  ss256  * (256  / 4096)^2; linewidth = 2.0)
    plot(range(0, 2048-1, length(ss1024)), ss1024 * (1024 / 4096)^2; linewidth = 2.0)
    plot(ss4096; linewidth = 2.0)
    ylim([0, 4e-5])
    xlabel(raw"$ar$")
    ylabel(raw"$a^2F_{ss}(ar)$")
    legend(["64x64", "256x256", "1024x1024", "4096x4096"])
    savefig("surfsurf-paper/images/plot-ss-noise.png")

    figure(figsize = (10, 8), dpi = 300)
    rc("font", size = 18)
    ticklabel_format(axis = "y", scilimits = (0, 0), useMathText = true)
    plot(range(0, 2048-1, length(sv64)),   sv64   * (64   / 4096); linewidth = 2.0)
    plot(range(0, 2048-1, length(sv256)),  sv256  * (256  / 4096); linewidth = 2.0)
    plot(range(0, 2048-1, length(sv1024)), sv1024 * (1024 / 4096); linewidth = 2.0)
    plot(sv4096; linewidth = 2.0)
    xlabel(raw"$ar$")
    ylabel(raw"$aF_{sv}(ar)$")
    legend(["64x64", "256x256", "1024x1024", "4096x4096"])
    savefig("surfsurf-paper/images/plot-sv-noise.png")

    save("surfsurf-paper/images/noise.png", Gray.(img1024))
end

end
