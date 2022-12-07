using ATP45
using Test
using Proj4

@testset "ATP45.jl" begin
    @testset "Horizontal walk with azimuth and distance" begin
        lon, lat = 4., 0.
        dist = 111321.
        dest = ATP45.horizontal_walk(lon, lat, dist, 90.)
        @test dest ≈ [lon+1, lat] atol=1e-4
   end

   @testset "ATP45 simple" begin include("atp45_simple.jl") end
   @testset "Zones" begin include("zones.jl") end
end
