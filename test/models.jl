using Test
using ATP45
import ATP45: Simplified, Detailed
import ATP45: ChemicalWeapon, BiologicalWeapon, RadiologicalWeapon, NuclearWeapon
import ATP45: ReleaseTypeA, ReleaseTypeB, ReleaseTypeC
import ATP45: Shell
import ATP45: WindDirection, ReleaseLocation
import ATP45: MissingInputsException
import ATP45: Atp45Result
import ATP45: CircleLike, TriangleLike

@testset "Models" begin
    chemical = ChemicalWeapon()
    simple = Simplified(chemical)
    windhigher = WindDirection(5., 45)
    windlower = WindDirection(2., 45)
    release = ReleaseLocation([4., 50.])
    @test_throws MissingInputsException simple()
    result = simple(windhigher, release)
    @test result isa Atp45Result

    biosimple = Simplified(BiologicalWeapon())
    bioresult = biosimple(windhigher, release)
    
    typeA = ReleaseTypeA()
    detailed = Detailed(chemical, typeA)
    detailed2 = Detailed(typeA, chemical)
    @test detailed == detailed2

    @test detailed(windlower, release).zones[2] isa CircleLike
    @test_throws MethodError Detailed(chemical, ReleaseTypeB())(windlower, release)
    typeBcontB = Detailed(chemical, ReleaseTypeB(), Shell())
    @test typeBcontB(windhigher, release).zones[2] isa TriangleLike

    # @test typeC = Detailed(chemical, ReleaseTypeC())
end