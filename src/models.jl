
function Base.show(io::IO, ::MIME"text/plain", cats::NTuple{N, AbstractCategory}) where N
    println(io, "ATP45 categories with ids:")
    for (i, c) in enumerate(cats)
        method = i % length(cats) == 0 ? print : println
        method(io, " - $(id(c))")
    end
end

#
# Helper functions to avoid repetition when building the ATP45 zones. 
#
_circle(location::AbstractReleaseLocations, inner_radius) = (ReleaseZone(CircleLikeZone(location, inner_radius)), )

_circle(inputs, inner_radius) = _circle(get_location(inputs), inner_radius)


_circle_circle(location::AbstractReleaseLocations, inner_radius, outer_radius) = 
    ReleaseZone(CircleLikeZone(location, inner_radius)), HazardZone(CircleLikeZone(location, outer_radius))

_circle_circle(inputs, inner_radius, outer_radius) = _circle_circle(get_location(inputs), inner_radius, outer_radius)


_circle_triangle(location::AbstractReleaseLocations, wind, inner_radius, dhd) = 
    ReleaseZone(CircleLikeZone(location, inner_radius)), HazardZone(TriangleLikeZone(location, wind, dhd, 2*inner_radius))

_circle_triangle(inputs, inner_radius, dhd) = _circle_triangle(get_location(inputs), get_wind(inputs), inner_radius, dhd)

_two_circles(locations::AbstractReleaseLocations{2}, inner_radius, outer_radius) =
    ReleaseZone(_circle_hull(locations, inner_radius)), HazardZone(_circle_hull(locations, outer_radius))

_two_circles(inputs, inner_radius, outer_radius) = _two_circles(get_location(inputs), inner_radius, outer_radius)

_two_circle_triangle(locations::AbstractReleaseLocations{2}, wind, inner_radius, dhd) =
    ReleaseZone(_circle_hull(locations, inner_radius)), HazardZone(_triangle_hull(locations, wind, inner_radius, dhd))

_two_circle_triangle(inputs, inner_radius, dhd) = _two_circle_triangle(get_location(inputs), get_wind(inputs), inner_radius, dhd)

function _circle_hull(locations, radius)
    zone1 = CircleLikeZone(ATP45.coords(locations)[1], radius)
    zone2 = CircleLikeZone(ATP45.coords(locations)[2], radius)
    convexhull(zone1, zone2)
end

function _triangle_hull(locations, wind, inner_radius, dhd)
    zone1 = TriangleLikeZone(ATP45.coords(locations)[1], wind, dhd, 2*inner_radius)
    zone2 = TriangleLikeZone(ATP45.coords(locations)[2], wind, dhd, 2*inner_radius)
    convexhull(zone1, zone2)
end

function checkwind(wind::AbstractWind) ::AbstractWindCategory
    if wind_speed(wind) * 3.6 > 10.
        HigherThan10()
    else
        LowerThan10()
    end
end
checkwind(inputs) = checkwind(get_wind(inputs))

get_location(inputs) = get_input(inputs, AbstractReleaseLocations)
get_wind(inputs) = get_input(inputs, AbstractWind)
get_stability(inputs) = get_input(inputs, AbstractStability)