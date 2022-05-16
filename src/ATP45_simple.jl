"""
Vx and Vy are the components of the wind speed vector on the West-East and South-North directions respectively

"""

function wind_speed(Vx, Vy)
    return sqrt(Vx^2 + Vy^2)
end


"""
    wind_direction(Vx, Vy)

Return the angle between the wind vector and the West-East direction

"""

function wind_direction(Vx, Vy)
    if Vx >= 0
        return atand(Vy/Vx)
    elseif Vy >= 0
        return 180. + atand(Vy/Vx)
    else
        return atand(Vy/Vx) - 180.
    end
end


"""
Azimuth in degrees, the reference direction is North

"""

function azimuth(Vx, Vy)
    return (90. - wind_direction(Vx, Vy))
end


"""
    circle_area(lon::AbstractFloat, lat::AbstractFloat, radius::AbstractFloat, res::AbstractFloat)

Calculate the coordinates of the release or the hazard area (circle)

"""

function circle_area(lon::AbstractFloat, lat::AbstractFloat, radius::AbstractFloat; pas = 1.)
    azimuth = 0.:pas:360.
    coords = []
    for az in azimuth
        push!(coords, horizontal_walk(lon, lat, radius, az))
    end
    return coords
end


"""
    hazard_area_triangle(lon, lat, Vx, Vy, hauteur, radius)

Calculate the coordinates of the ends of the hazard area (a triangle) in the case of a wind speed > 10km/h

"""

function hazard_area_triangle(lon, lat, Vx, Vy, hauteur, radius)
    l = hauteur/cosd(30)
    coords = []
    push!(coords, horizontal_walk(lon, lat, -2*radius, azimuth(Vx, Vy)))
    push!(coords, horizontal_walk(coords[1][1], coords[1][2], l, azimuth(Vx, Vy) - 30.))
    push!(coords, horizontal_walk(coords[1][1], coords[1][2], l, azimuth(Vx, Vy) + 30.))
    return coords
end


function simplified_proc(lon, lat, Vx, Vy; pas = 1.)
    release_area = Polygon([circle_area(lon, lat, 2000.; pas)])
    prop1 = Dict("type" => "release", "shape" => "circle")
    if wind_speed(Vx, Vy) <= 10
        hazard_area = Polygon([circle_area(lon, lat, 10000.; pas)])
        prop2 = Dict("type" => "hazard", "shape" => "circle")
        return Feature(release_area, prop1), Feature(hazard_area, prop2)
    else
        hazard_area = Polygon([hazard_area_triangle(lon, lat, Vx, Vy, 14000., 2000.)])
        prop2 = Dict("type" => "hazard", "shape" => "triangle")
        return Feature(release_area, prop1), Feature(hazard_area, prop2)
    end
end


function typeA(lon, lat, Vx, Vy; pas = 1.)
    release_area = Polygon([circle_area(lon, lat, 1000.; pas)])
    prop1 = Dict("type" => "release", "shape" => "circle")
    if wind_speed(Vx, Vy) <= 10
        hazard_area = Polygon([circle_area(lon, lat, 10000.; pas)])
        prop2 = Dict("type" => "hazard", "shape" => "circle")
        return Feature(release_area, prop1), Feature(hazard_area, prop2)
    else
        hazard_area = Polygon([hazard_area_triangle(lon, lat, Vx, Vy, 12000., 1000.)])
        prop2 = Dict("type" => "hazard", "shape" => "triangle")
        return Feature(release_area, prop1), Feature(hazard_area, prop2)
    end
end


function typeB(cont_type, lon, lat, Vx, Vy; pas = 1.)
    if haskey(CONT_TYPE1, cont_type)
        typeA(lon, lat, Vx, Vy; pas)
    elseif haskey(CONT_TYPE2, cont_type)
        simplified_proc(lon, lat, Vx, Vy; pas)
    end
end


function typeC(lon, lat; pas = 1.)
    hazard_area = Polygon([circle_area(lon, lat, 10000.; pas)])
    prop = Dict("type" => "hazard", "shape" => "circle")
    return Feature(hazard_area, prop)
end

const CONT_TYPE1 = Dict(
    :BML => Dict("name" => "Bomblet"),
    :SHL => Dict("name" => "Shell"),
    :MNE => Dict("name" => "Mine"),
    :SB_RKT => Dict("name" => "Surface Burst Rocket"),
    :SB_MSL => Dict("name" => "Surface Burst Missile")
)
    
const CONT_TYPE2 = Dict(
    :BOM => Dict("name" => "Bomb"),
    :NKN => Dict("name" => "Unknown"),
    :AB_RKT => Dict("name" => "Air Burst Rocket"),
    :AB_MSL => Dict("name" => "Air Burst Missile")
)