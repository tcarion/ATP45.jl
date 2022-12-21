using Test
using ATP45
import ATP45: AbstractWeapon, ChemicalWeapon
import ATP45: AbstractCategory, AbstractReleaseType, ReleaseTypeA, ReleaseTypeB, ReleaseTypeC
import ATP45: AbstractWindCategory, LowerThan10, HigherThan10
import ATP45: AbstractContainerGroup, ContainerGroupA,ContainerGroupB
import ATP45: id, description, content, note
import ATP45: nextchoice, categories_order, sort_categories

@testset "Release categories" begin
    typeA = ReleaseTypeA()
    ATP45.id(typeA) == "typeA"

    lower = LowerThan10()
    higher = HigherThan10()
    nextchoice(typeA, lower, higher)
    nextchoice(typeA)
end

@testset "Containers categories" begin
    groupA = ContainerGroupA()
    @test id(groupA) == "groupeA"
    @test description(ContainerGroupB()) == "Bomblet, Shell" 

end

@testset "Sort Categories" begin
    order = categories_order()
    unordered = (ContainerGroupB(), ReleaseTypeA(), ChemicalWeapon())
    ordered = sort_categories(unordered)
    @test ordered isa Tuple{<:AbstractWeapon, <:AbstractReleaseType, <:AbstractContainerGroup}
    unordered2 = (ContainerGroupB(), ChemicalWeapon())
    ordered2 = sort_categories(unordered2)
    @test ordered2 isa Tuple{<:AbstractWeapon, <:AbstractContainerGroup}
end