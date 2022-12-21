
function (::Type{T})(args::Vararg{<:AbstractCategory}) where {T<:AbstractModel}
    args = sort_categories(args)
    T(args)
end

struct Simplified{T} <: AbstractModel{T}
    categories::T
end
# id(::Type{Simplified}) = "simplified"
# longname(::Type{Simplified}) = "Simplified procedure"
description(::Type{Simplified}) = "The simplified procedure is primarily used for immediate warning. As soon as possible the detailed procedures must be carried out. A typical situation where simplified procedures will be used is when the substance type and persistency are not known."
Simplified(arg::AbstractCategory) = Simplified(Tuple([arg]))

struct Detailed{T} <: AbstractModel{T}
    categories::T
end

Detailed(arg::AbstractCategory) = Detailed(Tuple([arg]))
# id(::Type{Simplified}) = "detailed"
# longname(::Type{Simplified}) = "Detailed procedure"

required_categories(::Type{<:Simplified}) = (AbstractWeapon,)
required_inputs(::Type{<:Simplified}) = (AbstractReleaseLocation{1, <:Number}, AbstractWind)

function (procedure::Simplified{T})(inputs...) where T
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    geometry = _calculate_geometry(procedure, inputs)
    Atp45Result(geometry |> collect, Dict("tobe" => "designed"))
end

# function (procedure::Simplified{Tuple{ChemicalWeapon}})(inputs...) 
#     wind = get_input(inputs, AbstractWind)
#     location = get_input(inputs, ReleaseLocation)

#     speed = wind_speed(wind)
#     release_radius = 2_000.
#     if speed * 3.6 > 10.
#         geometries = [
#             CircleLike(location, release_radius, Dict("type" => "release")),
#             TriangleLike(location, wind, 10_000., 2release_radius, Dict("type" => "hazard")),
#         ]
#     else
#         geometries = [
#             CircleLike(location, release_radius, Dict("type" => "release")),
#             CircleLike(location, 10_000., Dict("type" => "hazard")),
#         ]
#     end
#     Atp45Result(geometries, Dict("wind" => "wind"))
# end

######
###### Methods dispatching on the right ATP45 zones parameters according to the given categories and inputs.
######
_calculate_geometry(model::Simplified{Tuple{ChemicalWeapon}}, inputs) = _calculate_geometry(model, checkwind(inputs), inputs)
_calculate_geometry(::Simplified{Tuple{ChemicalWeapon}}, ::LowerThan10, inputs) = _circle_circle(inputs, 2_000, 10_000)
_calculate_geometry(::Simplified{Tuple{ChemicalWeapon}}, ::HigherThan10, inputs) = _circle_triangle(inputs, 2_000, 10_000)


######
###### Helper functions to avoid repetition when building the ATP45 zones. 
######
_circle_circle(location::AbstractReleaseLocation, inner_radius, outer_radius) = 
    CircleLike(location, inner_radius, Dict("type" => "release")), CircleLike(location, outer_radius, Dict("type" => "hazard"))

_circle_circle(inputs, inner_radius, outer_radius) = _circle_circle(get_location(inputs), inner_radius, outer_radius)

_circle_triangle(location::AbstractReleaseLocation, wind, inner_radius, dhd) = 
    CircleLike(location, inner_radius, Dict("type" => "release")), TriangleLike(location, wind, dhd, 2*inner_radius, Dict("type" => "hazard"))

_circle_triangle(inputs, inner_radius, dhd) = _circle_triangle(get_location(inputs), get_wind(inputs), inner_radius, dhd)

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
