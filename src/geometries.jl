const VectorCoordsType = Vector{<:Vector{<:Number}}

abstract type PointsSeries{N, T} end
# Just make the constructor ok with different types of arguments.
(::Type{T})(vec::VectorCoordsType) where {T <: PointsSeries} = T(Tuple(Tuple.(vec)))

(::Type{T})(vec::Vector{<:Number}) where {T <: PointsSeries} = T((Tuple(vec),))

(::Type{T})(args::Vararg{Vector{<:Number}}) where {T <: PointsSeries} = T(Tuple(Tuple.(args)))

coords(ps::PointsSeries) = ps.coords

abstract type AbstractReleaseLocation{N, T} <: PointsSeries{N, T} end
GI.isgeometry(geom::AbstractReleaseLocation)::Bool = true
GI.geomtrait(::AbstractReleaseLocation) = MultiPointTrait()
GI.ngeom(::MultiPointTrait, ::AbstractReleaseLocation{N, T}) where {N, T} = N
GI.getgeom(::MultiPointTrait, geom::AbstractReleaseLocation, i) = coords(geom)[i]

ParamType(::Type{<:AbstractReleaseLocation}) = Location()

"""
    ReleaseLocation{N, T}
Represents the `N` locations of the release(s).

# Examples
```julia-repl
julia> coords = [
    [6., 49.],
    [6., 51.],
]
julia> ReleaseLocation(coords)
ReleaseLocation{2, Float64}(((6.0, 49.0), (6.0, 51.0)))
```
"""
struct ReleaseLocation{N, T} <: AbstractReleaseLocation{N, T}
    coords::NTuple{N, NTuple{2, T}}
end
==(r1::ReleaseLocation, r2::ReleaseLocation) = coords(r1) == coords(r2)
"""
    ZoneBoundary{N, T}
Represents the border for a ATP45 zone. `N` is the number of vertices defining the zone.
It implements the `GeoInterface.LinearRing` trait.

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
struct ZoneBoundary{N, T} <: PointsSeries{N, T} 
    coords::NTuple{N, NTuple{2, T}}
end
GI.isgeometry(::ZoneBoundary)::Bool = true
GI.geomtrait(::ZoneBoundary) = LinearRingTrait()

# We add the first point add the end to make it a closed shape.
GI.ngeom(::LinearRingTrait, geom::ZoneBoundary{N, T}) where {N, T} = N + 1
GI.getgeom(::LinearRingTrait, geom::ZoneBoundary{N, T}, i) where {N, T} = coords(geom)[(i-1)%N + 1]


abstract type AbstractZone{N, T} end
coords(zone::AbstractZone) = coords(boundaries(zone))
boundaries(zone::AbstractZone) = zone.boundaries

GI.isgeometry(geom::AbstractZone)::Bool = true
GI.geomtrait(::AbstractZone) = PolygonTrait()
GI.ngeom(::PolygonTrait, ::AbstractZone) = 1
GI.getgeom(::PolygonTrait, zone::AbstractZone, i) = boundaries(zone)

"""
    Zone{N, T} <: AbstractZone{N, T}
Defines a closed polygon with `N` vertices for representing a ATP-45 zone.
It implements the `GeoInterface.Polygon` trait.
"""
struct Zone{N, T} <: AbstractZone{N, T}
    boundaries::ZoneBoundary{N, T}
end
Zone(args...) = Zone(ZoneBoundary(args...))

struct TriangleLikeZone{T} <: AbstractZone{3, T}
    boundaries::ZoneBoundary{3, T}
end
function TriangleLikeZone(releaselocation::ReleaseLocation{1, T}, wind::AbstractWind, dhd, back_distance) where T
    azimuth = wind_azimuth(wind)
    center = coords(releaselocation)[1]
    triangle_coords = triangle_coordinates(center..., T(azimuth), T(dhd), T(back_distance))
    TriangleLikeZone{T}(ZoneBoundary(triangle_coords))
end

struct CircleLikeZone{N, T} <: AbstractZone{N, T}
    center::ReleaseLocation{1, T}
    radius::T
end

function CircleLikeZone(releaselocation::ReleaseLocation{1, T}, radius::Number; numpoint = 100) where {T}
    CircleLikeZone{numpoint, T}(releaselocation, radius)
end
function coords(circle::CircleLikeZone{N, T}) where {N, T} 
    center = coords(circle.center)[1]
    circle_coordinates(center..., circle.radius; res = N)
end
boundaries(circle::CircleLikeZone) = ZoneBoundary(coords(circle))

"""
    AbstractZoneFeature{N, T}
An ATP-45 [`Zone{N, T}`](@ref) with some properties related to it (typically the type of zone, e.g. release or hazard).
It implements the `GeoInterface.Feature` trait.
"""
abstract type AbstractZoneFeature{N, T} end
geometry(zonefeature::AbstractZoneFeature) = zonefeature.geometry
GI.isfeature(::Type{<:AbstractZoneFeature}) = true
GI.trait(::AbstractZoneFeature) = FeatureTrait()
GI.properties(zonefeature::AbstractZoneFeature) = properties(zonefeature)
GI.geometry(zonefeature::AbstractZoneFeature) = geometry(zonefeature)

struct HazardZone{N, T} <: AbstractZoneFeature{T, N}
    geometry::AbstractZone{N, T}
end
properties(::HazardZone) = (type="hazard",)
HazardZone(vec::VectorCoordsType) = HazardZone(Zone(vec))

struct ReleaseZone{N, T} <: AbstractZoneFeature{T, N}
    geometry::AbstractZone{N, T}
end
properties(::ReleaseZone) = (type="release",)
ReleaseZone(vec::VectorCoordsType) = ReleaseZone(Zone(vec))

abstract type AbstractAtp45Result end
properties(result::AbstractAtp45Result) = result.properties
GI.isfeaturecollection(::Type{<:AbstractAtp45Result}) = true
GI.trait(::AbstractAtp45Result) = FeatureCollectionTrait()
GI.nfeature(::FeatureCollectionTrait, result::AbstractAtp45Result) = length(zonecollection(result))
GI.getfeature(::FeatureCollectionTrait, result::AbstractAtp45Result) = zonecollection(result)
GI.getfeature(::FeatureCollectionTrait, result::AbstractAtp45Result, i::Integer) = zonecollection(result)[i]

"""
    Atp45Result
Collection of zones representing the result of an ATP-45 procedure result. Also contains relevant information about the input conditions.
It implements the `GeoInterface.FeatureCollection` trait.
"""
struct Atp45Result <: AbstractAtp45Result
    zones::Vector{AbstractZoneFeature}
    properties::AbstractDict
end
zonecollection(result::Atp45Result) = result.zones
properties(result::Atp45Result) = result.properties

Base.getindex(result::Atp45Result, name::Symbol) = getindex(properties(result), name)

function Base.show(io::IO, mime::MIME"text/plain", result::Atp45Result)
    println(io, "Atp45Result with $(length(zonecollection(result))) zones and properties:")
    show(io, mime, properties(result))
end
