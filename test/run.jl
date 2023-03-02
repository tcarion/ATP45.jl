using Test
using ATP45
import ATP45: ATP45_TREE
import ATP45: cast_id
import ATP45: Simplified, Detailed
import ATP45: _circle, _circle_circle, _circle_triangle, _two_circles, _two_circle_triangle
import ATP45: ChemicalWeapon, BiologicalWeapon, RadiologicalWeapon, NuclearWeapon
import ATP45: ReleaseTypeA, ReleaseTypeB, ReleaseTypeC
import ATP45: Shell
import ATP45: WindAzimuth, ReleaseLocations
import ATP45: Unstable, Stable
import ATP45: Atp45Result
import ATP45: HazardZone, ReleaseZone
import ATP45: MissingInputsException

@testset "zones generator methods" begin
    one_release = ReleaseLocations([4., 50.])
    wind = WindAzimuth(5., 130.)
    circ = _circle(one_release, 1_000)
    @test circ[1] isa ReleaseZone

    circcirc = _circle_circle(one_release, 1_000, 10_000)
    @test circcirc[1] isa ReleaseZone
    @test circcirc[2] isa HazardZone

    circtri = _circle_triangle(one_release, wind, 1_000, 10_000)
    @test circtri[1] isa ReleaseZone
    @test circtri[2] isa HazardZone

    two_releases = ReleaseLocations([4., 50.], [4.15, 50.03])
    twocirc = _two_circles(two_releases, 1_000, 10_000)
    @test twocirc[1] isa ReleaseZone
    @test twocirc[2] isa HazardZone

    twotri = _two_circle_triangle(two_releases, wind, 1_000, 10_000)
    @test twocirc[1] isa ReleaseZone
    @test twocirc[2] isa HazardZone
end

@testset "Run" begin
    model_parameters = (Simplified(), BiologicalWeapon(), WindAzimuth(45, 4), ReleaseLocations([4., 50.]))
    result = run_atp(model_parameters)
    @test result isa Atp45Result
    model_parameters_str = ("simplified", "bio", WindAzimuth(45, 4), ReleaseLocations([4., 50.]))
    @test cast_id.(model_parameters_str) == model_parameters
    res2 = run_atp(model_parameters_str)
    @test res2 isa Atp45Result
    res3 = run_atp("simplified", "chem", WindAzimuth(2, 5), ReleaseLocations([4, 50]))
    @test res3 isa Atp45Result
end

@testset "Models run" begin
    windhigher = WindAzimuth(5., 45)
    windlower = WindAzimuth(2., 45)
    unstable = Unstable()
    stable = Stable()
    release = ReleaseLocations([4., 50.])
    two_releases = ReleaseLocations([4., 50.], [4.15, 50.03])
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
                @test r.zones[2] isa HazardZone
                inputs = (windhigher, release, "unstable")
                r = typeAhigher(inputs...)
                @test r.zones[2] isa HazardZone
            end

            @testset "Release B" begin
                @test_throws MissingInputsException Detailed(chemical, ReleaseTypeB())(windlower, release)
                typeBcontB = Detailed(chemical, ReleaseTypeB(), Shell())
                @test typeBcontB(windhigher, release).zones[2] isa HazardZone

                @testset "with ContainerGroup" begin
                    withgroup = Detailed("chem", "typeB", "containergroupb")
                    @test withgroup(windhigher, release).zones[2] isa HazardZone
                end

                @testset "two releases case" begin
                    tworel_res = run_atp("detailed", "chem", "typeB", "SPR", windlower, two_releases)
                    @test tworel_res.zones[2] isa HazardZone 
                    @test_throws ErrorException run_atp("detailed", "chem", "typeB", "SPR", windlower, release)
                end
            end

            @testset "Release C" begin
                typeC = Detailed(chemical, ReleaseTypeC())
                @test typeC(windlower, release).zones[1] isa ReleaseZone
            end
        end

    end
    @testset "Results" begin
        result = run_atp("detailed", "chem", "typeA", Shell(), release, windhigher, stable)
        @test result[:locations] == release
        @test result[:categories] == (ChemicalWeapon(), ReleaseTypeA(), Shell())
        @test result[:weather] == (windhigher, stable)
    end
end