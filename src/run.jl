function (procedure::Simplified{T})(inputs...) where T
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    
    run(_group_parameters(procedure, inputs))
end

function (procedure::Detailed{T})(inputs...) where T
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    run(_group_parameters(procedure, inputs))
end

function run(model_parameters)
    leave = descendall(ATP45_TREE, model_parameters)
    nodeval = nodevalue(leave)
    nodeval isa Tuple{<:Nothing} && error("This case has not been implemented yet.")
    method, args... = nodeval
    geometry = eval(method)(model_parameters, args...)
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
