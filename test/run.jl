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

    @testset "Chemical" begin
        chemical = ChemicalWeapon()

        @testset "Simplified" begin
            simple_params = (Simplified(), chemical) 
            @test_throws MissingInputsException run_atp(simple_params)
            result = run_atp(simple_params..., windhigher, release)
            @test result isa Atp45Result
        end

        @testset "Detailed" begin 
            @testset "Release A" begin
                typeAwrong = (chemical, Detailed(), ReleaseTypeA())
                @test_throws MissingInputsException run_atp(typeAwrong...,windhigher, release)
                typeA = (chemical, Detailed(), ReleaseTypeA(), Shell())
                @test_throws MissingInputsException run_atp(typeA..., windhigher, release)
                inputs = (windhigher, release, unstable)
                r = run_atp(typeA..., inputs...)
                @test r.zones[2] isa HazardZone
                inputs = (windhigher, release, "unstable")
                r = run_atp(typeA..., inputs...)
                @test r.zones[2] isa HazardZone
            end
    
            @testset "Release B" begin
                @test_throws MissingInputsException run_atp(chemical, Detailed(), ReleaseTypeB(), windlower, release)
                typeBcontB = (chemical, Detailed(), ReleaseTypeB(), Shell())
                @test run_atp(typeBcontB..., windhigher, release).zones[2] isa HazardZone
    
                @testset "with ContainerGroup" begin
                    withgroup = ("chem", "detailed", "typeB", "containergroupb")
                    @test run_atp(withgroup..., windhigher, release).zones[2] isa HazardZone
                end
    
                @testset "two releases case" begin
                    tworel_res = run_atp("detailed", "chem", "typeB", "SPR", windlower, two_releases)
                    @test tworel_res.zones[2] isa HazardZone 
                    @test_throws ErrorException run_atp("detailed", "chem", "typeB", "SPR", windlower, release)
                end
            end
    
            @testset "Release C" begin
                typeC = (chemical, Detailed(), ReleaseTypeC())
                @test run_atp(typeC..., windlower, release).zones[1] isa ReleaseZone
            end
        end
        
    end

    @testset "Biological" begin
        biological = BiologicalWeapon()
        @testset "Simplified" begin
            biosimple = (Simplified(), biological)
            bioresult = run_atp(biosimple..., windhigher, release)
            @test bioresult isa Atp45Result
        end
    end
end

@testset "Atp45Result" begin
    release = ReleaseLocations([4., 50.])
    wind = WindAzimuth(5., 45)

    categories = ("detailed", "chem", "typeA", Shell())
    result = run_atp(categories..., release, wind, Stable())
    @test result[:locations] == release
    @test result[:categories] == (ChemicalWeapon(), ReleaseTypeA(), Shell(), Detailed())
    @test result[:weather] == (wind, Stable())

    release_zones = get_zones(result, "release")
    @test release_zones[1] isa ATP45.ReleaseZone
end