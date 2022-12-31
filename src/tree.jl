
# # const DECISION_TREE = Dict(
# const DECISION_TREE = Dict(
#     Simplified => Dict(
#         ChemicalWeapon => (:_circle_circle, 2_000, 10_000),
#         BiologicalWeapon => (:_circle_circle, 2_000, 10_000),
#     ),
#     Detailed => Dict(
#         ChemicalWeapon => Dict(
#             ReleaseTypeA => Dict(
#                 LowerThan10 => (:_circle_circle, 1_000, 10_000),
#                 HigherThan10 => Dict(
#                     ContainerGroupE => Dict(
#                         Unstable => (:_circle_triangle, 1_000, 10_000),
#                         Neutral => (:_circle_triangle, 1_000, 30_000),
#                         Stable => (:_circle_triangle, 1_000, 50_000),
#                     ),
#                     ContainerGroupF => Dict(
#                         Unstable => (:_circle_triangle, 1_000, 15_000),
#                         Neutral => (:_circle_triangle, 1_000, 30_000),
#                         Stable => (:_circle_triangle, 1_000, 50_000),
#                     ),
#                 )
#             )
#         ),
#         BiologicalWeapon => (:_circle_circle, 2_000, 10_000),
#     )
# )


# const DECISION_TREE = Dict(
const DECISION_TREE = [
    Simplified => [
        ChemicalWeapon => [
            LowerThan10 => (:_circle_circle, 2_000, 10_000),
            HigherThan10 => (:_circle_triangle, 2_000, 10_000),
        ],
        BiologicalWeapon => [
            LowerThan10 => (:_circle_circle, 2_000, 10_000),
            HigherThan10 => (:_circle_triangle, 2_000, 10_000),
        ],
    ],
    Detailed => [
        ChemicalWeapon => [
            ReleaseTypeA => [
                LowerThan10 => (:_circle_circle, 1_000, 10_000),
                HigherThan10 => [
                    ContainerGroupE => [
                        Unstable => (:_circle_triangle, 1_000, 10_000),
                        Neutral => (:_circle_triangle, 1_000, 30_000),
                        Stable => (:_circle_triangle, 1_000, 50_000),
                    ],
                    ContainerGroupF => [
                        Unstable => (:_circle_triangle, 1_000, 15_000),
                        Neutral => (:_circle_triangle, 1_000, 30_000),
                        Stable => (:_circle_triangle, 1_000, 50_000),
                    ],
                ],
            ],
            ReleaseTypeB => [
                ContainerGroupB => [
                    LowerThan10 => (:_circle_circle, 1_000, 10_000),
                    HigherThan10 => (:_circle_triangle, 1_000, 10_000),
                ],
                ContainerGroupC => [
                    LowerThan10 => (:_circle_circle, 2_000, 10_000),
                    HigherThan10 => (:_circle_triangle, 2_000, 10_000),
                ],
                ContainerGroupD => (nothing,)
            ],
            ReleaseTypeC => (:_circle, 10_000),
        ],
        BiologicalWeapon => (nothing,),
    ],
]

mutable struct TreeNode{T} <: AT.AbstractNode{T}
    value::T
    parent::Union{Nothing, TreeNode}
    children::Vector{TreeNode}
    sequence::Vector{Any}
    TreeNode(value::T, parent, children=TreeNode[]) where T = new{T}(value, parent, children)
end
AbstractTrees.ParentLinks(::Type{<:TreeNode}) = StoredParents()

# TreeNode(dict::AbstractDict) = TreeNode("root", nothing, [TreeNode(pair, "root") for pair in collect(dict)])
function TreeNode(vec::AbstractVector)
    newnode = TreeNode("root", nothing)
    newnode.children = [TreeNode(pair, newnode) for pair in vec]
    newnode
end
function TreeNode(pair::Pair, parent = nothing)
    k, v = pair
    value = k()

    if v isa AbstractVector
        newnode = TreeNode(value, parent)
        children = map(collect(v)) do child_pair
            TreeNode(child_pair, newnode)
        end
        newnode.children = children
        newnode
    else
        newnode = TreeNode(k(), parent)
        newnode.children = [TreeNode(v, newnode)]
        newnode
    end
