using ATP45
using Test
# using Aqua

# Aqua.test_all(ATP45; ambiguities = false)

@testset "ATP45.jl" begin
    @testset "Horizontal walk with azimuth and distance" begin
        lon, lat = 4., 0.
        distance = 111321.
        azimuth = 90.
        dest = ATP45.horizontal_walk(lon, lat, distance, azimuth)
        @test dest ≈ [lon+1, lat] atol=1e-4
   end

#    @testset "ATP45 simple" begin include("atp45_simple.jl") end
   @testset "Traits" begin include("traits.jl") end
   @testset "Geometries" begin include("geometries.jl") end
   @testset "Inputs" begin include("inputs.jl") end
   @testset "Models run" begin include("models.jl") end
   @testset "Tree" begin include("tree.jl") end
   @testset "Dict" begin include("dict.jl") end
   @testset "Run" begin include("run.jl") end
end
