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

function byid(iid::String) 
    try
        MAP_IDS[iid]
    catch e
        if e isa KeyError
            error("The id you provided does not exist. You can use `map_ids()` to see the existing and which object they correspond to. You can
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

# function cast_ids(model_parameters)
#     formated_params = []
#     for param in model_parameters
#         if param isa AbstractString
#             push!(formated_params, byid(param))
#         else
#             push!(formated_params, param)
#         end
#     end
#     formated_params
# end
