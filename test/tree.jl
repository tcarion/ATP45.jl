using Test
using ATP45
using ATP45: _group_parameters
using ATP45: TreeNode
import ATP45: children, parent, nodevalue
import ATP45: DECISION_TREE, build_tree, allparents, children_value_type, descend, descendall, _find_node
import ATP45: Simplified, Detailed, ChemicalWeapon, BiologicalWeapon, Shell, Bomb, ReleaseTypeA, WindDirection, ReleaseLocation, HigherThan10, Stable
import ATP45.AbstractTrees: Leaves, getroot
import ATP45: MissingInputsException

@testset "Tree creation" begin
    tree = TreeNode(DECISION_TREE)
    leaves = collect(Leaves(tree))
    @test length(leaves) == 10
    @test nodevalue(getroot(leaves[1])) == "root"
end

@testset "Tree methods" begin
    tree = build_tree()
    leaves = collect(Leaves(tree))
    leave = leaves[7]
    parents = allparents(leave)
    @test length(parents) == 7

    @testset "Descending " begin
        windhigher = WindDirection(5., 45)
        windlower = WindDirection(2., 45)
        release = ReleaseLocation([4., 50.])
        inputs = (windhigher, release)

        @testset "Simplified" begin
            model = Simplified(BiologicalWeapon())
            model_params = _group_parameters(model, inputs)
            next = descend(tree, model_params)
            @test next isa TreeNode{<:Simplified}
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:BiologicalWeapon}
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:HigherThan10}
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:Tuple}
        end

        @testset "Detailed" begin
            conttype = Bomb()
            model = Detailed(ChemicalWeapon(), ReleaseTypeA(), conttype)
            inputs_stab = (inputs..., Stable())
            model_params = _group_parameters(model, inputs_stab)
            next = descend(tree, model_params)
            @test next isa TreeNode{<:Detailed}
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:ChemicalWeapon}
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:ReleaseTypeA}
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:HigherThan10}
            node = next
            next = descend(node, model_params)
            @test conttype in nodevalue(next)
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:Stable}
            node = next
            next = descend(node, model_params)
            @test nodevalue(descendall(tree, model_params)) == nodevalue(next)


            model_params_wrong = _group_parameters(model, inputs)
            @test_throws MissingInputsException descendall(tree, model_params_wrong)
            model_params_wrong = _group_parameters(Detailed(ChemicalWeapon(), ReleaseTypeA()), inputs)
            @test_throws MissingInputsException descendall(tree, model_params_wrong)
        end
    end
end
