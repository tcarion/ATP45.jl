using Test
using ATP45
import ATP45: Simplified, Detailed
import ATP45: ChemicalWeapon, BiologicalWeapon, RadiologicalWeapon, NuclearWeapon
import ATP45: ReleaseTypeA, ReleaseTypeB, ReleaseTypeC
import ATP45: Shell
import ATP45: WindDirection, ReleaseLocation
import ATP45: Unstable, Stable
import ATP45: MissingInputsException
import ATP45: Atp45Result
import ATP45: CircleLike, TriangleLike

@testset "Models" begin
    windhigher = WindDirection(5., 45)
    windlower = WindDirection(2., 45)
    unstable = Unstable()
    stable = Stable()
    release = ReleaseLocation([4., 50.])
    chemical = ChemicalWeapon()

    @testset "Simplified" begin
        simple = Simplified(chemical)
        @test_throws MissingInputsException simple()
        result = simple(windhigher, release)
        @test result isa Atp45Result
    
        biosimple = Simplified(BiologicalWeapon())
        bioresult = biosimple(windhigher, release)
    end

    @testset "Detailed" begin
        detailed = Detailed(chemical, ReleaseTypeC())
        detailed2 = Detailed(ReleaseTypeC(), chemical)
        @test detailed == detailed2

        @testset "Chemical" begin
            chemical = ChemicalWeapon()
            @testset "Release A" begin
                typeA = Detailed(chemical, ReleaseTypeA())
                typeA(windlower, release)
                @test_throws MethodError typeA(windhigher, release)
                typeAhigher = Detailed(chemical, ReleaseTypeA(), Shell())
                @test_throws MissingInputsException typeAhigher(windhigher, release)
                r = typeAhigher(windhigher, release, unstable)
                @test r.zones[2] isa TriangleLike
            end

            @testset "Release B" begin
                @test_throws MethodError Detailed(chemical, ReleaseTypeB())(windlower, release)
                typeBcontB = Detailed(chemical, ReleaseTypeB(), Shell())
                @test typeBcontB(windhigher, release).zones[2] isa TriangleLike
            end

            @testset "Release C" begin
                typeC = Detailed(chemical, ReleaseTypeC())
                @test typeC(windlower, release).zones[1] isa CircleLike
            end
        end
    end
end