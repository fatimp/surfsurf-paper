module DMvsSobel
using Distributions
using FFTW
using Images
using OffsetArrays
using Statistics
using Random
using PyPlot

include("spheres.jl")

# Disk generation code is copied from CorrelationFunctions.jl test suite
export gradient, distance_map_edge, average,
    produce_fucking_graphics!,
    produce_map_vs_dir_plot!,
    produce_kernel_plot!,
    produce_another_comparison!

autocorr(arr :: AbstractArray) =
    (arr |> fft .|> abs2 |> ifft |> real) / length(arr)

function array_with_zero_based_indices(array :: Array)
    ax = map(x -> x .- 1, axes(array))
    return OffsetArray(array, ax)
end

function reflect(arr :: AbstractArray{T}) where T <: Real
    ft = arr |> fft |> array_with_zero_based_indices

    for idx in CartesianIndices(ft)
        ft[idx] = (-1)^(idx |> Tuple |> sum) * ft[idx]
    end

    return ft.parent |> ifft |> real
end

function gradient(arr :: AbstractMatrix, kernel = KernelFactors.sobel)
    x, y = imgradients(arr, kernel)
    return sqrt.(x.^2 + y.^2)
end

function distance_map_edge(arr :: AbstractMatrix{Bool})
    d = arr |> feature_transform |> distance_transform
    return @. 0 < d <= 1.42
end

function average(arr :: AbstractArray)
    arr = array_with_zero_based_indices(arr)
    center  = CartesianIndex(size(arr) .÷ 2)
    indices = CartesianIndices(arr)
    dict = Dict{Float64, Array{Float64}}()

    for idx in indices
        dist = (Tuple(idx - center) .^2) |> sum |> sqrt |> floor
        vals = get(dict, dist, Float64[])
        push!(vals, arr[idx])
        dict[dist] = vals
    end

    xs = dict |> keys |> collect |> sort
    ys = map(xs) do key mean(dict[key]) end

    return xs, ys
end

function produce_fucking_graphics!()
    Random.seed!(1)
    img = gendisks(1000, 10, 0.002)
    save("surfsurf-paper/images/original.png", img[1:100, 1:100])

    function plot_it!(fns)
        interfaces = map(fn -> fn(img), fns)
        cfss = interfaces .|> autocorr .|> reflect
        cf  = reduce(+, cfss) / length(cfss)
        xs, ys = average(cf)
        plot(xs, ys, linewidth = 2.0)
        return xs, cf
    end

    figure(figsize = (10, 9), dpi = 300)
    rc("font", size = 18)
    xs, cfs = plot_it!([gradient])
    xs, cfd = plot_it!([distance_map_edge])
    xs, cfd = plot_it!([distance_map_edge ∘ (.!)])
    xs, cfd = plot_it!([distance_map_edge,
                        distance_map_edge ∘ (.!)])
    th(x) = ss_theory(x, 10, 0.002)
    plot(xs, th.(xs), linewidth = 2.0)
    xlabel(raw"$r$")
    ylabel(raw"$F_{ss}(r)$")
    legend(["Sobel kernel",
            "Distance transform (outer border)",
            "Distance transform (inner border)",
            "Distance transform (mean)",
            "Theory"]; loc = 2)
    xlim([0, 40])
    savefig("surfsurf-paper/images/Fss_mean_dir.png")
    save("surfsurf-paper/images/distance_map.png", img[1:100, 1:100] |> distance_map_edge)
    save("surfsurf-paper/images/sobel.png", img[1:100, 1:100] |> gradient)

    function plot_it2!(cf, name)
        figure(figsize = (6, 6), dpi = 300)
        axis("off")
        s = CartesianIndex(size(cf) .÷ 2)
        w = CartesianIndex(50, 50)
        imshow(cf[(s - w):(s + w)])
        savefig("surfsurf-paper/images/Fss_map_$(name).png";
                bbox_inches = "tight",
                pad_inches = 0)
    end

    plot_it2!(cfs, "sobel")
    plot_it2!(cfd, "dm")
end

function produce_map_vs_dir_plot!()
    Random.seed!(1)
    img = gendisks(1000, 10, 0.002)
    cf  = img |> gradient |> autocorr
    cfr = cf  |> reflect
    xs, ys = average(cfr)
    th(x)  = ss_theory(x, 10, 0.002)

    figure(figsize = (10, 8); dpi = 300)
    rc("font", size = 18)
    plot(xs, th.(xs), linewidth = 2.0)
    plot(xs, ys, linewidth = 2.0)
    plot(cf[1,:], linewidth = 2.0)
    xlabel(raw"$r$")
    ylabel(raw"$F_{ss}(r)$")
    legend(["Theory", "Map average", "One direction"])
    xlim([0, 40])
    savefig("surfsurf-paper/images/direction_and_map.png")
end

function produce_kernel_plot!()
    Random.seed!(1)
    kernels = [KernelFactors.sobel,
               KernelFactors.scharr,
               KernelFactors.bickley,
               KernelFactors.prewitt,
               KernelFactors.ando3,
               KernelFactors.ando4,
               KernelFactors.ando5]

    img   = gendisks(5000, 70, 3e-6)
    th(x) = ss_theory(x, 70, 3e-6)

    figure(figsize = (10, 8); dpi = 300)
    rc("font", size = 18)
    ticklabel_format(axis = "y", scilimits = (0, 0))
    plot(0:400, th.(0:400))

    for kernel in kernels
        gr(x)  = gradient(x, kernel)
        cf     = img |> gr |> autocorr |> reflect
        xs, ys = average(cf)
        plot(xs, ys)
    end

    xlabel(raw"$r$")
    ylabel(raw"$F_{ss}(r)$")
    legend(["Theory", "Sobel", "Scharr", "Bickley", "Prewitt",
            "Ando3", "Ando4", "Ando5"])
    xlim([0, 400])
    ylim([0, 0.00004])
    savefig("surfsurf-paper/images/kernels.png")
end

function produce_another_comparison!()
    Random.seed!(1)
    img   = gendisks(5000, 70, 3e-6)
    th(x) = ss_theory(x, 70, 3e-6)

    function plot_it!(fn)
        interface = fn(img)
        cf = interface |> autocorr |> reflect
        xs, ys = average(cf)
        plot(xs, ys, linewidth = 2.0)
        return xs
    end

    figure(figsize = (10, 8), dpi = 300)
    rc("font", size = 18)
    xs = plot_it!(gradient)
    xs = plot_it!(distance_map_edge)
    plot(xs, th.(xs), linewidth = 2.0)
    xlabel(raw"$r$")
    ylabel(raw"$F_{ss}(r)$")
    legend(["Sobel", "Distance map", "Theory"])
    xlim([0, 400])
    ylim([0, 0.00004])
    savefig("surfsurf-paper/images/sobel-vs-distance-map.png")
end

end
