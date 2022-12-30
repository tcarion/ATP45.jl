
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
required_inputs(::Type{<:Detailed}) = (AbstractReleaseLocation{1, <:Number}, AbstractWind)
required_inputs(::Type{<:Detailed{Tuple{ChemicalWeapon, ReleaseTypeC}}}) = (AbstractReleaseLocation{1, <:Number},)
# required_inputs(::Type{<:Detailed{Tuple{ChemicalWeapon, ReleaseTypeA}}}) = (AbstractReleaseLocation{1, <:Number},)

#
# Helper functions to avoid repetition when building the ATP45 zones. 
#
_circle(location::AbstractReleaseLocation, inner_radius) = (CircleLike(location, inner_radius, Dict("type" => "release")), )

_circle(inputs, inner_radius) = _circle(get_location(inputs), inner_radius)


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