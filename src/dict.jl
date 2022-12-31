function build_verbose_tree(tree)
    AT.treemap(tree) do node
        newval = _format_node(node)
        (newval, children(node))
    end
end

_format_node(::TreeNode{<:String}) = [:id => "root"]
function _format_node(node::TreeNode{<:Union{AbstractCategory, AbstractModel, AbstractStability}})
    val = nodevalue(node)
    properties(val)
end

_format_node(::TreeNode{<:Tuple}) = nothing

function tree_to_dict(node)
    val = nodevalue(node)
    if isnothing(val)
        return nothing
    end

    OrderedDict(val..., :children => [tree_to_dict(c) for c in children(node)])
end

build_verbose_tree() = build_verbose_tree(ATP45_TREE)

"""
    properties(iid::String)
    properties(obj)
Give the properties defined on the ATP45 object, given the object itsels `obj` or its id `iid`.

# Examples
julia> ATP45.properties(ChemicalWeapon())
4-element Vector{Pair{Symbol, String}}:
           :id => "chem"
     :longname => "Chemical"
    :paramtype => "category"
 :internalname => "ChemicalWeapon"
"""
function properties(obj) :: Vector{<:Pair{Symbol, String}}
    to_include = [:id, :longname, :description, :note, :paramtype, :internalname]
    fs = Pair{Symbol, String}[]
    for ti in to_include
        val = eval(ti)(obj)
        val !== "" && push!(fs, ti => eval(ti)(obj))
    end
    fs
end
properties(iid::String) :: Vector{<:Pair{Symbol, String}} = properties(MAP_IDS[iid])