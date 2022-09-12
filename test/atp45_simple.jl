using Test
using ATP45
import ATP45: Stable, Unstable

##
lon, lat = 2.5, 46.
lon1, lat1 = 2.6, 45.7
Vx, Vy = 7., 5

relpoint = [50., 4]
atp_input = Atp45Input(
    [relpoint],
    WindCoords(Vx, Vy),
    :BOM,
    :simplified,
    ATP45.Stable
)


res = ATP45.run_chem(atp_input).collection 

coords1 = GeoJSON.coordinates(res[1])
coords2 = GeoJSON.coordinates(res[2])
plot(aspect_ratio = 1.)
plot!(Tuple.(coords1[1]), marker = :scatter)
plot!(Tuple.(coords2[1]), marker = :scatter, color = :yellow)
plot!(Tuple(relpoint), marker = :scatter, color = :red)

##

@testset "Wind" begin
    wdir = WindDirection(11., 45)
    wc_conv = convert(WindCoords, wdir)
    @test wc_conv.u ≈ wc_conv.v
    Vx, Vy = 1., 5.
    wc = WindCoords(Vx, Vy)
    wd_conv = convert(WindDirection, wc)
    wd_cc = convert(WindDirection, wc_conv)
    @test wd_cc.speed == wdir.speed
    @test wd_cc.direction == wdir.direction
end

function plotwind(w::ATP45.AbstractWind)
    wc = convert(WindCoords, w)
    quiver([0], [0], quiver = ([w.u], [w.v]))
end

@recipe function f(w::ATP45.AbstractWind; x_origin = 0., y_origin = 0.)
    wc = convert(WindCoords, w)
    seriestype --> :quiver
    quiver --> ([wc.u], [wc.v])
    [x_origin], [y_origin]
end

##
wdir = WindDirection(15., 110)
p = plot(wdir, aspect_ratio = 1, x_origin = 1)
plot!(p, aspec_ratio = 1.)
##

@test ATP45.hazard_area_triangle(lon, lat, Vx, Vy, 14000., 2000.)[1][1] == lon
@test ATP45.hazard_area_triangle(lon, lat, Vy, Vx, 14000., 2000.)[1][2] ≈ lat atol=1e-4
@test ATP45.circle_area(lon, lat, 1000., 360)[1][1] == lon

input = Atp45Input([[lon, lat], [lon1, lat1]], WindDirection(15., 0.), :SPR, :B, Unstable)
a = ATP45.run(input)
coords = a.collection.features[2].geometry.coordinates[1]
@test coords[1][1] == lon
@test coords[5][1] == lon1

input1 = Atp45Input([[lon, lat]], WindDirection(15., 90.), :BOM, :A, Unstable)
b = ATP45.run(input1)
coords1 = b.collection.features[2].geometry.coordinates[1]
@test coords1[1][2] ≈ lat atol=1e-4