using Test
using ATP45: TreeNode
import ATP45: children, parent, nodevalue
import ATP45: DECISION_TREE
import ATP45: Simplified
import ATP45.AbstractTrees: Leaves

@testset "Tree creation" begin
    tree = TreeNode(DECISION_TREE)
    leaves = collect(Leaves(tree))
    @test length(leaves) == 10
end
