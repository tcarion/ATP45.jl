module ATP45

using GeoInterface
using Proj
using RecipesBase
using GeoJSON
import GeoJSON: Feature, FeatureCollection, Polygon

import RecipesBase: @recipe

const GI = GeoInterface

const EARTH_RADIUS = 6371.0e3

const DEFAULT_PROJ = Ref{Proj.geod_geodesic}()

function __init__()
    # values for WGS84 (https://manpages.ubuntu.com/manpages/bionic/man3/geodesic.3.html)
    a = 6378137.; f = 1/298.257223563
    Proj.geod_init(DEFAULT_PROJ, a, f)
    # DEFAULT_PROJ[] = Proj.proj_create("EPSG:4326")
end

# include("shapes.jl")
# include("coordinates.jl")
include("helpers.jl")
include("categories.jl")
include("meteorology.jl")
include("zones.jl")
include("constants.jl")
include("atp45_.jl")
include("recipes.jl")

export WindVector, WindDirection, Atp45Input
export run_chem, run_bio

end
