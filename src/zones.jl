abstract type AbstractZone{N, T} end
GI.isgeometry(geom::AbstractZone)::Bool = true
GI.geomtrait(::AbstractZone) = PolygonTrait()
GI.ngeom(::PolygonTrait, ::AbstractZone) = 1
GI.getgeom(::PolygonTrait, zone::AbstractZone, i) = geometry(zone)

const VectorCoordsType = Vector{<:Vector{<:Number}}

"""
    ZoneBoundary{N, T}
Represents the border for a ATP45 zone. `N` is the number of vertices defining the zone.

# Examples
```julia-repl
# We create a triangle like border (3 vertices):
julia> coords = [
    [6., 49.],
    [5., 50.],
    [4., 49.],
]
julia> ZoneBoundary(coords)
ZoneBoundary{3, Float64}(((6.0, 49.0), (5.0, 50.0), (4.0, 49.0)))
```
"""
struct ZoneBoundary{N, T}
    coords::NTuple{N, NTuple{2, T}}
end
function ZoneBoundary(vec::Vector{<:Vector{<:Number}})
    npoints = length(vec)
    ZoneBoundary(NTuple{npoints}(Tuple.(vec)))
end
function ZoneBoundary(args...)
    # @assert args isa Tuple{Vararg{<:NTuple{2, <: Number}}} "Arguments must be "
    ZoneBoundary(Tuple(Tuple.(args)))
end
GI.isgeometry(::ZoneBoundary)::Bool = true
GI.geomtrait(::ZoneBoundary) = LinearRingTrait()

# We add the first point add the end to make it a closed shape.
GI.ngeom(::LinearRingTrait, geom::ZoneBoundary{N, T}) where {N, T} = N + 1
GI.getgeom(::LinearRingTrait, geom::ZoneBoundary{N, T}, i) where {N, T} = geom.coords[(i-1)%N + 1]

"""
    Zone{N, T} <: AbstractZone{N, T}
Defines a closed polygon with `N` vertices for representing a ATP-45 zone.
"""
struct Zone{N, T} <: AbstractZone{N, T}
    geometry::ZoneBoundary{N, T}
end
geometry(zone::Zone) = zone.geometry
Zone(vec::VectorCoordsType) = Zone(ZoneBoundary(vec))
Zone(args...) = Zone(ZoneBoundary(args...))

# struct TriangleLike{T} <: AbstractZone
#     geom::ZoneBoundary{3, T}
#     properties::AbstractDict
#     # function TriangleLike(x::Vector{<:Vector{<:T}}, y) where T<:Number
#     #     push!(x, x[1])
#     #     new(x, y)
#     # end
# end

# TriangleLike(vec::Vector{<:Vector{<:Number}}, props) = TriangleLike(ZoneBoundary(vec), props)

# GI.geomtrait(::TriangleLike) = TriangleTrait()
# GI.ngeom(::TriangleTrait, geom::TriangleLike)::Integer = 1
# GI.getgeom(::TriangleTrait, geom::TriangleLike, i) = geom.geom
# GeoInterface.ngeom(::TriangleLike)::DataType = TriangleTrait()