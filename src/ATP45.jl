module ATP45

import Base.==
using RecipesBase
using GeoInterface
using LibGEOS
using WellKnownGeometry: getwkt
using Proj
using InteractiveUtils
using AbstractTrees
import AbstractTrees: children, parent, nodevalue
using OrderedCollections: OrderedDict

import RecipesBase: @recipe

const GI = GeoInterface
const AT = AbstractTrees
const LG = LibGEOS

const EARTH_RADIUS = 6371.0e3

const DEFAULT_PROJ = Ref{Proj.geod_geodesic}()
const MAP_IDS = Dict{String, Any}()

function __init__()
    # values for WGS84 (https://manpages.ubuntu.com/manpages/bionic/man3/geodesic.3.html)
    a = 6378137.; f = 1/298.257223563
    Proj.geod_init(DEFAULT_PROJ, a, f)
    # DEFAULT_PROJ[] = Proj.proj_create("EPSG:4326")

    add_ids_to_map!(AbstractModel)
    add_ids_to_map!(AbstractStability)
    add_ids_to_map!(AbstractAgent)
    add_ids_to_map!(AbstractChemAgent)
    add_ids_to_map!(AbstractReleaseType)
    add_ids_to_map!(AbstractReleaseSize)
    add_ids_to_map!(AbstractAgentName)
    add_ids_to_map!(AbstractContainerType)
    # add_ids_to_map!(AbstractContainerGroup)
end

include("helpers.jl")
include("traits.jl")
include("meteorology.jl")
include("geometries.jl")
include("categories.jl")
include("inputs.jl")
include("models.jl")
include("tree.jl")

ATP45_TREE(wind::AbstractWind) = build_tree(wind)

include("dict.jl")

ATP45_VERBOSE_TREE(wind::AbstractWind) = build_verbose_tree(wind)
ATP45_DICT_TREE(wind::AbstractWind) = tree_to_dict(ATP45_VERBOSE_TREE(wind))

include("run.jl")
include("recipes.jl")

decision_tree(wind::AbstractWind; typedict = false) = typedict ? ATP45_DICT_TREE(wind) : ATP45_VERBOSE_TREE(wind)

"""
    map_ids()
Dictionnary mapping the existing id's to the `ATP45.jl` categories.

# Examples:
```julia-repl
julia> ATP45.map_ids()
Dict{String, Any} with 29 entries:
  "MPL"             => MissilesPayload()
  "MSL"             => Missile()
  "chem"            => Chemical()
  "typeC"           => ReleaseTypeC()
  "MNE"             => Mine()
  ⋮                 => ⋮
```
"""
map_ids() = MAP_IDS

export WindVector, WindAzimuth, Stable, Unstable, Neutral, ReleaseLocations
export Simplified, Detailed, run_atp
export ChemicalAgent, ChemicalWeapon, ChemicalSubstance, BiologicalAgent, RadiologicalAgent, NuclearAgent
export ReleaseTypeA, ReleaseTypeB, ReleaseTypeC, ReleaseBloodAgent, ReleaseTypeD, SubType1, SubType2, SubType3, ReleaseTypeP, ReleaseTypeQ, ReleaseTypeR, ReleaseTypeS
export ReleaseSmall, ReleaseMedium, ReleaseLarge, ReleaseExtraLarge
export Sarin
export decision_tree
export get_zones


end
