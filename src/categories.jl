abstract type AbstractCategory end

ParamType(::Type{<:AbstractCategory}) = Category()



"""
    AbstractAgent <: AbstractCategory
Discriminate between the type of agent (Chemical, Biological, Radiological, Nuclear)
"""
abstract type AbstractAgent <: AbstractCategory end
# ParamType(::Type{<:AbstractAgent}) = Category()

struct ChemicalAgent <: AbstractAgent end
id(::Type{ChemicalAgent}) = "chem"
longname(::Type{ChemicalAgent}) = "Chemical"

struct BiologicalAgent <: AbstractAgent end
id(::Type{BiologicalAgent}) = "bio"
longname(::Type{BiologicalAgent}) = "Biological"

struct RadiologicalAgent <: AbstractAgent end
id(::Type{RadiologicalAgent}) = "radio"
longname(::Type{RadiologicalAgent}) = "Radiological"

struct NuclearAgent <: AbstractAgent end
id(::Type{NuclearAgent}) = "nuclear"
longname(::Type{NuclearAgent}) = "Nuclear"



"""
    AbstractChemAgent <: AbstractCategory
Discriminate between the type of chemical agent (Weapon or Substance)
"""
abstract type AbstractChemAgent <: AbstractCategory end

struct ChemicalWeapon <: AbstractChemAgent end
id(::Type{ChemicalWeapon}) = "chem_weapon"
longname(::Type{ChemicalWeapon}) = "Chemical Weapon"

struct ChemicalSubstance <: AbstractChemAgent end
id(::Type{ChemicalSubstance}) = "chem_sub"
longname(::Type{ChemicalSubstance}) = "Chemical Substance"



"""
    AbstractModel
Determine the type of APT-45 that will be run (simplified or detailed).

"""
abstract type AbstractModel <: AbstractCategory end
ParamType(::Type{<:AbstractModel}) = Procedure()
internalname(T::Type{<:AbstractModel}) = string(_nonparamtype(T()))

struct Simplified <: AbstractModel end
longname(::Type{Simplified}) = "Simplified procedure"
description(::Type{Simplified}) = "The simplified procedure is primarily used for immediate warning. As soon as possible the detailed procedures must be carried out. A typical situation where simplified procedures will be used is when the substance type and persistency are not known."
id(::Type{Simplified}) = "simplified"

struct Detailed <: AbstractModel end
id(::Type{Detailed}) = "detailed"
longname(::Type{Detailed}) = "Detailed procedure"



"""
    AbstractReleaseType <: AbstractCategory
Discriminate between the release type (ex: Air Contaminating Attack, Ground Contaminating Attacks)
"""
abstract type AbstractReleaseType <: AbstractCategory end

struct ReleaseTypeA <: AbstractReleaseType end
description(::Type{ReleaseTypeA}) = "Release following an attack with an air contaminating (non-persistent) chemical agent."
longname(::Type{ReleaseTypeA}) = "Air Contaminating Attack"
id(::Type{ReleaseTypeA}) = "typeA"

struct ReleaseTypeB <: AbstractReleaseType end
description(::Type{ReleaseTypeB}) = "Release following an attack with a ground contaminating (persistent) chemical agent."
longname(::Type{ReleaseTypeB}) = "Ground Contaminating Attack"
id(::Type{ReleaseTypeB}) = "typeB"

struct ReleaseTypeC <: AbstractReleaseType end
description(::Type{ReleaseTypeC}) = "Detection of a chemical agent following an unobserved release."
longname(::Type{ReleaseTypeC}) = "Chemical Agent Release of Unknown Origin"
id(::Type{ReleaseTypeC}) = "typeC"

struct ReleaseBloodAgent <: AbstractReleaseType end
description(::Type{ReleaseBloodAgent}) = "Release following an attack with a blood agent."
longname(::Type{ReleaseBloodAgent}) = "Blood Agent Release"
id(::Type{ReleaseBloodAgent}) = "bloodAgent"

