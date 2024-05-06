function build_verbose_tree(tree)
    AT.treemap(tree) do node
        newval = _format_node(node)
        (newval, children(node))
    end
end

_format_node(::TreeNode{<:String}) = (id = "root",)
function _format_node(node::TreeNode{<:Union{AbstractCategory, AbstractModel, AbstractStability, <:Leaf}})
    val = nodevalue(node)
    properties(val)
end

_format_node(::TreeNode{<:Tuple}) = nothing
function _format_node(::TreeNode{<:Leaf{N}}) where N
    (id = "leaf", description = string(N), note = "number of required release locations") 
end

function tree_to_dict(node)
    val = nodevalue(node)
    if isnothing(val)
        return nothing
    end

    OrderedDict(collect(pairs(val))..., :children => [tree_to_dict(c) for c in children(node)])
end

build_verbose_tree(wind::AbstractWind) = build_verbose_tree(ATP45_TREE(wind))

"""
    properties(iid::String)
    properties(obj)
Give the properties defined on the ATP45 object, given the object itsels `obj` or its id `iid`.

# Examples
```julia-repl
julia> ATP45.properties(ChemicalWeapon())
4-element Vector{Pair{Symbol, String}}:
           :id => "chem_weapon"
     :longname => "Chemical Weapon"
    :paramtype => "category"
 :internalname => "ChemicalWeapon"
```
"""
function properties(obj)
    to_include = [:id, :longname, :description, :note, :paramtype, :internalname, :content]
    fs = Pair{Symbol, Any}[]
    for ti in to_include
        val = eval(ti)(obj)
        val !== "" && push!(fs, ti => eval(ti)(obj))
    end
    (; fs...)
end
properties(iid::String) = properties(MAP_IDS[iid])
