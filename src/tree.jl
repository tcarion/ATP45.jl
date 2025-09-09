struct Leaf{N}
    locationtype::Type{ReleaseLocations{N}}
    fname::Symbol
    args::Tuple{Vararg{Any}}
end
Leaf(d, fname::Symbol, args::Vararg{Any}) = Leaf(d, fname, Tuple(args))

function decision_tree_full(wind::AbstractWind)
    DECISION_TREE = [
        ChemicalAgent => [
            ChemicalWeapon => [
                Simplified => [
                    LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 2_000, 10_000),
                    HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 2_000, 10_000)
                ],
                Detailed => [
                    ReleaseTypeA => [
                        LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 1_000, 10_000),
                        HigherThan10 => [
                            ContainerGroupE => [
                                Unstable => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 10_000),
                                Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 30_000),
                                Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 50_000)
                            ],
                            ContainerGroupF => [
                                Unstable => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 15_000),
                                Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 30_000),
                                Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 50_000)
                            ]
                        ]
                    ],
                    ReleaseTypeB => [
                        ContainerGroupB => [
                            LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 1_000, 10_000),
                            HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 10_000)
                        ],
                        ContainerGroupC => [
                            LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 2_000, 10_000),
                            HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 2_000, 10_000)
                        ],
                        ContainerGroupD => [
                            LowerThan10 => Leaf(ReleaseLocations{2}, :_two_circles, 1_000, 10_000),
                            HigherThan10 => Leaf(ReleaseLocations{2}, :_two_circle_triangle, 1_000, 10_000)
                        ]
                    ],
                    ReleaseTypeC => Leaf(ReleaseLocations{1}, :_circle, 10_000),
                    ReleaseBloodAgent => Leaf(ReleaseLocations{1}, :_circle, 1_000)
                ]
            ],
            ChemicalSubstance => [
                Simplified => [
                    LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 1_000, 3_000),
                    HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 3_000)
                ],
                Detailed => [
                    ReleaseTypeD => [
                        SubType1 => [
                            ReleaseSmall => [
                                Sarin => [
                                    LowerThan10 => [
                                        Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                        Neutral => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 1_100),
                                        Stable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 1_100)
                                    ],
                                    HigherThan10 => [
                                        Unstable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 400),
                                        Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                        Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                    ]
                                ]
                            ],
                            ReleaseMedium => [
                                LowerThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ],
                                HigherThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ]
                            ],
                            ReleaseLarge => [
                                LowerThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ],
                                HigherThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ]
                            ],
                            ReleaseExtraLarge => [
                                LowerThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ],
                                HigherThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ]
                            ]
                        ],
                        SubType2 => [
                            ReleaseSmall => [
                                LowerThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ],
                                HigherThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ]
                            ],
                            ReleaseMedium => [
                                LowerThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ],
                                HigherThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ]
                            ],
                            ReleaseLarge => [
                                LowerThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ],
                                HigherThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ]
                            ],
                            ReleaseExtraLarge => [
                                LowerThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ],
                                HigherThan10 => [
                                    Unstable => Leaf(ReleaseLocations{1}, :_circle_circle, 60, 400),
                                    Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100),
                                    Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 60, 1_100)
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ],
        BiologicalAgent => [
            Simplified => [
                LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 2_000, 10_000),
                HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 2_000, 10_000)
            ],
            Detailed => [
                ReleaseTypeP => [
                    LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 2_000, 20_000),
                    HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 2_000, 2*wind_speed(wind)*3.6*1000)
                ],
                ReleaseTypeQ => [
                    LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 10_000, 20_000),
                    HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 10_000, 2*wind_speed(wind)*3.6*1000)
                ],
                ReleaseTypeR => [
                    LowerThan10 => Leaf(ReleaseLocations{2}, :_two_circles, 2_000, 20_000),
                    HigherThan10 => Leaf(ReleaseLocations{2}, :_two_circle_triangle, 2_000, 2*wind_speed(wind)*3.6*1000)
                ],
                ReleaseTypeS => Leaf(ReleaseLocations{1}, :_circle, 10_000)
            ]
        ],
    ]
    return DECISION_TREE
