"""
    horizontal_walk(lon::AbstractFloat, lat::AbstractFloat, distance::AbstractFloat, azimuth::AbstractFloat)

Compute the end location given a starting location `lon` and `lat` in degrees, a distance `distance` in meters
and an azimuth `azimuth` in degrees (the reference direction is North)
"""
function horizontal_walk(start::Vector{T}, distance::AbstractFloat, azimuth::AbstractFloat) where {T<:Number}
    outlon = Ref{Cdouble}()
    outlat = Ref{Cdouble}()
    Proj.geod_direct(DEFAULT_PROJ, start[2], start[1], azimuth, distance, outlat, outlon, Ref(0.))
    [outlon[], outlat[]]
end
horizontal_walk(lon::Number, lat::Number, distance::Number, azimuth::Number) = horizontal_walk(Float64.([lon, lat]), distance, azimuth)

