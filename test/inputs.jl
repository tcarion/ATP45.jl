using Test
using ATP45
import ATP45: Simplified
import ATP45: AbstractWind, WindDirection, ReleaseLocation, AbstractReleaseLocation
import ATP45: AbstractWind, WindDirection, ReleaseLocation, AbstractReleaseLocation
import ATP45: MissingInputsException

@testset "Inputs" begin
    required = required_inputs(Simplified())
    @time Set(required)

    simple = Simplified()
    wind = WindDirection(11., 45)
    release = ReleaseLocation([4., 50.])
    simple(wind, release)
    @test missing_inputs(simple, wind) == [AbstractReleaseLocation{1, <:Number}]
    @test missing_inputs(simple, wind, release) == []
    @test missing_inputs(simple, release, release) == [AbstractWind]
    @test_throws MissingInputsException simple()

end
