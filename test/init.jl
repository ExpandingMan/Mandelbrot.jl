using Mandelbrot
using Images, ImageInTerminal, Distributions
using Base.Threads, LinearAlgebra

using Mandelbrot: buddha, attractor

const DIR = joinpath(splitdir(pathof(Mandelbrot))[1],"..","images")

filename(str::AbstractString) = joinpath(DIR,str)
