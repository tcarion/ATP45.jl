@enum StabilityClass Unstable Neutral Stable

tostab(stab::Symbol) = getproperty(@__MODULE__, stab)

Base.convert(::Type{StabilityClass}, s::Symbol) = tostab(s)

abstract type AbstractWind end
mutable struct WindVector <: AbstractWind
    u::Real
    v::Real
end

mutable struct WindDirection <: AbstractWind
    speed::Real
    direction::Real
end

"""
    _2windvector(wind)

Convert the speed and azimuth of the wind into the coordinates of the wind vector.
"""
function _2windvector(wind::WindDirection)
    u = wind.speed*cosd(90 - wind.direction)
    v = wind.speed*sind(90 - wind.direction)
    return u, v
end

function _2winddir(wind::WindVector)
    dir = wind_azimuth(wind.u, wind.v)
    speed = wind_speed(wind)
    return speed, dir
end

"""
    wind_speed(Vx, Vy)

`Vx` and `Vy` are the components of the wind speed vector on the West-East and South-North directions respectively
Return the wind speed

"""
function wind_speed(Vx, Vy)
    return sqrt(Vx^2 + Vy^2)
end

wind_speed(wind::WindVector) = wind_speed(wind.u, wind.v)
function wind_speed(wind::WindDirection)
    WindVector = _2windvector(wind)
    wind_speed(WindVector[1], WindVector[2])
end

"""
    wind_azimuth(Vx, Vy)

Azimuth in degrees, the reference direction is North
"""
function wind_azimuth(Vx, Vy)
    return 90. - atan(Vy, Vx) * 180 / π
end

function wind_azimuth(lon1, lat1, lon2, lat2)
    x = cosd(lat1)*sind(lat2) - sind(lat1)*cosd(lat2)*cosd(lon2 - lon1)
    y = sind(lon2 - lon1)*cosd(lat2)
    return 2*atand(y/(sqrt(x^2 + y^2) + x))
end

wind_azimuth(wind::WindVector) = convert(WindDirection, wind).direction
wind_azimuth(wind::WindDirection) = wind.direction

function Base.convert(::Type{WindDirection}, w::WindVector)
    WindDirection(_2winddir(w)...)
end

function Base.convert(::Type{WindVector}, w::WindDirection)
    WindVector(_2windvector(w)...)
end