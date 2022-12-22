using Test
using ATP45
import ATP45: Simplified
import ATP45: AbstractWind, WindDirection, ReleaseLocation, AbstractReleaseLocation
import ATP45: AbstractStability, Unstable, Stable
import ATP45: required_inputs, missing_inputs, get_input

@testset "Inputs" begin
    required = required_inputs(Simplified())

    simple = Simplified()
    wind = WindDirection(11., 45)
    release = ReleaseLocation([4., 50.])
    stable = Stable()
    @test missing_inputs(simple, wind) == [AbstractReleaseLocation{1, <:Number}]
    @test missing_inputs(simple, wind, release) == []

    inputs = (wind, release, stable)
    @test get_input(inputs, AbstractWind) == wind
    @test get_input(inputs, AbstractReleaseLocation) == release
    @test get_input(inputs, AbstractStability) == stable
    @test_throws ErrorException get_input([wind], AbstractReleaseLocation)
end
