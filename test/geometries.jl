using Test
using ATP45
import ATP45: ReleaseLocation
import ATP45: ZoneBoundary, Zone
import ATP45: CircleLike, TriangleLike
import ATP45: Atp45Result
import ATP45: WindDirection
import ATP45: GI
using ATP45.GeoInterface

using GeoJSON

@testset "Release locations" begin
    init_coords = [
        [6., 49.],
        [6., 51.],
    ]
    location = ReleaseLocation(init_coords)
    @test GI.testgeometry(location)
    @test GI.geomtrait(location) == MultiPointTrait()
    @test GI.ngeom(location) == 2
    @test GI.npoint(location) == 2
    @test GI.coordinates(location) == init_coords
    @test GI.getgeom(location, 1) == Tuple(init_coords[1])
    @test_throws BoundsError GI.getgeom(location, 3) 
    @test GeoJSON.write(location) == "{\"type\":\"MultiPoint\",\"coordinates\":[[6.0,49.0],[6.0,51.0]]}"

    location = ReleaseLocation([4., 50.])
    @test GI.testgeometry(location)
    @test GI.geomtrait(location) == MultiPointTrait()
    @test GI.ngeom(location) == 1
    @test GI.npoint(location) == 1
    @test GI.coordinates(location) == [[4., 50.]]
    @test_throws BoundsError GI.getgeom(location, 2) 
end

@testset "Zone boundary" begin
    init_coords = [
        [6., 49.],
        [5., 50.],
        [4., 49.],
    ]
    border = ZoneBoundary(init_coords)
    @test GI.testgeometry(border)
    @test GI.npoint(border) == 4
    @test GI.isring(border)
    @test GI.coordinates(border)[1:3] == init_coords
    @test GI.coordinates(border)[1] == GI.coordinates(border)[end]

    border2 = ZoneBoundary(init_coords[1], init_coords[2], init_coords[3])
    @test border == border2

    @test GeoJSON.write(border) == "{\"type\":\"LineString\",\"coordinates\":[[6.0,49.0],[5.0,50.0],[4.0,49.0],[6.0,49.0]]}"

end

@testset "Zone" begin
    init_coords = [
        [6., 49.],
        [6., 51.],
        [5., 50.],
        [4., 49.],
    ]
    zone = Zone(init_coords)
    @test GI.testgeometry(zone)
    @test GI.geomtrait(zone) == PolygonTrait()
    @test GI.ngeom(zone) == 1
    @test GI.coordinates(zone) == [[init_coords; [init_coords[1]]]]
    @test GI.getgeom(zone, 1) == ZoneBoundary(init_coords)
    @test GeoJSON.write(zone) == "{\"type\":\"Polygon\",\"coordinates\":[[[6.0,49.0],[6.0,51.0],[5.0,50.0],[4.0,49.0],[6.0,49.0]]]}"
end

@testset "CircleLike" begin
    init_coords = [
        [6., 51.],
    ]
    location = ReleaseLocation(init_coords)
    radius = 10000
    circle = CircleLike(location, radius, Dict("type" => "release"))
    @test GI.testfeature(circle)
    @test GI.geometry(circle) isa Zone
    @test GI.properties(circle) isa Dict
end

@testset "TriangeLike" begin
    init_coords = [
        [6., 51.],
    ]
    location = ReleaseLocation(init_coords)
    radius = 2000
    wind = WindDirection(11, 45.)
    dhd = 10000
    triangle = TriangleLike(location, wind, dhd, 2*radius, Dict("type" => "release"))
    @test GI.testfeature(triangle)
    @test GI.geometry(triangle) isa Zone
    @test GI.properties(triangle) isa Dict
end

@testset "Atp45 result" begin
    init_coords = [
        [6., 51.],
    ]
    location = ReleaseLocation(init_coords)
    radius = 2000
    wind = WindDirection(11, 45.)
    dhd = 10000
    triangle = TriangleLike(location, wind, dhd, 2*radius, Dict("type" => "release"))
    circle = CircleLike(location, radius, Dict("type" => "hazard"))
    result = Atp45Result([triangle, circle], Dict("procedure" => "dummy"))
    @test GI.testfeaturecollection(result)
    @test GI.nfeature(result) == 2
    @test GI.getfeature(result, 1) == triangle
end