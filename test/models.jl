using Test
using ATP45
import ATP45: Simplified
import ATP45: ChemicalWeapon
import ATP45: WindDirection, ReleaseLocation
import ATP45: MissingInputsException

@testset "Models" begin
    simple = Simplified()
    weapon = ChemicalWeapon()
    wind = WindDirection(11., 45)
    release = ReleaseLocation([4., 50.])
    @test_throws MissingInputsException simple()
    simple(weapon, wind, release)
end