module ATP45

using GeoInterface
using Proj
using RecipesBase
using GeoJSON
import GeoJSON: Feature, FeatureCollection, Polygon
using InteractiveUtils

import RecipesBase: @recipe

const GI = GeoInterface

const EARTH_RADIUS = 6371.0e3

const DEFAULT_PROJ = Ref{Proj.geod_geodesic}()
const MAP_IDS = Dict{String, Any}()

function __init__()
    # values for WGS84 (https://manpages.ubuntu.com/manpages/bionic/man3/geodesic.3.html)
    a = 6378137.; f = 1/298.257223563
    Proj.geod_init(DEFAULT_PROJ, a, f)
    # DEFAULT_PROJ[] = Proj.proj_create("EPSG:4326")

    add_ids_to_map(AbstractStability)
    add_ids_to_map(AbstractWeapon)
    add_ids_to_map(AbstractReleaseType)
    add_ids_to_map(AbstractContainerType)
    add_ids_to_map(AbstractContainerGroup)
end

# include("shapes.jl")
# include("coordinates.jl")
include("helpers.jl")
include("methods.jl")
include("meteorology.jl")
include("geometries.jl")
include("categories.jl")
include("constants.jl")
include("inputs.jl")
include("models.jl")
# include("atp45_.jl")
include("recipes.jl")

export WindVector, WindDirection, Atp45Input
export run_chem, run_bio

end
