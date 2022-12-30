description(::Type) = ""
description(o::T) where T = description(T)

longname(::Type) = ""
longname(o::T) where T = longname(T)

id(::Type) = ""
id(o::T) where T = id(T)

note(::Type) = ""
note(o::T) where T = note(T)

paramtype(::Type) = ""
paramtype(o::T) where T = paramtype(T)

internalname(T::Type) = string(T)
internalname(o::T) where T = internalname(T)

byid(iid::String) = MAP_IDS[iid]

function add_ids_to_map(abstract_type)
    for ttype in subtypes(abstract_type)
        id(ttype) !== "" && push!(MAP_IDS, id(ttype) => ttype())
    end
end