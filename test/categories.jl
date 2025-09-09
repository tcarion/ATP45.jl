using Test
using ATP45
import ATP45: AbstractWeapon, ChemicalWeapon, BiologicalAgent
import ATP45: AbstractCategory, AbstractReleaseType, ReleaseTypeA, ReleaseTypeB, ReleaseTypeC
import ATP45: AbstractWindCategory, LowerThan10, HigherThan10
import ATP45: ContainerGroupA,ContainerGroupB
import ATP45: AbstractContainerType, Shell, Bomb
import ATP45: id, description, note
import ATP45: nextchoice, categories_order, sort_categories

@testset "Release categories" begin
    typeA = ReleaseTypeA()
    ATP45.id(typeA) == "typeA"

    lower = LowerThan10()
    higher = HigherThan10()
    @test nextchoice(ChemicalWeapon(), typeA, lower) |> isnothing
    @test nextchoice(ChemicalWeapon(), typeA) == [lower, higher]
end

@testset "Containers types" begin
    shell = Shell()
    @test shell isa ContainerGroupA
    typeB = ReleaseTypeB()
    @test nextchoice(ChemicalWeapon(), typeB) isa Vector{<:Vector{<:DataType}}
    @test nextchoice(ChemicalWeapon(), typeB, shell) == [lower, higher]
end

@testset "Sort Categories" begin
    order = categories_order()
    unordered = (Shell(), ReleaseTypeA(), ChemicalWeapon())
    ordered = sort_categories(unordered)
    @test ordered isa Tuple{<:AbstractWeapon, <:AbstractReleaseType, <:AbstractContainerType}
    unordered2 = (Shell(), ChemicalWeapon())
    ordered2 = sort_categories(unordered2)
    @test ordered2 isa Tuple{<:AbstractWeapon, <:AbstractContainerType}
end