description(::Type) = ""
description(o::T) where T = description(T)

longname(::Type) = ""
longname(o::T) where T = longname(T)

note(::Type) = ""
note(o::T) where T = note(T)

internalname(T::Type) = string(T)
internalname(o::T) where T = internalname(T)

abstract type ParamType end
struct Procedure <: ParamType end
struct Category <: ParamType end
struct Meteo <: ParamType end
struct Group <: ParamType end
struct Location <: ParamType end
struct WindChoice <: ParamType end
struct NoParam <: ParamType end

ParamType(o::T) where T = ParamType(T)
ParamType(::Type) = NoParam()

paramtype(::T) where T <: ParamType = begin
    str = string(Symbol(T))
    spl = split(str, ".")
    str = spl[end]
    lowercase(str)
end
paramtype(::NoParam) = ""
paramtype(o) = paramtype(ParamType(o))

content(o) = content(ParamType(o), o)
content(::ParamType, o) = ""
content(::Group, o) = [id(c) for c in o.content]

id(o) = id(ParamType(o), o)
id(::ParamType, o) = id(typeof(o))
id(::Group, o) = id(o)

function byid(iid::String) 
    try
        MAP_IDS[iid]
    catch e
        if e isa KeyError
            error("The id you provided does not exist. You can use `map_ids()` to see the existing ids and which object they correspond to. You can
            also have more information by looking at the decision tree with `decision_tree()`")
        else
            rethrow()
        end
    end
end

function add_ids_to_map(abstract_type)
    for ttype in subtypes(abstract_type)
        id(ttype) !== "" && push!(MAP_IDS, id(ttype) => ttype())
    end
end

cast_id(param) = param isa AbstractString ? byid(param) : param

filter_paramtype(parameters, p::ParamType) = filter(x -> ParamType(x) == p, parameters)