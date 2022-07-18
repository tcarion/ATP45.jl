const CONTAINERS = Dict(
    :BML => Dict(
        :name => "Bomblet",
        :type => 1
    ),
    :SHL => Dict(
        :name => "Shell",
        :type => 1
    ),
    :MNE => Dict(
        :name => "Mine",
        :type => 1
    ),
    :SB_RKT => Dict(
        :name => "Surface Burst Rocket",
        :type => 1
    ),
    :SB_MSL => Dict(
        :name => "Surface Burst Missile",
        :type => 1
    ),
    :BOM => Dict(
        :name => "Bomb",
        :type => 2
    ),
    :NKN => Dict(
        :name => "Unknown",
        :type => 2
    ),
    :AB_RKT => Dict(
        :name => "Air Burst Rocket",
        :type => 2
    ),
    :AB_MSL => Dict(
        :name => "Air Burst Missile",
        :type => 2
    ),
    :SPR => Dict(
        :name => "Tank",
        :type => 3
    ),
    :GEN => Dict(
        :name => "Aerosols",
        :type => 3
    )
)


const PROCEDURES = Dict(
    :simplified => Dict(
        :name => "Simplified Procedure"
    ),
    :A => Dict(
        :name => "Non Persistent Agents"
    ),
    :B => Dict(
        :name => "Persistent Agents"
    ),
    :C => Dict(
        :name => "Unobserved Release"
    )
)

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
    container::Symbol
    "Type of procedure"
    procedure::Symbol
end

mutable struct Atp45Result
    "Coordinates of the multiple Atp45 model areas"
    collection::FeatureCollection
    "Input used for the model"
    input::Atp45Input
end

function run(input::Atp45Input)
    #result::FeatureCollection = foo()
    if input.procedure == :A
        Atp45Result(proc(input, 1000.), input)
    elseif input.procedure == :B
        Atp45Result(typeB(input), input)
    elseif input.procedure == :C
        Atp45Result(typeC(input), input)
    elseif input.procedure == :simplified
        Atp45Result(proc(input, 2000.), input)
    else
        error("The procedure type $(input.procedure) is not recognized")
    end
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

function azimuth(lon1, lat1, lon2, lat2)
    x = cosd(lat1)*sind(lat2) - sind(lat1)*cosd(lat2)*cosd(lon2 - lon1)
    y = sind(lon2 - lon1)*cosd(lat2)
    return 2*atand(y/(sqrt(x^2 + y^2) + x))
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



