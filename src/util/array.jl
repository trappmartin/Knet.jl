issimilar(a,b)=((typeof(a)==typeof(b)) && (size(a)==size(b)))

# Fix bug with deepcopy, where a shared bits array is copied multiple times:
# TODO: check if this bug is still there
Base.deepcopy_internal{T<:Number}(x::Array{T}, s::ObjectIdDict)=(haskey(s,x)||(s[x]=copy(x));s[x])

function Base.isapprox(x, y; 
                       maxeps::Real = max(eps(eltype(x)), eps(eltype(y))),
                       rtol::Real=maxeps^(1/3), atol::Real=maxeps^(1/2))
    size(x) == size(y) || (warn("isapprox: $(size(x))!=$(size(y))"); return false)
    x = convert(Array, x)
    y = convert(Array, y)
    d = abs(x-y)
    s = abs(x)+abs(y)
    maximum(d - rtol * s) <= atol
end

# This is missing from Base
Base.convert{T,I}(::Type{Array{T,2}}, a::SparseMatrixCSC{T,I})=full(a)

if !GPU  # alternatives defined in cudart.jl
    typealias BaseArray{T,N} Union{Array{T,N},SubArray{T,N}}
    copysync!(a,b)=copy!(a,b)
    fillsync!(a,b)=fill!(a,b)
end

# Define a more versatile version of randn!

import Base: randn!, GLOBAL_RNG

randn!{T}(A::AbstractArray{T}, mean=zero(T), std=one(T)) = randn!(GLOBAL_RNG, A, mean, std)

function randn!{T}(rng::AbstractRNG, A::AbstractArray{T}, mean=zero(T), std=one(T))
    for i in eachindex(A)
        @inbounds A[i] = mean+std*randn(rng)
    end
    A
end

### DEAD CODE:

# # SIMILAR! create an array l.(n) similar to a given one.  If l.(n)
# # exists check and resize if necessary.

# function similar!(l, n, a, T=eltype(a), dims=size(a); fill=nothing)
#     if !isdefined(l,n) || (typeof(l.(n)) != typeof(a))
#         l.(n) = similar(a, T, dims)
#         fill != nothing && fillsync!(l.(n), fill)
#     elseif (size(l.(n)) != dims)
#         l.(n) = resize!(l.(n), dims)
#         fill != nothing && fillsync!(l.(n), fill)
#     end
#     return l.(n)
# end

# similar!(l, n, a, T, dims::Integer...; o...) = similar!(l,n,a,T,dims; o...)
# similar!(l, n, a, dims::Integer...; o...) = similar!(l,n,a,dims; o...)
# similar!(l, n, a, dims::Dims; o...) = similar!(l,n,a,eltype(a),dims; o...)

# issimilar1(a,b)=((eltype(a)==eltype(b)) && (isongpu(a)==isongpu(b)) && (length(a)==length(b)))
# issimilar2(a,b)=((eltype(a)==eltype(b)) && (isongpu(a)==isongpu(b)) && (size2(a)==size2(b)))


# This does not work in place!
# Base.resize!(a::Array, d::Dims)=similar(a, d)

