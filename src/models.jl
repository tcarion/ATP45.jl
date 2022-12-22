
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

function (procedure::Simplified{T})(inputs...) where T <: Tuple{Union{RadiologicalWeapon, NuclearWeapon}}
    error("The simplified procedure for radiological and nuclear weapon is not implemented yet.")
end

function (procedure::Simplified{T})(inputs...) where T
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    geometry = _calculate_geometry(procedure, inputs)
    Atp45Result(geometry |> collect, Dict("tobe" => "designed"))
end

function (procedure::Detailed{T})(inputs...) where T <: Tuple{Union{BiologicalWeapon, RadiologicalWeapon, NuclearWeapon}}
    error("The detailed procedure for biological, radiological and nuclear weapon is not implemented yet.")
end

function (procedure::Detailed{T})(inputs...) where T
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    geometry = _calculate_geometry(procedure, inputs)
    Atp45Result(geometry |> collect, Dict("tobe" => "designed"))
end

#
# Methods dispatching on the right ATP45 zones parameters according to the given categories and inputs.
#

##
## Simplified procedures
##
_calculate_geometry(model::Simplified{Tuple{T}}, inputs) where T<:AbstractWeapon = _calculate_geometry(model, checkwind(inputs), inputs)

###
### Chemical and Biological weapons
###
_calculate_geometry(::Simplified{Tuple{T}}, ::LowerThan10, inputs) where T<:Union{ChemicalWeapon, BiologicalWeapon} = _circle_circle(inputs, 2_000, 10_000)
_calculate_geometry(::Simplified{Tuple{T}}, ::HigherThan10, inputs) where T<:Union{ChemicalWeapon, BiologicalWeapon} = _circle_triangle(inputs, 2_000, 10_000)

##
## Detailed procedures
##

###
### Chemical weapon
###

####
#### Type A releases
####
_calculate_geometry(model::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeA, Vararg{<:AbstractContainerType}}}, inputs) = _calculate_geometry(model, checkwind(inputs), inputs)
_calculate_geometry(::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeA}}, ::LowerThan10, inputs) = _circle_circle(inputs, 1_000, 10_000)
function _calculate_geometry(
    model::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeA, <:AbstractContainerType}}, 
    wind::HigherThan10, 
    inputs)

    stability = try
        get_stability(inputs)
    catch e
        if e isa ErrorException
            throw(MissingInputsException([AbstractStability])) 
        end
        throw(e)
    end
    _calculate_geometry(model, wind, stability, inputs)
end
_calculate_geometry(
    ::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeA, <:ContainerGroupE}}, 
    ::HigherThan10, 
    stab::AbstractStability, 
    inputs) = 
    _circle_triangle(inputs, 1_000, _dhd_group_e(stab))

_calculate_geometry(
    ::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeA, <:ContainerGroupF}}, 
    ::HigherThan10, 
    stab::AbstractStability, 
    inputs) = 
    _circle_triangle(inputs, 1_000, _dhd_group_f(stab))


# from Table 3-2 of ATP-45
_dhd_group_e(::Unstable) = 10_000
_dhd_group_e(::Neutral) = 30_000
_dhd_group_e(::Stable) = 50_000
_dhd_group_f(::Unstable) = 15_000
_dhd_group_f(::Neutral) = 30_000
_dhd_group_f(::Stable) = 50_000

####
#### Type B releases
####
_calculate_geometry(model::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeB, <:AbstractContainerType}}, inputs) = _calculate_geometry(model, checkwind(inputs), inputs)

#####
##### Container group B
#####
_calculate_geometry(::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeB, <:ContainerGroupB}}, ::LowerThan10, inputs) = _circle_circle(inputs, 1_000, 10_000)
_calculate_geometry(::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeB, <:ContainerGroupB}}, ::HigherThan10, inputs) = _circle_triangle(inputs, 1_000, 10_000)

#####
##### Container group C
#####
_calculate_geometry(::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeB, <:ContainerGroupC}}, ::LowerThan10, inputs) = _circle_circle(inputs, 2_000, 10_000)
_calculate_geometry(::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeB, <:ContainerGroupC}}, ::HigherThan10, inputs) = _circle_triangle(inputs, 2_000, 10_000)

#####
##### Container group D
#####
_calculate_geometry(::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeB, <:ContainerGroupD}}, ::LowerThan10, inputs) = error("Not implemented yet. Requires 2 releases")
_calculate_geometry(::Detailed{<:Tuple{ChemicalWeapon, ReleaseTypeB, <:ContainerGroupD}}, ::HigherThan10, inputs) = error("Not implemented yet. Requires 2 releases")

####
#### Type C releases
####
_calculate_geometry(::Detailed{Tuple{ChemicalWeapon, ReleaseTypeC}}, inputs) = _circle(inputs, 10_000)



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
