using Test
using ATP45
import ATP45: ATP45_TREE
import ATP45: cast_id
import ATP45: Simplified, Detailed
import ATP45: ChemicalWeapon, BiologicalWeapon, RadiologicalWeapon, NuclearWeapon
import ATP45: ReleaseTypeA, ReleaseTypeB, ReleaseTypeC
import ATP45: Shell
import ATP45: WindDirection, ReleaseLocation
import ATP45: Unstable, Stable
import ATP45: Atp45Result
import ATP45: CircleLike, TriangleLike
import ATP45: MissingInputsException

@testset "Run" begin
    model_parameters = (Simplified(), BiologicalWeapon(), WindDirection(45, 4), ReleaseLocation([4., 50.]))
    result = ATP45.run_atp(model_parameters)
    @test result isa Atp45Result
    model_parameters_str = ("simplified", "bio", WindDirection(45, 4), ReleaseLocation([4., 50.]))
    @test cast_id.(model_parameters_str) == model_parameters
    res2 = ATP45.run_atp(model_parameters_str)
    @test res2 isa Atp45Result
    res3 = ATP45.run_atp("simplified", "chem", WindDirection(2, 5), ReleaseLocation([4, 50]))
    @test res3 isa Atp45Result
end

@testset "Models run" begin
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
        withid = Detailed("chem", "typeC")
        @test detailed == detailed2 == withid

        @testset "Chemical" begin
            chemical = ChemicalWeapon()
            @testset "Release A" begin
                typeA = Detailed(chemical, ReleaseTypeA())
                @test_throws MissingInputsException typeA(windhigher, release)
                typeAhigher = Detailed(chemical, ReleaseTypeA(), Shell())
                @test_throws MissingInputsException typeAhigher(windhigher, release)
                inputs = (windhigher, release, unstable)
                r = typeAhigher(inputs...)
                @test r.zones[2] isa TriangleLike
                inputs = (windhigher, release, "unstable")
                r = typeAhigher(inputs...)
                @test r.zones[2] isa TriangleLike
            end

            @testset "Release B" begin
                @test_throws MissingInputsException Detailed(chemical, ReleaseTypeB())(windlower, release)
                typeBcontB = Detailed(chemical, ReleaseTypeB(), Shell())
                @test typeBcontB(windhigher, release).zones[2] isa TriangleLike

                @testset "with ContainerGroup" begin
                    withgroup = Detailed("chem", "typeB", "containergroupb")
                    @test withgroup(windhigher, release).zones[2] isa TriangleLike
                end
            end

            @testset "Release C" begin
                typeC = Detailed(chemical, ReleaseTypeC())
                @test typeC(windlower, release).zones[1] isa CircleLike
            end
        end
    end
end