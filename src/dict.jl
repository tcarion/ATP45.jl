function build_verbose_tree(tree)
    AT.treemap(tree) do node
        newval = _format_node(node)
        (newval, children(node))
    end
end

_format_node(::TreeNode{<:String}) = [:id => "root"]
function _format_node(node::TreeNode{<:Union{AbstractCategory, AbstractModel, AbstractStability}}) :: Vector{<:Pair{Symbol, String}}
    to_include = [:id, :longname, :description, :note, :paramtype, :internalname]
    fs = Pair{Symbol, String}[]
    for ti in to_include
        nodeval = nodevalue(node)
        val = eval(ti)(nodeval)
        val !== "" && push!(fs, ti => eval(ti)(nodevalue(node)))
    end
    fs
end

_format_node(::TreeNode{<:Tuple}) = nothing

function tree_to_dict(node)
    val = nodevalue(node)
    if isnothing(val)
        return []
    end

    OrderedDict(val..., :children => [tree_to_dict(c) for c in children(node)])
end

build_verbose_tree() = build_verbose_tree(ATP45_TREE)