using ATP45
using Test
using Proj4

@testset "ATP45.jl" begin
    @testset "Horizontal walk with azimuth and distance" begin
        lon, lat = 4., 50.
        distance = 111321.
        azimuth = 90.
        dest = ATP45.horizontal_walk(lon, lat, dist)
        @test dest ≈ [lon+1, lat] atol=1e-4
   end

   @testset "ATP45 simple" begin include("atp45_simple.jl") end
end
