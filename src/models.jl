"""
    AbstractModel
Determine the type of APT-45 that will be run. Each model is a callable object that takes the needed inputs as arguments.

"""
abstract type AbstractModel end
ParamType(::Type{<:AbstractModel}) = Procedure()
internalname(T::Type{<:AbstractModel}) = string(_nonparamtype(T()))


# I'm not very satisfied with this implementation, but that's the price I had to pay to make the instanciation
# of these types kind of user friendly. This way, Simplified("chem"), Simplified("chem", ReleaseTypeA()) and
# Simplified((ReleaseTypeA(), ChemicalWeapon())) all work. Maybe there's a clever way to implement this though.
function (::Type{T})(args::Vararg{Union{AbstractCategory, String}}) where {T<:AbstractModel}
    cast = cast_id.(args)
    args = sort_categories(cast)
    T(args)
end
(::Type{T})(args::Tuple{Vararg{AbstractCategory}}) where {T<:AbstractModel} = T(args)

categories(procedure::AbstractModel) = procedure.categories

function Base.show(io::IO, ::MIME"text/plain", procedure::AbstractModel)
    print(io, "`$(id(procedure))` procedure with ")
    cat = categories(procedure)
    if cat == ()
        print(io, "no parameters.")
    else
        println(io, "parameters:")
        for (i, c) in enumerate(cat)
            method = i % length(cat) == 0 ? print : println
            method(io, " - $(id(c))")
        end
    end
end

struct Simplified <: AbstractModel
    categories::Tuple{Vararg{AbstractCategory}}
end
Simplified() = Simplified(())
function Simplified(arg::Union{ATP45.AbstractCategory, String})
    args = Tuple([arg])
    cast = cast_id.(args)
    args = sort_categories(cast)
    Simplified(args)
end
longname(::Type{Simplified}) = "Simplified procedure"
description(::Type{Simplified}) = "The simplified procedure is primarily used for immediate warning. As soon as possible the detailed procedures must be carried out. A typical situation where simplified procedures will be used is when the substance type and persistency are not known."
id(::Type{Simplified}) = "simplified"

struct Detailed <: AbstractModel
    categories::Tuple{Vararg{AbstractCategory}}
end
Detailed() = Detailed(())
function Detailed(arg::Union{ATP45.AbstractCategory, String})
    args = Tuple([arg])
    cast = cast_id.(args)
    args = sort_categories(cast)
    Detailed(args)
end
id(::Type{Detailed}) = "detailed"
longname(::Type{Detailed}) = "Detailed procedure"

#
# Helper functions to avoid repetition when building the ATP45 zones. 
#
_circle(location::AbstractReleaseLocation, inner_radius) = (ReleaseZone(CircleLikeZone(location, inner_radius)), )

_circle(inputs, inner_radius) = _circle(get_location(inputs), inner_radius)


_circle_circle(location::AbstractReleaseLocation, inner_radius, outer_radius) = 
    ReleaseZone(CircleLikeZone(location, inner_radius)), HazardZone(CircleLikeZone(location, outer_radius))

_circle_circle(inputs, inner_radius, outer_radius) = _circle_circle(get_location(inputs), inner_radius, outer_radius)


_circle_triangle(location::AbstractReleaseLocation, wind, inner_radius, dhd) = 
    ReleaseZone(CircleLikeZone(location, inner_radius)), HazardZone(TriangleLikeZone(location, wind, dhd, 2*inner_radius))

_circle_triangle(inputs, inner_radius, dhd) = _circle_triangle(get_location(inputs), get_wind(inputs), inner_radius, dhd)

_two_circles(locations::AbstractReleaseLocation{2}, inner_radius, outer_radius) =
    ReleaseZone(_circle_hull(locations, inner_radius)), HazardZone(_circle_hull(locations, outer_radius))

_two_circles(inputs, inner_radius, outer_radius) = _two_circles(get_location(inputs), inner_radius, outer_radius)

_two_circle_triangle(locations::AbstractReleaseLocation{2}, wind, inner_radius, dhd) =
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

get_location(inputs) = get_input(inputs, AbstractReleaseLocation)
get_wind(inputs) = get_input(inputs, AbstractWind)
get_stability(inputs) = get_input(inputs, AbstractStability)

function _group_parameters(model::T) where T <: AbstractModel
    grouped = []
    push!(grouped, model)
    for cat in model.categories
        push!(grouped, cat)
    end
    grouped
end
function _group_parameters(model, inputs)
    grouped = _group_parameters(model)
    for input in inputs
        push!(grouped, input)
    end
    grouped
end