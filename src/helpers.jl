"""
    horizontal_walk(lon::AbstractFloat, lat::AbstractFloat, distance::AbstractFloat, azimuth::AbstractFloat)

Compute the end location given a starting location `lon` and `lat` in degrees, a distance `distance` in meters
and an azimuth `azimuth` in degrees (the reference direction is North)
"""
function horizontal_walk(start::Vector{T}, distance::T, azimuth::T) where {T<:Number}
    outlon = Ref{Cdouble}()
    outlat = Ref{Cdouble}()
    Proj.geod_direct(DEFAULT_PROJ, start[2], start[1], azimuth, distance, outlat, outlon, Ref(0.))
    [outlon[], outlat[]]
end
horizontal_walk(lon::Number, lat::Number, distance::Number, azimuth::Number) = horizontal_walk(Float64.([lon, lat]), distance, azimuth)

"""
    circle_coordinates(lon::Number, lat::Number, radius::Number, res)

Calculate the coordinates of a circle like zone given the center (`lon`, `lat`) and the `radius` in meters. `res` is the number of points on the circle.
"""
function circle_coordinates(lon::Number, lat::Number, radius::Number; res = 360)
    # azimuth = range(0., 360., length = res)
    # coords = []
    # for az in azimuth
    #     push!(coords, horizontal_walk(lon, lat, radius, az))
    # end
    # return coords

    map(range(0., 360., length = res)) do azimuth
        horizontal_walk(lon, lat, radius, azimuth)
    end
end