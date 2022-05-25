abstract type AbstractWind end
mutable struct WindCoords <: AbstractWind
    u::Real
    v::Real
end

mutable struct WindAzimuth <: AbstractWind
    speed::Real
    azimuth::Real
end

mutable struct Atp45Input
    "Vector of locations in format [lon, lat]"
    locations::Vector{Vector{Real}}
    "Information about the wind"
    wind::AbstractWind
    "Type of containers"
    cont_type::Symbol
    "Type of procedure"
    cbrn_type::String
end

mutable struct Atp45Result
    "Coordinates of the multiple Atp45 model areas"
    collection::FeatureCollection
    "Input used for the model"
    input::Atp45Input
end

function run(input::Atp45Input)
    #result::FeatureCollection = foo()
    if input.cbrn_type == "TypeA"
        result = proc(input, 1000.)
    elseif input.cbrn_type == "TypeB"
        result = typeB(input)
    elseif input.cbrn_type == "TypeC"
        result = typeC(input)
    else
        result = proc(input, 2000.)
    end
    Atp45Result(result, input)
end

function windCoords(wind::WindAzimuth)
    u = wind.speed*cosd(90 - wind.azimuth)
    v = wind.speed*sind(90 - wind.azimuth)
    return u, v
end

"""
Vx and Vy are the components of the wind speed vector on the West-East and South-North directions respectively

"""

function wind_speed(Vx, Vy)
    return sqrt(Vx^2 + Vy^2)
end

wind_speed(wind::WindCoords) = wind_speed(wind.u, wind.v)
function wind_speed(wind::WindAzimuth)
    windcoords = windCoords(wind)
    wind_speed(windcoords[1], windcoords[2])
end


"""
    wind_direction(Vx, Vy)

Return the angle between the wind vector and the West-East direction

"""

function wind_direction(Vx, Vy)
    if Vx >= 0
        return atand(Vy/Vx)
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
    circle_area(lon::AbstractFloat, lat::AbstractFloat, radius::AbstractFloat, res)

Calculate the coordinates of the release or the hazard area (circle)

"""

function circle_area(lon::AbstractFloat, lat::AbstractFloat, radius::AbstractFloat, res = 360)
    azimuth = range(0., 360., length = res)
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

function hazard_area_triangle(lon, lat, Vx, Vy, dist, radius)
    l = dist/cosd(30)
    coords = []
    push!(coords, horizontal_walk(lon, lat, -2*radius, azimuth(Vx, Vy)))
    push!(coords, horizontal_walk(coords[1][1], coords[1][2], l, azimuth(Vx, Vy) - 30.))
    push!(coords, horizontal_walk(coords[1][1], coords[1][2], l, azimuth(Vx, Vy) + 30.))
    return coords
end

hazard_area_triangle(lon, lat, wind::WindCoords, dist, radius) = hazard_area_triangle(lon, lat, wind.u, wind.v, dist, radius)
function hazard_area_triangle(lon, lat, wind::WindAzimuth, dist, radius)
    windcoords = windCoords(wind)
    hazard_area_triangle(lon, lat, windcoords[1], windcoords[2], dist, radius)
end


function proc(input::Atp45Input, radius, res = 360)
    lon = input.locations[1][1]
    lat = input.locations[1][2]
    release_area = Polygon([circle_area(lon, lat, radius, res)])
    prop1 = Dict("type" => "release", "shape" => "circle")
    features = [Feature(release_area, prop1)]
    if wind_speed(input.wind) <= 10
        hazard_area = Polygon([circle_area(lon, lat, 10000., res)])
        prop2 = Dict("type" => "hazard", "shape" => "circle")
        push!(features, Feature(hazard_area, prop2))
    else
        hazard_area = Polygon([hazard_area_triangle(lon, lat, input.wind, 10000. + 2*radius, radius)])
        prop2 = Dict("type" => "hazard", "shape" => "triangle")
        push!(features, Feature(hazard_area, prop2))
    end
    FeatureCollection(features)
end



function typeB(input::Atp45Input, res = 360)
    if haskey(CONT_TYPE[:TYPE1], input.cont_type)
        proc(input, 1000., res)
    elseif haskey(CONT_TYPE[:TYPE2], input.cont_type)
        proc(input, 2000., res)
    end
end


function typeC(input::Atp45Input, res = 360)
    lon = input.locations[1][1]
    lat = input.locations[1][2]
    hazard_area = Polygon([circle_area(lon, lat, 10000., res)])
    prop = Dict("type" => "hazard", "shape" => "circle")
    return Feature(hazard_area, prop)
end

const CONT_TYPE = Dict(
    :TYPE1 => Dict(
        :BML => Dict("name" => "Bomblet"),
        :SHL => Dict("name" => "Shell"),
        :MNE => Dict("name" => "Mine"),
        :SB_RKT => Dict("name" => "Surface Burst Rocket"),
        :SB_MSL => Dict("name" => "Surface Burst Missile")
    ),
    :TYPE2 => Dict(
        :BOM => Dict("name" => "Bomb"),
        :NKN => Dict("name" => "Unknown"),
        :AB_RKT => Dict("name" => "Air Burst Rocket"),
        :AB_MSL => Dict("name" => "Air Burst Missile")
    )
)