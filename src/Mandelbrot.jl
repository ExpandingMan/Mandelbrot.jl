module Mandelbrot

using ColorTypes, Transducers
using Random, Distributions
using Base.Threads
using Base.Broadcast: Broadcasted


f(z, c) = z^2 + c

struct MandelbrotSet end
const mandelbrot = MandelbrotSet()

"""
    c ∈ mandelbrot

Returns true if `c` is in the Mandelbrot set, otherwise false.
"""
function Base.:(∈)(c::Number, ::MandelbrotSet; n::Integer=10^3)
    z = zero(typeof(c))
    for i ∈ 1:n
        abs2(z) > 4.0 && return false
        z = f(z, c)
    end
    true
end

"""
    escape(c[,n=200, M=32])

Compute the escape trajectory from `c`.  If the trajectory does not escape, it is discarded.  Only
points that do not exceed `M` in magnitude are kept.
"""
function escape(c::Number, n::Integer=200, M::Real=32.0)
    z = zero(typeof(c))
    v = typeof(c)[]
    η = false
    for i ∈ 1:n
        z = f(z, c)
        abs2(z) > M^2 && break
        push!(v, z)
        abs2(z) > 4.0 && (η = true)
    end
    η ? v : typeof(c)[]
end

function Random.rand(rng::AbstractRNG, ::Type{Complex}, p::Distribution)
    a, b = rand(rng, p)
    a + im*b
end
Random.rand(::Type{Complex}, p::Distribution) = rand(Random.GLOBAL_RNG, Complex, p)

"""
    buddha(p, n=10^6)
    buddha(n=10^6)

Computes the "buddhabrot" histogram of points sampled from distribution `p`.  If no distribution is
provided, a uniform one will be chosen.
"""
function buddha(p::Distribution, n::Integer=10^6; iterations=400,
                bounding_box=(-2.0-1.5*im, 1.0+1.5*im), nbins=1601+1601im,
                brighten=(x -> x^(1/2)), rng=Random.GLOBAL_RNG)
    v = reduce(vcat, tcollect(escape(rand(rng, Complex, p), iterations) for i ∈ 1:n))
    histogram(v, bounding_box=bounding_box, nbins=nbins)
end
function buddha(n::Integer=10^6; kwargs...)
    p = Product([Uniform(-2.0, 1.0), Uniform(-1.5, 1.5)])
    buddha(p, n; kwargs...)
end

"""
    Mandelbrot.Series{T}

A mandelbrot series from `c` starting at `z₀`.
"""
struct Series{T<:Number}
    c::T
    z₀::T
end

Series(c::Number, z₀::Number=zero(typeof(c))) = Series{typeof(c)}(c, z₀)

Base.eltype(s::Series{T}) where {T} = T
Base.IteratorSize(s::Series) = Base.IsInfinite()

Base.iterate(s::Series{T}) where {T} = (s.z₀, s.z₀)
function Base.iterate(s::Series{T}, z) where {T}
    o = f(z, s.c)
    o, o
end

function Base.getindex(s::Series{T}, idx::Base.OneTo) where {T<:Number}
    v = Vector{T}(undef, length(idx))
    z, α = iterate(s)
    for i ∈ idx
        v[i] = z
        z, α = iterate(s, α)
    end
    v
end
Base.getindex(s::Series{T}, idx) where {T<:Number} = s[Base.OneTo(idx)]

function ColorTypes.HSL(z::Complex, a::Real=0.5, s::Real=1.0)
    HSL(180.0*angle(z)/π, s, 1.0 - a^abs(z))
end

function threads(::typeof(∈), Z::AbstractArray, ::MandelbrotSet)
    b = similar(Z, Bool)
    @threads for idx ∈ eachindex(Z)
        b[idx] = Z[idx] ∈ mandelbrot
    end
    b
end

"""
    attractor(s::Series)

Estimates the attractor of a discrete trajectory.
"""
attractor(v::AbstractVector, n::Integer=min(length(v),32)) = extrema(abs.(view(v, (lastindex(v)-n):lastindex(v))))
attractor(s::Series, N::Integer=2^8, n::Integer=min(N,32)) = attractor(s[1:N], n)


include("utils.jl")


export mandelbrot

end # module
