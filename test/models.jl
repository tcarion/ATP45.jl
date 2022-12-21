using Test
using ATP45
import ATP45: Simplified, Detailed
import ATP45: ChemicalWeapon
import ATP45: ReleaseTypeA
import ATP45: WindDirection, ReleaseLocation
import ATP45: MissingInputsException
import ATP45: Atp45Result

@testset "Models" begin
    weapon = ChemicalWeapon()
    simple = Simplified(weapon)
    wind = WindDirection(11., 45)
    release = ReleaseLocation([4., 50.])
    @test_throws MissingInputsException simple()
    result = simple(wind, release)
    @test result isa Atp45Result

    typeA = ReleaseTypeA()
    detailed = Detailed(weapon, typeA)
    detailed2 = Detailed(typeA, weapon)
    @test detailed == detailed2
end