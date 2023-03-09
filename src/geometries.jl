const VectorCoordsType = Vector{<:Vector{<:Number}}

abstract type PointsSeries{N, T} end
# Just make the constructor ok with different types of arguments.
(::Type{T})(vec::VectorCoordsType) where {T <: PointsSeries} = T(Tuple(Tuple.(vec)))

(::Type{T})(vec::Vector{<:Number}) where {T <: PointsSeries} = T((Tuple(vec),))

(::Type{T})(args::Vararg{Vector{<:Number}}) where {T <: PointsSeries} = T(Tuple(Tuple.(args)))

coords(ps::PointsSeries) = ps.coords

abstract type AbstractReleaseLocations{N, T} <: PointsSeries{N, T} end
GI.isgeometry(geom::AbstractReleaseLocations)::Bool = true
GI.geomtrait(::AbstractReleaseLocations) = MultiPointTrait()
GI.ngeom(::MultiPointTrait, ::AbstractReleaseLocations{N, T}) where {N, T} = N
GI.getgeom(::MultiPointTrait, geom::AbstractReleaseLocations, i) = coords(geom)[i]

ParamType(::Type{<:AbstractReleaseLocations}) = Location()

"""
    ReleaseLocations{N, T}
Represents the `N` locations of the release(s).

# Examples
```julia-repl
julia> coords = [
    [6., 49.],
    [6., 51.],
]
julia> ReleaseLocations(coords)
ReleaseLocations{2, Float64}(((6.0, 49.0), (6.0, 51.0)))
```
"""
struct ReleaseLocations{N, T} <: AbstractReleaseLocations{N, T}
    coords::NTuple{N, NTuple{2, T}}
end
==(r1::ReleaseLocations, r2::ReleaseLocations) = coords(r1) == coords(r2)
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

_tolibgeos(geom) = LG.readgeom(convert(String, getwkt(geom)))
function convexhull(zone1::AbstractZone, zone2::AbstractZone)
    lgz1, lgz2 = _tolibgeos(zone1), _tolibgeos(zone2)  
    uunion = GI.union(lgz1, lgz2)
    lghull = GI.convexhull(uunion)
    Zone(GI.coordinates(lghull)[1])
end
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
function TriangleLikeZone(ReleaseLocations::ReleaseLocations{1, T}, wind::AbstractWind, dhd, back_distance) where T
    azimuth = wind_azimuth(wind)
    center = coords(ReleaseLocations)[1]
    triangle_coords = triangle_coordinates(center..., T(azimuth), T(dhd), T(back_distance))
    TriangleLikeZone{T}(ZoneBoundary(triangle_coords))
end
TriangleLikeZone(vec, wind::AbstractWind, dhd, back_distance) = TriangleLikeZone(ReleaseLocations(collect(vec)), wind, dhd, back_distance)

struct CircleLikeZone{N, T} <: AbstractZone{N, T}
    center::ReleaseLocations{1, T}
    radius::T
end

function CircleLikeZone(ReleaseLocations::ReleaseLocations{1, T}, radius::Number; numpoint = 100) where {T}
    CircleLikeZone{numpoint, T}(ReleaseLocations, radius)
end
CircleLikeZone(vec, radius::Number; numpoint = 100) = CircleLikeZone(ReleaseLocations(collect(vec)), radius; numpoint)

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
It implements the `GeoInterface.FeatureCollection` trait. The properties can be accessed with [`ATP45.properties`](@ref).

# Examples
This is the output type of [`run_atp`](@ref):
```jldoctest atp45result
result = run_atp("chem", "simplified", WindAzimuth(2., 90.), ReleaseLocations([4., 50.]))

# output
Atp45Result with 2 zones and properties:
Dict{Symbol, Any} with 3 entries:
  :locations  => ReleaseLocations{1, Float64}(((4.0, 50.0),))
  :categories => (ChemicalWeapon(), Simplified())
  :weather    => (WindAzimuth(2.0, 90.0),)
```

Specific zones can be access with the [`get_zones`](@ref) function:
```jldoctest atp45result
get_zones(result, "release")

# output
1-element Vector{ATP45.AbstractZoneFeature}:
 ReleaseZone{100, Float64}(ATP45.CircleLikeZone{100, Float64}(ReleaseLocations{1, Float64}(((4.0, 50.0),)), 2000.0))
```
"""
struct Atp45Result <: AbstractAtp45Result
    zones::Vector{AbstractZoneFeature}
    properties::AbstractDict
end
zonecollection(result::Atp45Result) = result.zones
properties(result::Atp45Result) = result.properties

Base.getindex(result::Atp45Result, name::Symbol) = getindex(properties(result), name)

"""
    get_zones(result::Atp45Result, type::String)
Get the zones in the ATP45Result `result` from reading the type propertie of the zones.
See [`ATP45.Atp45Result`]
"""
function get_zones(result::Atp45Result, type::String)
    zones = result.zones
    fzones = AbstractZoneFeature[]

    for zone in zones
        if properties(zone)[:type] == type
            push!(fzones, zone)
        end
    end
    return fzones
end

function Base.show(io::IO, mime::MIME"text/plain", result::Atp45Result)
    println(io, "Atp45Result with $(length(zonecollection(result))) zones and properties:")
    show(io, mime, properties(result))
end