end

mutable struct TreeNode{T} <: AT.AbstractNode{T}
    value::T
    parent::Union{Nothing, TreeNode}
    children::Vector{TreeNode}
    TreeNode(value::T, parent, children=TreeNode[]) where T = new{T}(value, parent, children)
end
AbstractTrees.ParentLinks(::Type{<:TreeNode}) = StoredParents()

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

build_tree(wind::AbstractWind) = TreeNode(decision_tree_full(wind))

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
    descendall(node::TreeNode, model_params) :: TreeNode{<:Tuple}
Browse the tree starting at `node`, choosing the path following what is specified in `model_params`.

# Examples
```julia-repl
julia> ex = Simplified => [
               ChemicalAgent => [
                   LowerThan10 => (:_circle_circle, 2_000, 10_000),
                   HigherThan10 => (:_circle_triangle, 2_000, 10_000),
               ],
               BiologicalAgent => [
                   LowerThan10 => (:_circle_circle, 1_000, 10_000),
                   HigherThan10 => (:_circle_triangle, 1_000, 10_000),
               ],
           ]
julia> model_params = (BiologicalAgent(), WindAzimuth(45, 2))
julia> descendall(TreeNode(ex), model_params)
(:_circle_triangle, 1000, 10000)
```
"""
function descendall(node::TreeNode, model_params) :: TreeNode{<:Leaf}
    next = descend(node, model_params)

    while true
        next isa TreeNode{<:Leaf} && return next
        next = descend(next, model_params)
    end
end

"""
    descend(node::TreeNode, model_params) :: TreeNode
Discriminate between the children of `node` according to the parameters in `model_params`.

# Examples
```julia-repl
julia> ex = Simplified => [
               ChemicalAgent => [
                   LowerThan10 => (:_circle_circle, 2_000, 10_000),
                   HigherThan10 => (:_circle_triangle, 2_000, 10_000),
               ],
               BiologicalAgent => [
                   LowerThan10 => (:_circle_circle, 1_000, 10_000),
                   HigherThan10 => (:_circle_triangle, 1_000, 10_000),
               ],
           ]
julia> model_params = (BiologicalAgent(),)
julia> descend(TreeNode(ex), model_params)
BiologicalAgent()
├─ LowerThan10()
│  └─ (:_circle_circle, 1000, 10000)
└─ HigherThan10()
   └─ (:_circle_triangle, 1000, 10000)
```
"""
function descend(node::TreeNode, model_params) :: TreeNode
    node_children = children(node)
    vals = nodevalue.(node_children)
    children_type = eltype(vals)
    ichild = _find_node(children_type, vals, model_params)
    ichild = isnothing(ichild) ? 1 : ichild
    node_children[ichild]
end

# function _find_node(::Type{<:AbstractModel}, vals, model_params)
#     param = _getisa(model_params, AbstractModel)
#     # Quite ugly, should find a better solution
#     inode = findisa(vals, _nonparamtype(param))
#     inode
# end

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
    # First tries to find the ContainerGroup, then tries with the ContainerType
    inode = try 
        param = _getisa(model_params, AbstractContainerGroup)
        findfirst(x -> x == param, vals)
    catch e
        if e isa MissingInputsException
            nothing
        else
            rethrow()
        end
    end

    inode = if isnothing(inode)
        param = _getisa(model_params, AbstractContainerType)
        findfirst(x -> param in x, vals)
    else
        inode
    end

    inode
end

function _find_node(::Type{<:Leaf{N}}, vals, model_params) where N 
    input_loc = try 
        get_location(model_params)
    catch e
        e isa ErrorException && throw(MissingInputsException([ReleaseLocations{N}]))
    end
    input_loc isa ReleaseLocations{N} || error("Wrong number of input release locations: required: $N.")
    nothing
end

_find_node(::Type{<:Tuple}, vals, model_params) = error("This case has not been implemented yet.")

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
