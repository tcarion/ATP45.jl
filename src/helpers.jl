"""
    horizontal_walk(lon::AbstractFloat, lat::AbstractFloat, distance::AbstractFloat, azimuth::AbstractFloat)

Compute the end location given a starting location `lon` and `lat` in degrees, a distance `distance` in meters
and an azimuth `azimuth` in degrees (the reference direction is North)
"""
function horizontal_walk(start::Vector{<:AbstractFloat}, distance::AbstractFloat, azimuth::AbstractFloat)
    proj = DEFAULT_PROJ[]
    q2, _ = geod_direct(lonlat2xy(start, proj), azimuth, distance, proj)
    xy2lonlat(q2, proj)
end
horizontal_walk(lon::Number, lat::Number, distance::Number, azimuth::Number) = horizontal_walk(Float64.([lon, lat]), distance, azimuth)

