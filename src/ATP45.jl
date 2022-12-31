module ATP45

import Base.==
using GeoInterface
using Proj
using RecipesBase
using InteractiveUtils
using AbstractTrees
import AbstractTrees: children, parent, nodevalue
using OrderedCollections: OrderedDict

import RecipesBase: @recipe

const GI = GeoInterface
const AT = AbstractTrees

const EARTH_RADIUS = 6371.0e3

const DEFAULT_PROJ = Ref{Proj.geod_geodesic}()
const MAP_IDS = Dict{String, Any}()

function __init__()
    # values for WGS84 (https://manpages.ubuntu.com/manpages/bionic/man3/geodesic.3.html)
    a = 6378137.; f = 1/298.257223563
    Proj.geod_init(DEFAULT_PROJ, a, f)
    # DEFAULT_PROJ[] = Proj.proj_create("EPSG:4326")

    add_ids_to_map(AbstractModel)
    add_ids_to_map(AbstractStability)
    add_ids_to_map(AbstractWeapon)
    add_ids_to_map(AbstractReleaseType)
    add_ids_to_map(AbstractContainerType)
    # add_ids_to_map(AbstractContainerGroup)
end

include("helpers.jl")
include("methods.jl")
include("meteorology.jl")
include("geometries.jl")
include("categories.jl")
include("inputs.jl")
include("models.jl")
include("tree.jl")

const ATP45_TREE = build_tree()

include("dict.jl")

const ATP45_VERBOSE_TREE = build_verbose_tree()
const ATP45_DICT_TREE = tree_to_dict(ATP45_VERBOSE_TREE)

include("run.jl")
include("recipes.jl")

decision_tree(; typedict = false) = typedict ? ATP45_DICT_TREE : ATP45_VERBOSE_TREE
map_ids() = MAP_IDS

export WindVector, WindDirection, Stable, Unstable, Neutral, ReleaseLocation
export Simplified, Detailed
export ChemicalWeapon, BiologicalWeapon, RadiologicalWeapon, NuclearWeapon
export ReleaseTypeA, ReleaseTypeB, ReleaseTypeC
export decision_tree


end
