module ATP45

using GeoInterface
using Proj4
import GeoJSON: Feature, FeatureCollection, Polygon

const EARTH_RADIUS = 6371.0e3
const DEFAULT_PROJ = Ref{Any}(C_NULL)

function __init__()
    DEFAULT_PROJ[] = Projection("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
end

# include("shapes.jl")
# include("coordinates.jl")
include("helpers.jl")
include("constants.jl")
include("atp45.jl")

export WindCoords, WindDirection, Atp45Input

end
