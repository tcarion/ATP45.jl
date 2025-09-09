using Test
using ATP45
using ATP45: TreeNode, Leaf
import ATP45: children, parent, nodevalue
import ATP45: build_tree, allparents, children_value_type, descend, descendall, _find_node
import ATP45: Simplified, Detailed, ChemicalWeapon, BiologicalAgent, Shell, Bomb, ReleaseTypeA, WindAzimuth, ReleaseLocations, LowerThan10, HigherThan10
import ATP45: Stable, Unstable, Neutral
import ATP45: ContainerGroupE, ContainerGroupF, ContainerGroupB, ContainerGroupC
import ATP45.AbstractTrees: Leaves, getroot
import ATP45: MissingInputsException

example_tree = [
    Simplified => [
        ChemicalWeapon => [
            LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 2_000, 10_000),
            HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 2_000, 10_000),
        ],
        BiologicalAgent => [
            LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 2_000, 10_000),
            HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 2_000, 10_000),
        ],
    ],
    Detailed => [
        ChemicalWeapon => [
            ReleaseTypeA => [
                LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 1_000, 10_000),
                HigherThan10 => [
                    ContainerGroupE => [
                        Unstable => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 10_000),
                        Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 30_000),
                        Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 50_000),
                    ],
                    ContainerGroupF => [
                        Unstable => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 15_000),
                        Neutral => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 30_000),
                        Stable => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 50_000),
                    ],
                ],
            ],
            ReleaseTypeB => [
                ContainerGroupB => [
                    LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 1_000, 10_000),
                    HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 1_000, 10_000),
                ],
                ContainerGroupC => [
                    LowerThan10 => Leaf(ReleaseLocations{1}, :_circle_circle, 2_000, 10_000),
                    HigherThan10 => Leaf(ReleaseLocations{1}, :_circle_triangle, 2_000, 10_000),
                ],
            ],
            ReleaseTypeC => Leaf(ReleaseLocations{2}, :_circle, 10_000),
        ],
        BiologicalAgent => (nothing,),
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
        windhigher = WindAzimuth(5., 45)
        windlower = WindAzimuth(2., 45)
        release = ReleaseLocations([4., 50.])
        inputs = (windhigher, release)
        inputs_stab = (inputs..., Stable())

        @testset "Not implemented" begin
            categories = (BiologicalAgent(), Detailed())
            @test_throws ErrorException descendall(tree, (categories..., inputs...))
        end

        @testset "Simplified" begin
            model = (BiologicalAgent(), Simplified())
            model_params = (model..., inputs...)
            next = descend(tree, model_params)
            @test next isa TreeNode{<:Simplified}
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:BiologicalAgent}
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:HigherThan10}
            node = next
            next = descend(node, model_params)
            @test next isa TreeNode{<:Leaf}
        end

        @testset "Detailed" begin
            conttype = Bomb()
            categories = (ChemicalWeapon(), ReleaseTypeA(), Detailed(),conttype)
            model_params = (categories..., inputs_stab...)
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

            # missing ReleaseLocations
            model_params_norel = (categories..., windhigher)
            @test_throws MissingInputsException descendall(tree, model_params_norel)

            # missing stability
            model_params_wrong = (categories..., inputs)
            @test_throws MissingInputsException descendall(tree, model_params_wrong)

            # missing container type
            model_params_wrong = (Detailed(), ChemicalWeapon(), ReleaseTypeA(), inputs...)
            @test_throws MissingInputsException descendall(tree, model_params_wrong)

            # wrong number of releases
            model_params_wrong = (Detailed(), ChemicalWeapon(), ReleaseTypeC(), inputs...)
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
