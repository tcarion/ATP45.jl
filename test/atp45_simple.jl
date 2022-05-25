using Test
using ATP45

input = Atp45Input([[50., 3.]], WindCoords(10., 10.), :BOM, "TypeB")
ATP45.run(input)

lon, lat = 2.5, 46.
Vx, Vy = 0., 10.
@test ATP45.hazard_area_triangle(lon, lat, Vx, Vy, 14000., 2000.)[1][1] == lon
@test ATP45.hazard_area_triangle(lon, lat, Vy, Vx, 14000., 2000.)[1][2] ≈ lat atol=1e-4