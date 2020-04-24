using Mandelbrot
using Images, ImageInTerminal
using Base.Threads

using Mandelbrot: buddha, attractor

const DIR = joinpath(splitdir(pathof(Mandelbrot))[1],"..","images")

filename(str::AbstractString) = joinpath(DIR,str)

function attractors1(x=(-1.5:0.001:0.5), y=(-1:0.001:1))
    A = x' .+ im .* y
    S = Mandelbrot.Series.(A)
    ζ = attractor.(S)
    α, β = first.(ζ), last.(ζ)
    α = replace!(x -> isnan(x) || abs(x) > 4.0 ? 0.0 : x, α)
    β = replace!(x -> isnan(x) || abs(x) > 4.0 ? 0.0 : x, β)
    fα, fβ = takemap.((scaleminmax,), (α, β))
    RGB.(fα.(α).^(1/2), 0, 0), RGB.(0, 0, fβ.(β).^(1/2))
end

function buddhabrot1(h=buddha(10^7))
    f = takemap(scaleminmax, h)
    RGB.(0, 0, f.(h).^(1/2))
end

function nebulabrot1(hr=buddha(5*10^6, iterations=2000),
                     hg=buddha(5*10^6, iterations=500),
                     hb=buddha(5*10^6, iterations=50))
    fr, fg, fb = takemap.((scaleminmax,), (hr, hg, hb))
    RGB.(fr.(hr).^(1/2), fg.(hg).^(1/2), fb.(hb).^(1/2))
end