function typeB_2(input::Atp45Input, res = 360)
    lon1 = input.locations[1][1]
    lat1 = input.locations[1][2]
    lon2 = input.locations[2][1]
    lat2 = input.locations[2][2]

    release_area1 = circle_area(lon1, lat1, 1000., res)
    release_area2 = circle_area(lon2, lat2, 1000., res)

    az = Int(round(azimuth(lon1, lat1, lon2, lat2)))
    if az < 0
        az += 360
    end

    if az <= 90
        coords_release = [vcat([release_area1[az + 90:az + 270]]..., [release_area2[az + 270:end]]..., [release_area2[1:az + 90]]...)]
    elseif 90 < az <= 270
        coords_release = [vcat([release_area1[az + 90:end]]..., [release_area1[1:az - 90]]..., [release_area2[az - 90:az + 90]]...)]
    else
        coords_release = [vcat([release_area1[az - 270:az - 90]]..., [release_area2[az - 90:end]]..., [release_area2[1:az - 270]]...)]
    end

    release_area = Polygon(coords_release)
    prop1 = Dict("type" => "release", "shape" => "circles")
    feature = [Feature(release_area, prop1)]

    if wind_speed(input.wind) <= 10
        hazard_area1 = circle_area(lon1, lat1, 10000., res)
        hazard_area2 = circle_area(lon2, lat2, 10000., res)  
        if az <= 90
            coords_hazard = [vcat([hazard_area1[az + 90:az + 270]]..., [hazard_area2[az + 270:end]]..., [hazard_area2[1:az + 90]]...)]
        elseif 90 < az <= 270
            coords_hazard = [vcat([hazard_area1[az + 90:end]]..., [hazard_area1[1:az - 90]]..., [hazard_area2[az - 90:az + 90]]...)]
        else
            coords_hazard = [vcat([hazard_area1[az - 270:az - 90]]..., [hazard_area2[az - 90:end]]..., [hazard_area2[1:az - 270]]...)]
        end

        hazard_area = Polygon(coords_hazard)
        prop2 = Dict("type" => "hazard", "shape" => "circles")
        push!(feature, Feature(hazard_area, prop2))
    else
        if az <= 180
            hazard_triangle1 = hazard_area_triangle(lon1, lat1, input.wind, 10000., 1000.)
            hazard_triangle2 = hazard_area_triangle(lon2, lat2, input.wind, 10000., 1000.)
        else
            hazard_triangle1 = hazard_area_triangle(lon2, lat2, input.wind, 10000., 1000.)
            hazard_triangle2 = hazard_area_triangle(lon1, lat1, input.wind, 10000., 1000.)
        end

        if az <= 45 || 180 <= az <= 225
            if input.wind.azimuth <= 45
                coords = [vcat([hazard_triangle1[1]], [hazard_triangle1[2]], [hazard_triangle2[2]], [hazard_triangle2[3]], [hazard_triangle1[3]])]
            elseif 45 < input.wind.azimuth <= 135
                coords = [vcat([hazard_triangle1[1]], [hazard_triangle1[3]], [reverse(hazard_triangle2)...])]
            elseif 135 < input.wind.azimuth <= 180
                coords = [vcat([hazard_triangle2[1]], [hazard_triangle2[2]], [hazard_triangle1[2]], [hazard_triangle1[3]], [hazard_triangle1[1]])]
            elseif 180 < input.wind.azimuth <= 225
                coords = [vcat([hazard_triangle1[2]], [hazard_triangle1[3]], [hazard_triangle2[3]], [hazard_triangle2[1]], [hazard_triangle2[2]])]
            elseif 225 < input.wind.azimuth <= 270
                coords = [vcat([hazard_triangle1]..., [hazard_triangle2[3]], [hazard_triangle2[1]])]
            else
                coords = [vcat([hazard_triangle1[1]], [hazard_triangle1[2]], [hazard_triangle2[2]], [hazard_triangle2[3]], [hazard_triangle2[1]])]
            end

        elseif 45 < az <= 90 || 225 <= az <= 270
            if input.wind.azimuth <= 45
                coords = [vcat([hazard_triangle1[1]], [hazard_triangle1[2]], [hazard_triangle2[2]], [hazard_triangle2[3]], [hazard_triangle2[1]])]
            elseif 45 < input.wind.azimuth <= 90
                coords = [vcat([hazard_triangle1[1]], [hazard_triangle1[2]], [hazard_triangle2[2]], [hazard_triangle2[3]], [hazard_triangle1[3]])]
            elseif 90 < input.wind.azimuth <= 180
                coords = [vcat([hazard_triangle2]..., [hazard_triangle1[3]], [hazard_triangle1[1]])]
            elseif 180 < input.wind.azimuth <= 225
                coords = [vcat([hazard_triangle2[1]], [hazard_triangle2[2]], [hazard_triangle1[2]], [hazard_triangle1[3]], [hazard_triangle1[1]])]
            elseif 225 < input.wind.azimuth <= 270
                coords = [vcat([hazard_triangle1[2]], [hazard_triangle1[3]], [hazard_triangle2[3]], [hazard_triangle2[1]], [hazard_triangle2[2]])]
            else
                coords = [vcat([hazard_triangle1]..., [hazard_triangle2[3]], [hazard_triangle2[1]])]
            end

        elseif 90 < az <= 135 || 270 <= az <= 315
            if input.wind.azimuth <= 90
                coords = [vcat([hazard_triangle1[1]], [hazard_triangle1[2]], [hazard_triangle2[2]], [hazard_triangle2[3]], [hazard_triangle2[1]])]
            elseif 90 < input.wind.azimuth <= 135
                coords = [vcat([hazard_triangle1[1]], [hazard_triangle1[2]], [hazard_triangle2[2]], [hazard_triangle2[3]], [hazard_triangle1[3]])]
            elseif 135 < input.wind.azimuth <= 225
                coords = [vcat([hazard_triangle2]..., [hazard_triangle1[3]], [hazard_triangle1[1]])]
            elseif 225 <= input.wind.azimuth <= 270
                coords = [vcat([hazard_triangle2[1]], [hazard_triangle2[2]], [hazard_triangle1[2]], [hazard_triangle1[3]], [hazard_triangle1[1]])]
            elseif 270 < input.wind.azimuth <= 315
                coords = [vcat([hazard_triangle1[2]], [hazard_triangle1[3]], [hazard_triangle2[3]], [hazard_triangle2[1]], [hazard_triangle2[2]])]
            else
                coords = [vcat([hazard_triangle1]..., [hazard_triangle2[3]], [hazard_triangle2[1]])]
            end

        else
            if input.wind.azimuth <= 90
                coords = [vcat([hazard_triangle1]..., [hazard_triangle2[3]], [hazard_triangle2[1]])]
            elseif 90 < input.wind.azimuth <= 135
                coords = [vcat([hazard_triangle1[1]], [hazard_triangle1[2]], [hazard_triangle2[2]], [hazard_triangle2[3]], [hazard_triangle2[1]])]
            elseif 135 < input.wind.azimuth <= 180
                coords = [vcat([hazard_triangle1[1]], [hazard_triangle1[2]], [hazard_triangle2[2]], [hazard_triangle2[3]], [hazard_triangle1[3]])]
            elseif 180 < input.wind.azimuth <= 225
                coords = [vcat([hazard_triangle2]..., [hazard_triangle1[3]], [hazard_triangle1[1]])]
            elseif 225 < input.wind.azimuth <= 315
                coords = [vcat([hazard_triangle2[1]], [hazard_triangle2[2]], [hazard_triangle1[2]], [hazard_triangle1[3]], [hazard_triangle1[1]])]
            else
                coords = [vcat([hazard_triangle1[2]], [hazard_triangle1[3]], [hazard_triangle2[3]], [hazard_triangle2[1]], [hazard_triangle2[2]])]
            end
        end

        
        hazard_area = Polygon(coords)
        prop2 = Dict("type" => "hazard", "shape" => "triangles")
        push!(feature, Feature(hazard_area, prop2))
    end
    FeatureCollection(feature)
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
    if CONTAINERS[input.container][:type] == 1
        proc(input, 1000., res)
    elseif CONTAINERS[input.container][:type] == 2
        proc(input, 2000., res)
    elseif CONTAINERS[input.container][:type] == 3
        typeB_2(input, res)
    end
end


function typeC(input::Atp45Input, res = 360)
    lon = input.locations[1][1]
    lat = input.locations[1][2]
    hazard_area = Polygon([circle_area(lon, lat, 10000., res)])
    prop = Dict("type" => "hazard", "shape" => "circle")
    feature = [Feature(hazard_area, prop)]
    FeatureCollection(feature)
end