### Chemical Substance Release Types ###
struct ReleaseTypeD <: AbstractReleaseType end
description(::Type{ReleaseTypeD}) = "Release of chemical agent or TIC, commonly used in industrial processes."
longname(::Type{ReleaseTypeD}) = "Chemical Substance Release"
id(::Type{ReleaseTypeD}) = "typeD"

struct SubType1 <: AbstractReleaseType end
description(::Type{SubType1}) = "Release from a stationary leaking tank or container."
longname(::Type{SubType1}) = "Point Source Release from Tank or Container"
id(::Type{SubType1}) = "subtype1"

struct SubType2 <: AbstractReleaseType end
description(::Type{SubType2}) = "Release from a leaking tank or container on the move, resulting in the dispersion of a chemical over an extended distance."
longname(::Type{SubType2}) = "Moving Source Release from Tank or Container"
id(::Type{SubType2}) = "subtype2"

struct SubType3 <: AbstractReleaseType end
description(::Type{SubType3}) = "Detection of a chemical substance after an unobserved release."
longname(::Type{SubType3}) = "Chemical Substance Unobserved Release"
id(::Type{SubType3}) = "subtype3"
########

struct ReleaseTypeP <: AbstractReleaseType end
description(::Type{ReleaseTypeP}) = "Release with localized exploding munitions or point release."
longname(::Type{ReleaseTypeP}) = "Localized Exploding Munitions or Point Release"
id(::Type{ReleaseTypeP}) = "typeP"

struct ReleaseTypeQ <: AbstractReleaseType end
description(::Type{ReleaseTypeQ}) = "Release with munitions that cover a larger area."
longname(::Type{ReleaseTypeQ}) = "Larger Area Covering Munitions Release"
id(::Type{ReleaseTypeQ}) = "typeQ"

struct ReleaseTypeR <: AbstractReleaseType end
description(::Type{ReleaseTypeR}) = "Release where the location of the release is known, but the type of container is either NKN, or an SPR or GEN releasing material over 2 km."
longname(::Type{ReleaseTypeR}) = "Release at Known Location, but Container NKN, or SPR/GEN over 2 km"
id(::Type{ReleaseTypeR}) = "typeR"

struct ReleaseTypeS <: AbstractReleaseType end
description(::Type{ReleaseTypeS}) = "Detection of a biological agent following an unobserved release."
longname(::Type{ReleaseTypeS}) = "Biological Agent Release of Unknown Origin"
id(::Type{ReleaseTypeS}) = "typeS"



"""
    AbstractReleaseSize <: AbstractCategory
Discriminate between the release size (Small, Medium, Large, Extra Large)
"""
abstract type AbstractReleaseSize <: AbstractCategory end

struct ReleaseSmall <: AbstractReleaseSize end
description(::Type{ReleaseSmall}) = "Release ≤ 200 litres."
longname(::Type{ReleaseSmall}) = "Small Release"
id(::Type{ReleaseSmall}) = "small"

struct ReleaseMedium <: AbstractReleaseSize end
description(::Type{ReleaseMedium}) = "200 litres < Release ≤ 1500 kg."
longname(::Type{ReleaseMedium}) = "Medium Release"
id(::Type{ReleaseMedium}) = "med"

struct ReleaseLarge <: AbstractReleaseSize end
description(::Type{ReleaseLarge}) = "1500 kg < Release ≤ 50000 kg."
longname(::Type{ReleaseLarge}) = "Large Release"
id(::Type{ReleaseLarge}) = "large"

struct ReleaseExtraLarge <: AbstractReleaseSize end
description(::Type{ReleaseExtraLarge}) = "Release > 50000 kg."
longname(::Type{ReleaseExtraLarge}) = "Extra Large Release"
id(::Type{ReleaseExtraLarge}) = "xlarge"



"""
    AbstractAgentName <: AbstractCategory
Select the substance released for chemical release type D
"""
abstract type AbstractAgentName <: AbstractCategory end

struct Sarin <: AbstractAgentName end
longname(::Type{Sarin}) = "Sarin"
id(::Type{Sarin}) = "sarin"



