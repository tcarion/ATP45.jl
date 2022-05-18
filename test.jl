using Plots
using ATP45

function Plot(lon, lat, azimuth)
    l = 14000/cosd(30)
    LON = []
    LAT = []
    push!(LON, ATP45.horizontal_walk(lon, lat, -4000., azimuth)[1])
    push!(LAT, ATP45.horizontal_walk(lon, lat, -4000., azimuth)[2])
    push!(LON, ATP45.horizontal_walk(LON[1], LAT[1], l, azimuth - 30.)[1])
    push!(LAT, ATP45.horizontal_walk(LON[1], LAT[1], l, azimuth - 30.)[2])
    push!(LON, ATP45.horizontal_walk(LON[1], LAT[1], l, azimuth + 30.)[1])
    push!(LAT, ATP45.horizontal_walk(LON[1], LAT[1], l, azimuth + 30.)[2])
    push!(LON, ATP45.horizontal_walk(lon, lat, -4000., azimuth)[1])
    push!(LAT, ATP45.horizontal_walk(lon, lat, -4000., azimuth)[2])
    plot!(LON, LAT, label=azimuth)
end


az = [0., 45., 90., 135., 180., 225., 270., 315.]
for azi in az
    display(Plot(2.5, 46., azi))
end


plot(ATP45.typeB("BML", 2.5, 46., 10., 10., 10.)[2])
plot!(ATP45.typeB("BML", 2.5, 46., 10., 10., 10.)[1])

plot(ATP45.simplified_proc(2.5, 46., 10., 10., 10.)[2])
plot!(ATP45.simplified_proc(2.5, 46., 10., 10., 10.)[1])

plot(ATP45.simplified_proc(2.5, 46., 10., 1., 1.)[2])
plot!(ATP45.simplified_proc(2.5, 46., 10., 1., 1.)[1])

Vx = [0., 100., 100., 100., 0., -100., -100., -100.]
Vy = [100., 100., 0., -100., -100., -100., 0., 100.]
for (vx, vy) in zip(Vx, Vy)
    plot!(ATP45.simplified_proc(2.5, 46., vx, vy, 10.)[2])
    plot!(ATP45.simplified_proc(2.5, 46., vx, vy, 10.)[1])
    display(plot!(line(2.5, 46., 14000., vx, vy)))
end

plot()


function line(lon, lat, dist, Vx, Vy)
    coords = [[lon, lat]]
    push!(coords, ATP45.horizontal_walk(lon, lat, dist, ATP45.azimuth(Vx, Vy)))
    
    linestring = LineString(coords)
    prop = Dict("shape" => "line")
    return Feature(linestring, prop)
end
