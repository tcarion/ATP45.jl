using Test
using ATP45
import ATP45: ReleaseLocation
import ATP45: ZoneBoundary, Zone
import ATP45: TriangleLike
using GeoInterface
import GeoInterface as GI
using GeoJSON

@testset "Release locations" begin
    coords = [
        [6., 49.],
        [6., 51.],
    ]
    location = ReleaseLocation(coords)
    @test GI.testgeometry(location)
    @test GI.geomtrait(location) == MultiPointTrait()
    @test GI.ngeom(location) == 2
    @test GI.npoint(location) == 2
    @test GI.coordinates(location) == coords
    @test GI.getgeom(location, 1) == Tuple(coords[1])
    @test_throws BoundsError GI.getgeom(location, 3) 
    @test GeoJSON.write(location) == "{\"type\":\"MultiPoint\",\"coordinates\":[[6.0,49.0],[6.0,51.0]]}"

    location = ReleaseLocation((4., 50.))
    @test GI.testgeometry(location)
    @test GI.geomtrait(location) == MultiPointTrait()
    @test GI.ngeom(location) == 1
    @test GI.npoint(location) == 1
    @test GI.coordinates(location) == [[4., 50.]]
    @test_throws BoundsError GI.getgeom(location, 2) 
end

@testset "Zone boundary" begin
    coords = [
        [6., 49.],
        [5., 50.],
        [4., 49.],
    ]
    border = ZoneBoundary(coords)
    @test GI.testgeometry(border)
    @test GI.npoint(border) == 4
    @test GI.isring(border)
    @test GI.coordinates(border)[1:3] == coords
    @test GI.coordinates(border)[1] == GI.coordinates(border)[end]

    border2 = ZoneBoundary(coords[1], coords[2], coords[3])
    @test border == border2

    @test GeoJSON.write(border) == "{\"type\":\"LineString\",\"coordinates\":[[6.0,49.0],[5.0,50.0],[4.0,49.0],[6.0,49.0]]}"

end

@testset "Zone" begin
    coords = [
        [6., 49.],
        [6., 51.],
        [5., 50.],
        [4., 49.],
    ]
    zone = Zone(coords)
    @test GI.testgeometry(zone)
    @test GI.geomtrait(zone) == PolygonTrait()
    @test GI.ngeom(zone) == 1
    @test GI.coordinates(zone) == [[coords; [coords[1]]]]
    @test GI.getgeom(zone, 1) == ZoneBoundary(coords)
    @test GeoJSON.write(zone) == "{\"type\":\"Polygon\",\"coordinates\":[[[6.0,49.0],[6.0,51.0],[5.0,50.0],[4.0,49.0],[6.0,49.0]]]}"
end


# @testset "Triangle shape" begin
    coords = [
        [6., 49.],
        [5., 50.],
        [4., 49.],
    ]
    props = Dict(:type => "release")
    triangle = TriangleLike(coords, props)
    @test GI.npoint(triangle) == 3
    GI.getcoord(triangle, 2)
    GI.getgeom(triangle, 1)
    GI.testgeometry(triangle)
# end

