include("init.jl")

# x ∈ [0, 1)
pretty(x::Real, φ::Real=200, s::Real=1, l::Real=0.5) = HSL(360*x + φ % 360, s, l)

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
function buddhabrot2(h=buddha(10^7), φ::Real=200, s::Real=1, l::Real=0.5)
    f = takemap(scaleminmax, h)
    pretty.(f.(h).^(3/4), φ, s, l)
end
function buddhabrot3(n::Integer=10^7, φ::Real=180, s::Real=0.7, l::Real=0.4)
    𝓅 = MvNormal(ones(2), Diagonal(ones(2)))
    h = buddha(𝓅, n)
    f = takemap(scaleminmax, h)
    pretty.(f.(h).^(3/4), φ, s, l)
end

function nebulabrot1(hr=buddha(5*10^6, iterations=2000),
                     hg=buddha(5*10^6, iterations=500),
                     hb=buddha(5*10^6, iterations=50))
    fr, fg, fb = takemap.((scaleminmax,), (hr, hg, hb))
    RGB.(fr.(hr).^(1/2), fg.(hg).^(1/2), fb.(hb).^(1/2))
end
