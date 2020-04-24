
"""
    search(v, x[,idx=1])

Assuming `v` is a sorted `Vector`, finds the largest index `i` such that `v[i] ≤ x` (that is, as long
as `v[i+1]` exists this returns `i` such that `v[i] ≤ x < v[i+1]`).  Returns `nothing` if no such `i`
exists.

`v` can be any iterable that implements `view`.

`idx` adjusts the result such that the first index of `v` is `idx` (i.e. if `v` is a sub-array this
can be used to find the position in the parent of `v`).
"""
function search(v, x, idx::Integer=1)
    n, r = divrem(length(v), 2)
    s = n + r
    l = view(v, 1:s)
    r = view(v, (s+1):lastindex(v))
    if x < first(l)
        nothing
    elseif x ≥ last(r)
        nothing
    elseif x < first(r)
        x ≥ last(l) && return idx+s-1
        length(l) == 1 ? idx : search(l, x, idx)
    else
        length(r) == 1 ? s+idx : search(r, x, s+idx)
    end
end


"""
    histogram(z)

Computes a histogram of a `AbstractVector{<:Complex}`.  The abscissa is the imaginary axis and the
ordinate is the real access (this convention is chosen because it's convenient for generating
Mandelbrot images.
"""
function histogram(z::AbstractVector{<:Complex},
                   rbins::AbstractVector{<:Real}, ibins::AbstractVector{<:Real})
    h = zeros(Int, length(rbins)-1, length(ibins)-1)
    for ζ ∈ z
        ridx = search(rbins, real(ζ))
        isnothing(ridx) && continue
        iidx = search(ibins, imag(ζ))
        isnothing(iidx) && continue
        h[ridx, iidx] += 1
    end
    h
end
function histogram(z::AbstractVector{<:Complex}; bounding_box=(-1.5 - im, 0.5+im), nbins=2000+2000im)
    rbins = range(real(bounding_box[1]), length=real(nbins), stop=real(bounding_box[2]))
    ibins = range(imag(bounding_box[1]), length=imag(nbins), stop=imag(bounding_box[2]))
    histogram(z, rbins, ibins)
end
