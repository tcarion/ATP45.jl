
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
        ChemicalWeapon => (:_circle_circle, 2_000, 10_000),
        BiologicalWeapon => (:_circle_circle, 2_000, 10_000),
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
        ],
        BiologicalWeapon => (:_circle_circle, 2_000, 10_000),
    ],
]

struct TreeNode
    value
    parent
    children::Vector{TreeNode}
    sequence::Vector{Any}
    TreeNode(value, parent, children=TreeNode[]) = new(value, parent, children)
end
AbstractTrees.ParentLinks(::Type{<:TreeNode}) = StoredParents()

# TreeNode(dict::AbstractDict) = TreeNode("root", nothing, [TreeNode(pair, "root") for pair in collect(dict)])
TreeNode(vec::AbstractVector) = TreeNode("root", nothing, [TreeNode(pair, "root") for pair in vec])
function TreeNode(pair::Pair, parent = nothing)
    k, v = pair
    value = k()

    if v isa AbstractVector
        children = map(collect(v)) do child_pair
            TreeNode(child_pair, value)
        end
        TreeNode(value, parent, children)
    else
        TreeNode(k(), parent, [TreeNode(v, k())])
    end
end
# function TreeNode(pair::Pair{T, <:Tuple}) where {T <: Union{UnionAll, DataType, <:Tuple}}
# function TreeNode(pair::Pair, parent)
#     k, v = pair
#     TreeNode(k(), parent, [TreeNode(v, k())])
# end


# TreeNode(model::Type{Simplified}) = TreeNode(model, nothing, [
#     TreeNode(ChemicalWeapon, model),
#     TreeNode(BiologicalWeapon, model),
#     TreeNode(RadiologicalWeapon, model),
#     TreeNode(NuclearWeapon, model),
# ])

# TreeNode(weapon::Type{T}, parent::Type{Simplified}) where {T <: AbstractWeapon }= TreeNode(weapon, parent, [
#     TreeNode(AbstractWind, weapon),
#     TreeNode(AbstractReleaseLocation, weapon),
# ])
# TreeNode(model::Simplified{<:Tuple{ChemicalWeapon}})

# children(node::TreeNode) = [ChemicalWeapon, BiologicalWeapon, RadiologicalWeapon, NuclearWeapon]

children(node::TreeNode) = node.children
parent(node::TreeNode) = node.parent
nodevalue(node::TreeNode) = node.value
