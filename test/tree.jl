using Test
using ATP45
using ATP45: _group_parameters
using ATP45: TreeNode, Leaf
import ATP45: children, parent, nodevalue
import ATP45: build_tree, allparents, children_value_type, descend, descendall, _find_node
import ATP45: Simplified, Detailed, ChemicalWeapon, BiologicalWeapon, Shell, Bomb, ReleaseTypeA, WindDirection, ReleaseLocation, LowerThan10, HigherThan10
import ATP45: Stable, Unstable, Neutral
import ATP45: ContainerGroupE, ContainerGroupF, ContainerGroupB, ContainerGroupC
import ATP45.AbstractTrees: Leaves, getroot
import ATP45: MissingInputsException

example_tree = [
    Simplified => [
        ChemicalWeapon => [
            LowerThan10 => Leaf(ReleaseLocation{1}, :_circle_circle, 2_000, 10_000),
            HigherThan10 => Leaf(ReleaseLocation{1}, :_circle_triangle, 2_000, 10_000),
        ],
        BiologicalWeapon => [
            LowerThan10 => Leaf(ReleaseLocation{1}, :_circle_circle, 2_000, 10_000),
            HigherThan10 => Leaf(ReleaseLocation{1}, :_circle_triangle, 2_000, 10_000),
        ],
    ],
    Detailed => [
        ChemicalWeapon => [
            ReleaseTypeA => [
                LowerThan10 => Leaf(ReleaseLocation{1}, :_circle_circle, 1_000, 10_000),
                HigherThan10 => [
                    ContainerGroupE => [
                        Unstable => Leaf(ReleaseLocation{1}, :_circle_triangle, 1_000, 10_000),
                        Neutral => Leaf(ReleaseLocation{1}, :_circle_triangle, 1_000, 30_000),
                        Stable => Leaf(ReleaseLocation{1}, :_circle_triangle, 1_000, 50_000),
                    ],
                    ContainerGroupF => [
                        Unstable => Leaf(ReleaseLocation{1}, :_circle_triangle, 1_000, 15_000),
                        Neutral => Leaf(ReleaseLocation{1}, :_circle_triangle, 1_000, 30_000),
                        Stable => Leaf(ReleaseLocation{1}, :_circle_triangle, 1_000, 50_000),
                    ],
                ],
            ],
            ReleaseTypeB => [
                ContainerGroupB => [
                    LowerThan10 => Leaf(ReleaseLocation{1}, :_circle_circle, 1_000, 10_000),
                    HigherThan10 => Leaf(ReleaseLocation{1}, :_circle_triangle, 1_000, 10_000),
                ],
                ContainerGroupC => [
                    LowerThan10 => Leaf(ReleaseLocation{1}, :_circle_circle, 2_000, 10_000),
                    HigherThan10 => Leaf(ReleaseLocation{1}, :_circle_triangle, 2_000, 10_000),
                ],
            ],
            ReleaseTypeC => Leaf(ReleaseLocation{2}, :_circle, 10_000),
        ],
        BiologicalWeapon => (nothing,),
    ],
]

@testset "Tree creation" begin
    tree = TreeNode(example_tree)
    leaves = collect(Leaves(tree))
    @test length(leaves) == 17
    @test nodevalue(getroot(leaves[1])) == "root"
end

@testset "Tree methods" begin
    tree = TreeNode(example_tree)
    leaves = collect(Leaves(tree))
    leave = leaves[7]
    parents = allparents(leave)
    @test length(parents) == 7

    @testset "Descending " begin
        windhigher = WindDirection(5., 45)
        windlower = WindDirection(2., 45)
        release = ReleaseLocation([4., 50.])
        inputs = (windhigher, release)
        inputs_stab = (inputs..., Stable())

        @testset "Not implemented" begin
            model = Detailed(BiologicalWeapon())
            @test_throws ErrorException descendall(tree, _group_parameters(model, inputs))
        end

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
            @test next isa TreeNode{<:Leaf}
        end

        @testset "Detailed" begin
            conttype = Bomb()
            model = Detailed(ChemicalWeapon(), ReleaseTypeA(), conttype)
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

            # missing ReleaseLocation
            model_params_norel = _group_parameters(model, (windhigher,))
            @test_throws MissingInputsException descendall(tree, model_params_norel)

            # missing stability
            model_params_wrong = _group_parameters(model, inputs)
            @test_throws MissingInputsException descendall(tree, model_params_wrong)

            # missing container type
            model_params_wrong = _group_parameters(Detailed(ChemicalWeapon(), ReleaseTypeA()), inputs)
            @test_throws MissingInputsException descendall(tree, model_params_wrong)

            # wrong number of releases
            model_params_wrong = _group_parameters(Detailed(ChemicalWeapon(), ReleaseTypeC()), inputs)
            @test_throws ErrorException descendall(tree, model_params_wrong)

            @testset "Discriminate between groups" begin
                model_params_e = (Detailed(), ChemicalWeapon(), ReleaseTypeA(), ContainerGroupE(), inputs..., Unstable())
                final_node = descendall(tree, model_params_e)
                @test nodevalue(final_node).args == (1000, 10000)
                model_params_f = (Detailed(), ChemicalWeapon(), ReleaseTypeA(), ContainerGroupF(), inputs..., Unstable())
                final_node = descendall(tree, model_params_f)
                @test nodevalue(final_node).args == (1000, 15000)
            end
        end
    end
end