end

children(node::TreeNode) = node.children
parent(node::TreeNode) = node.parent
nodevalue(node::TreeNode) = node.value

build_tree() = TreeNode(DECISION_TREE)

function allparents(node::TreeNode)
    parents = TreeNode[]
    p = parent(node)
    while true
        isnothing(p) && return parents
        push!(parents, p)
        node = p
        p = parent(p)
    end
end

function children_value_type(node::TreeNode)
    vals = nodevalue.(children(node))
    eltype(vals)
end

"""
    descend(node::TreeNode, model_params) :: TreeNode
Discriminate between the children of `node` according to the parameters in `model_params`.

# Examples
julia> ex = Simplified => [
               ChemicalWeapon => [
                   LowerThan10 => (:_circle_circle, 2_000, 10_000),
                   HigherThan10 => (:_circle_triangle, 2_000, 10_000),
               ],
               BiologicalWeapon => [
                   LowerThan10 => (:_circle_circle, 1_000, 10_000),
                   HigherThan10 => (:_circle_triangle, 1_000, 10_000),
               ],
           ]
julia> model_params = (BiologicalWeapon(),)
julia> descend(TreeNode(ex), model_params)
BiologicalWeapon()
├─ LowerThan10()
│  └─ (:_circle_circle, 1000, 10000)
└─ HigherThan10()
   └─ (:_circle_triangle, 1000, 10000)
"""
function descend(node::TreeNode, model_params) :: TreeNode
    node_children = children(node)
    vals = nodevalue.(node_children)
    children_type = eltype(vals)
    ichild = _find_node(children_type, vals, model_params)
    ichild = isnothing(ichild) ? 1 : ichild
    node_children[ichild]
    # _descend_with_find(node, model)
end

"""
    descendall(node::TreeNode, model_params) :: TreeNode{<:Tuple}
Browse the tree starting at `node`, choosing the path following what is specified in `model_params`.

# Examples
```julia-repl
julia> ex = Simplified => [
               ChemicalWeapon => [
                   LowerThan10 => (:_circle_circle, 2_000, 10_000),
                   HigherThan10 => (:_circle_triangle, 2_000, 10_000),
               ],
               BiologicalWeapon => [
                   LowerThan10 => (:_circle_circle, 1_000, 10_000),
                   HigherThan10 => (:_circle_triangle, 1_000, 10_000),
               ],
           ]
julia> model_params = (BiologicalWeapon(), WindDirection(45, 2))
julia> descendall(TreeNode(ex), model_params)
(:_circle_triangle, 1000, 10000)
```
"""
function descendall(node::TreeNode, model_params) :: TreeNode{<:Tuple}
    next = descend(node, model_params)

    while true
        next isa TreeNode{<:Tuple} && return next
        next = descend(next, model_params)
    end
end

function _find_node(::Type{<:AbstractModel}, vals, model_params)
    # findwithtype(model_params, AbstractModel)
    param = _getisa(model_params, AbstractModel)
    # Quite ugly, should find a better solution
    inode = findisa(vals, _nonparamtype(param))
    inode
end

function _find_node(children_type::Type{<:Union{AbstractCategory, AbstractStability}}, vals, model_params)
    param = _getisa(model_params, children_type)
    inode = findisa(vals, param)
    inode
end

function _find_node(::Type{<:AbstractWindCategory}, vals, model_params)
    param = _getisa(model_params, AbstractWind)
    category = checkwind(param)
    inode = findisa(vals, category)
    inode
end

function _find_node(::Type{<:AbstractContainerGroup}, vals, model_params)
    param = _getisa(model_params, AbstractContainerType)
    inode = findfirst(x -> param in x, vals)
    inode
end

_find_node(::Type{<:Tuple}, vals, model_params) = nothing

function _descend_with_find(node, tofind)
    node_children = children(node)
    vals = nodevalue.(node_children)
    i = findisa(vals, tofind)
    node_children[i]
end

function _getisa(model_params, tofind)
    iparams = findisa(model_params, tofind)
    isnothing(iparams) && throw(MissingInputsException([tofind]))
    model_params[iparams]
end