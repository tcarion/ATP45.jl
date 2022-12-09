using Test
using ATP45
import ATP45: Simplified
import ATP45: AbstractWind, WindDirection, ReleaseLocation, AbstractReleaseLocation
import ATP45: Abstracteapon, ChemicalWeapon
import ATP45: required_inputs, missing_inputs

@testset "Inputs" begin
    required = required_inputs(Simplified())

    simple = Simplified()
    weapon = ChemicalWeapon()
    wind = WindDirection(11., 45)
    release = ReleaseLocation([4., 50.])
    @test missing_inputs(simple, weapon, wind) == [AbstractReleaseLocation{1, <:Number}]
    @test missing_inputs(simple, weapon, wind, release) == []

end
