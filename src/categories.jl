abstract type AbstractCategory end

description(::Type) = ""
description(o::T) where T = description(T)

longname(::Type) = ""
longname(o::T) where T = longname(T)

id(::Type) = ""
id(o::T) where T = id(T)

note(::Type) = ""
note(o::T) where T = note(T)

"""
    AbstractWeapon <: AbstractCategory
Discriminate between the type of weapon (Chemical, Biological, Radiological, Nuclear)
"""
abstract type AbstractWeapon <: AbstractCategory end

struct ChemicalWeapon <: AbstractWeapon end
id(::Type{ChemicalWeapon}) = "chemical"
longname(::Type{ChemicalWeapon}) = "Chemical"

struct BiologicalWeapon <: AbstractWeapon end
id(::Type{BiologicalWeapon}) = "biological"
longname(::Type{BiologicalWeapon}) = "Biological"

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

struct LowerThan10 <: AbstractWindCategory end
description(::Type{LowerThan10}) = "The wind is <= 10km/h."

struct HigherThan10 <: AbstractWindCategory end
description(::Type{HigherThan10}) = "The wind is > 10km/h."

abstract type AbstractContainerType <: AbstractCategory end

# struct Bomblet <: AbstractContainerType end
# id(::Type{Bomblet}) = "BML"
# description(::Type{Bomblet}) = "Bomblet"

# struct Bomb <: AbstractContainerType end
# id(::Type{Bomb}) = "BOM"
# description(::Type{Bomb}) = "Bomb"

# struct Shell <: AbstractContainerType end
# id(::Type{Shell}) = "SHL"
# description(::Type{Shell}) = "Shell"

# struct Spray <: AbstractContainerType end
# id(::Type{Spray}) = "SPR"
# description(::Type{Spray}) = "Spray (tank)"

# struct Generator <: AbstractContainerType end
# id(::Type{Generator}) = "GEN"
# description(::Type{Generator}) = "Generator (Aerosol)"

# macro container(typ::String, id::String, descr::String)
macro container(typ, id, descr)
    containermacro(typ, id, descr)
end

# function containermacro(typ, id, descr)
#     quote
#         Base.@__doc__ struct $(eval(typ)) <: AbstractContainerType end
#         id(::Type{$(eval(typ))}) = $id
#         description(::Type{$(eval(typ))}) = $descr
#     end |> esc
# end
function containermacro(typ, id, descr)
    quote
        struct $typ <: AbstractContainerType end
        id(::Type{$typ}) = $id
        longname(::Type{$typ}) = $descr
    end
end

container_types = (
    (:Bomblet, "BML", "Bomblet"),
    (:Bomb, "BOM", "Bomb"),
    (:Shell, "SHL", "Shell"),
    (:Spray, "SPR", "Spray (tank)"),
    (:Generator, "GEN", "Generator (Aerosol)"),
    (:Mine, "MNE", "Mine"),
    (:Missile, "MSL", "Missile"),
    (:AirRocket, "ARKT", "Air burst rocket"),
    (:SurfaceRocket, "SRKT", "Surface burst rocket"),
    (:NotKnown, "NKN", "Not Known"),
)

for ct in container_types
    eval(containermacro(ct...))
end

abstract type AbstractContainerGroup <: AbstractCategory end
description(cg::Type{<:AbstractContainerGroup}) = join([longname(x) for x in content(cg)], ", ")

struct ContainerGroupA <: AbstractContainerGroup end
content(::Type{ContainerGroupA}) = (Bomblet, Bomb, SurfaceRocket, AirRocket, Shell, Mine, NotKnown, Missile)
id(::Type{ContainerGroupA}) = "groupeA"

struct ContainerGroupB <: AbstractContainerGroup end
content(::Type{ContainerGroupB}) = (Bomblet, Shell, Mine, SurfaceRocket, Missile)
id(::Type{ContainerGroupB}) = "groupeB"

struct ContainerGroupC <: AbstractContainerGroup end
content(::Type{ContainerGroupC}) = (Bomb, NotKnown, AirRocket, Missile)
id(::Type{ContainerGroupC}) = "groupeC"

struct ContainerGroupD <: AbstractContainerGroup end
content(::Type{ContainerGroupD}) = (Spray, Generator)
id(::Type{ContainerGroupD}) = "groupeD"

# nextchoice(args::Vararg{Tuple{<:AbstractCategory}}) = nextchoice(typeof.(args)...)
nextchoice(args::Vararg{<:AbstractCategory}) = nextchoice(typeof.(args)...)
# nextchoice(::T...) where {T<:AbstractCategory} = println(T)

nextchoice(::Type{ReleaseTypeA}) = [LowerThan10(), HigherThan10()]
nextchoice(::Type{ReleaseTypeA}, ::Type{LowerThan10}) = "circle"
nextchoice(::Type{ReleaseTypeA}, ::Type{HigherThan10}) = "triangle"

nextchoice(::Type{ReleaseTypeB}) = [ContainerGroupB(), ContainerGroupC(), ContainerGroupD()]
nextchoice(::Type{ReleaseTypeB}, ::Type{ContainerGroupB}) = [LowerThan10(), HigherThan10()]
nextchoice(::Type{ReleaseTypeB}, ::Type{ContainerGroupC}) = [LowerThan10(), HigherThan10()]
nextchoice(::Type{ReleaseTypeB}, ::Type{ContainerGroupD}) = [LowerThan10(), HigherThan10()]

nextchoice(::Type{ReleaseTypeB}, ::Type{ContainerGroupB}, ::Type{LowerThan10}) = "circle"

nextchoice(::Type{ReleaseTypeC}) = "circle"
# nextchoice(::Type{ReleaseTypeB}, ::Type{HigherThan10}) = "circle"