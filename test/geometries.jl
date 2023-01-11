using Test
using ATP45
import ATP45: ReleaseLocation
import ATP45: ZoneBoundary, Zone
import ATP45: CircleLikeZone, TriangleLikeZone
import ATP45: HazardZone, ReleaseZone
import ATP45: Atp45Result
import ATP45: WindDirection
import ATP45: GI, convexhull
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
    @test length(ATP45.coords(zone)) == length(init_coords)
    @test GI.testgeometry(zone)
    @test GI.geomtrait(zone) == PolygonTrait()
    @test GI.ngeom(zone) == 1
    @test GI.coordinates(zone) == [[init_coords; [init_coords[1]]]]
    @test GI.getgeom(zone, 1) == ZoneBoundary(init_coords)
    @test GeoJSON.write(zone) == "{\"type\":\"Polygon\",\"coordinates\":[[[6.0,49.0],[6.0,51.0],[5.0,50.0],[4.0,49.0],[6.0,49.0]]]}"
end

@testset "CircleLikeZone" begin
    init_coords = [
        [6., 51.],
    ]
    location = ReleaseLocation(init_coords)
    radius = 10000
    circle = CircleLikeZone(location, radius; numpoint = 10)
    @test ATP45.boundaries(circle) isa ZoneBoundary{10}
    @test length(ATP45.coords(circle)) == 10
    @test GI.testgeometry(circle)
    @test length(GI.coordinates(circle)[1]) == 11
end

@testset "TriangeLikeZone" begin
    init_coords = [
        [6., 51.],
    ]
    location = ReleaseLocation(init_coords)
    radius = 2000
    wind = WindDirection(11, 45.)
    dhd = 10000
    triangle = TriangleLikeZone(location, wind, dhd, 2*radius)
    @test ATP45.boundaries(triangle) isa ZoneBoundary{3}
    @test length(ATP45.coords(triangle)) == 3
    @test GI.testgeometry(triangle)
    @test length(GI.coordinates(triangle)[1]) == 4
end

@testset "ZoneFeatures" begin
    init_coords = [
        [6., 49.],
        [6., 51.],
        [5., 50.],
        [4., 49.],
    ]
    hazard = HazardZone(init_coords)
    @test GI.testfeature(hazard)
    @test GI.geometry(hazard) isa Zone{4}
    @test GI.coordinates(hazard)[1] |> length == 5
    @test GI.properties(hazard).type == "hazard"

    circle = CircleLikeZone(ReleaseLocation([4.,50.]), 10000.; numpoint = 10)
    release = ReleaseZone(circle)
    @test GI.testfeature(release)
    @test GI.geometry(release) isa ATP45.AbstractZone{10}
    @test GI.properties(release).type == "release"
end

@testset "Geometries operation" begin
    locations = ReleaseLocation([[4., 50.], [4.2, 50.]])
    zone1 = CircleLikeZone(ATP45.coords(locations)[1], 1_000; numpoint = 10)
    zone2 = CircleLikeZone(ATP45.coords(locations)[2], 1_000; numpoint = 10)
    hull = convexhull(zone1, zone2)
    @test hull isa ATP45.AbstractZone
end

@testset "Atp45 result" begin
    init_coords = [
        [6., 51.],
    ]
    location = ReleaseLocation(init_coords)
    radius = 2000
    wind = WindDirection(11, 45.)
    dhd = 10000
    triangle = TriangleLikeZone(location, wind, dhd, 2*radius)
    circle = CircleLikeZone(location, radius)
    result = Atp45Result([HazardZone(triangle), ReleaseZone(circle)], Dict("procedure" => "dummy"))
    @test GI.testfeaturecollection(result)
    @test GI.nfeature(result) == 2
    @test GI.getfeature(result, 1) == HazardZone(triangle)
end