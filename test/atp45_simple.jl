using Test
using ATP45

lon, lat = 2.5, 46.
lon1, lat1 = 2.6, 45.7
Vx, Vy = 0., 10.
@test ATP45.hazard_area_triangle(lon, lat, Vx, Vy, 14000., 2000.)[1][1] == lon
@test ATP45.hazard_area_triangle(lon, lat, Vy, Vx, 14000., 2000.)[1][2] ≈ lat atol=1e-4
@test ATP45.circle_area(lon, lat, 1000., 360)[1][1] == lon

input = Atp45Input([[lon, lat], [lon1, lat1]], WindAzimuth(15., 0.), :SPR, :B, U)
a = ATP45.run(input)
coords = a.collection.features[2].geometry.coordinates[1]
@test coords[1][1] == lon
@test coords[5][1] == lon1

input1 = Atp45Input([[lon, lat]], WindAzimuth(15., 90.), :BOM, :A, U)
b = ATP45.run(input1)
coords1 = b.collection.features[2].geometry.coordinates[1]
@test coords1[1][2] ≈ lat atol=1e-4