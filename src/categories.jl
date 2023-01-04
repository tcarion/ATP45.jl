abstract type AbstractCategory end

ParamType(::Type{<:AbstractCategory}) = Category()

"""
    AbstractWeapon <: AbstractCategory
Discriminate between the type of weapon (Chemical, Biological, Radiological, Nuclear)
"""
abstract type AbstractWeapon <: AbstractCategory end
# ParamType(::Type{<:AbstractWeapon}) = Category()

struct ChemicalWeapon <: AbstractWeapon end
id(::Type{ChemicalWeapon}) = "chem"
longname(::Type{ChemicalWeapon}) = "Chemical"

struct BiologicalWeapon <: AbstractWeapon end
id(::Type{BiologicalWeapon}) = "bio"
longname(::Type{BiologicalWeapon}) = "Biological"

struct RadiologicalWeapon <: AbstractWeapon end
id(::Type{RadiologicalWeapon}) = "radio"
longname(::Type{RadiologicalWeapon}) = "Radiological"

struct NuclearWeapon <: AbstractWeapon end
id(::Type{NuclearWeapon}) = "nuclear"
longname(::Type{NuclearWeapon}) = "Nuclear"

"""
    AbstractReleaseType <: AbstractCategory
Discriminate between the release type (ex: Air Contaminating Attack, Ground Contaminating Attacks)
"""
abstract type AbstractReleaseType <: AbstractCategory end
description(::Type{<:AbstractReleaseType}) = "No description"
longname(::Type{<:AbstractReleaseType}) = "Unknown release type"
id(::Type{<:AbstractReleaseType}) = ""
note(::Type{<:AbstractReleaseType}) = ""

struct ReleaseTypeA <: AbstractReleaseType end
description(::Type{ReleaseTypeA}) = "Release following an attack with an air contaminating (non-persistent) chemical agent."
longname(::Type{ReleaseTypeA}) = "Air Contaminating Attack."
id(::Type{ReleaseTypeA}) = "typeA"
note(::Type{ReleaseTypeA}) = """
Type A attack is considered the immediate, short period worst-case attack scenario because it is an immediate hazard. Assume a Type A attack if:
- Liquid agent cannot be observed or;
- No passive methods or indicators confirm the hazard to be a persistent agent.
"""

struct ReleaseTypeB <: AbstractReleaseType end
description(::Type{ReleaseTypeB}) = "Release following an attack with a ground contaminating (persistent) chemical agent."
longname(::Type{ReleaseTypeB}) = "Ground Contaminating Attacks."
id(::Type{ReleaseTypeB}) = "typeB"

struct ReleaseTypeC <: AbstractReleaseType end
description(::Type{ReleaseTypeC}) = "Detection of a chemical agent following an unobserved release."
longname(::Type{ReleaseTypeC}) = "Chemical Agent Release of Unknown Origin."
id(::Type{ReleaseTypeC}) = "typeC"


abstract type AbstractWindCategory <: AbstractCategory end
ParamType(::Type{<:AbstractWindCategory}) = WindChoice()

struct LowerThan10 <: AbstractWindCategory end
description(::Type{LowerThan10}) = "The wind is <= 10km/h."
id(::Type{LowerThan10}) = "windlowerthan10"

struct HigherThan10 <: AbstractWindCategory end
description(::Type{HigherThan10}) = "The wind is > 10km/h."
id(::Type{HigherThan10}) = "windhigherthan10"

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

const container_groups = (
    ContainerGroupA = [Bomblet, Bomb, SurfaceRocket, AirRocket, Shell, Mine, NotKnown, Missile],
    ContainerGroupB = [Bomblet, Shell, Mine, SurfaceRocket, Missile],
    ContainerGroupC = [Bomb, NotKnown, AirRocket, Missile],
    ContainerGroupD = [Spray, Generator],
    ContainerGroupE = [Shell, Bomblet, Mine],
    ContainerGroupF = [MissilesPayload, Bomb, SurfaceRocket, AirRocket, NotKnown],
)

abstract type AbstractContainerGroup <: AbstractCategory end
struct ContainerGroup <: AbstractContainerGroup
    name::Symbol
    content::Vector{<:AbstractContainerType}
end
Base.in(item::AbstractContainerType, collection::AbstractContainerGroup) = item in collection.content
ParamType(::Type{ContainerGroup}) = Group()
id(group::ContainerGroup) = (lowercase ∘ string)(group.name)

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


categories_order() = [AbstractWeapon, AbstractReleaseType, AbstractContainerType]

function sort_categories(categories)
    order = categories_order()
    ordered = AbstractCategory[]
    for ocat in order
        icategory = findfirst(isa.(categories, Ref(ocat)))
        !isnothing(icategory) && push!(ordered, categories[icategory])
    end
    Tuple(ordered)
end