"""
    AbstractWindCategory <: AbstractCategory
Discriminate between the wind speed under/equal, and over 10 km/h
"""
abstract type AbstractWindCategory <: AbstractCategory end
ParamType(::Type{<:AbstractWindCategory}) = WindChoice()

struct LowerThan10 <: AbstractWindCategory end
description(::Type{LowerThan10}) = "The wind is <= 10km/h."
id(::Type{LowerThan10}) = "windlowerthan10"

struct HigherThan10 <: AbstractWindCategory end
description(::Type{HigherThan10}) = "The wind is > 10km/h."
id(::Type{HigherThan10}) = "windhigherthan10"



"""
    AbstractContainerType <: AbstractCategory
Discriminate between the types of containers for chemical weapon (ex: Bomb, Mine, Shell, etc.)
"""
abstract type AbstractContainerType <: AbstractCategory end

macro container(typ, id, descr)
    containermacro(typ, id, descr)
end

function containermacro(typ, id, descr)
    quote
        struct $typ <: AbstractContainerType end
        id(::Type{$typ}) = $id
        longname(::Type{$typ}) = $descr
    end
end

const container_types = (
    (:Bomblet, "BML", "Bomblet"),
    (:Bomb, "BOM", "Bomb"),
    (:Shell, "SHL", "Shell"),
    (:Spray, "SPR", "Spray (tank)"),
    (:Generator, "GEN", "Generator (Aerosol)"),
    (:Mine, "MNE", "Mine"),
    (:Missile, "MSL", "Missile"),
    (:AirRocket, "ARKT", "Air burst rocket"),
    (:SurfaceRocket, "SRKT", "Surface burst rocket"),
    (:MissilesPayload, "MPL", "Surface burst missiles payload"),
    (:NotKnown, "NKN", "Unknown munitions"),
)

for ct in container_types
    eval(containermacro(ct...))
end



"""
    AbstractContainerGroup <: AbstractCategory
Group together the container types (for chemical weapons) which lead to the same result
"""
abstract type AbstractContainerGroup <: AbstractCategory end

struct ContainerGroup <: AbstractContainerGroup
    name::Symbol
    content::Vector{<:AbstractContainerType}
end

const container_groups = (
    ContainerGroupA = [Bomblet, Bomb, SurfaceRocket, AirRocket, Shell, Mine, NotKnown, Missile],
    ContainerGroupB = [Bomblet, Shell, Mine, SurfaceRocket, Missile],
    ContainerGroupC = [Bomb, NotKnown, AirRocket, Missile],
    ContainerGroupD = [Spray, Generator],
    ContainerGroupE = [Shell, Bomblet, Mine],
    ContainerGroupF = [MissilesPayload, Bomb, SurfaceRocket, AirRocket, NotKnown],
)

Base.in(item::AbstractContainerType, collection::AbstractContainerGroup) = item in collection.content
ParamType(::Type{ContainerGroup}) = Group()
id(group::ContainerGroup) = (lowercase ∘ string)(group.name)
==(a::T, b::T) where T <: AbstractContainerGroup = a.name == b.name

function containergroupmacro(name, group)
    quote
        const $name = Union{$(group...)}
        $name() = ContainerGroup($(Expr(:quote, name)), [ct() for ct in $group])
    end
end

# Create the ContainerGroups methods and add the categories to the MAP_IDS
for (k, v) in pairs(container_groups)
    eval(containergroupmacro(k, v))
    instantiated_group = eval(k)()
    push!(MAP_IDS, id(instantiated_group) => instantiated_group)
end



### Order the categories ###
categories_order() = [AbstractAgent, AbstractReleaseType, AbstractContainerGroup, AbstractContainerType]

function sort_categories(categories)
    order = categories_order()
    ordered = AbstractCategory[]
    for ocat in order
        icategory = findfirst(isa.(categories, Ref(ocat)))
        !isnothing(icategory) && push!(ordered, categories[icategory])
    end
    Tuple(ordered)
end
