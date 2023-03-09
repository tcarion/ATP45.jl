var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ATP45","category":"page"},{"location":"#ATP45","page":"Home","title":"ATP45","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"ATP45 implements the NATO ATP-45 impact assessment model for CBRN-type incidents.","category":"page"},{"location":"#Getting-started","page":"Home","title":"Getting started","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using ATP45\nusing Plots\ndetailed_chem = (ChemicalWeapon(), Detailed(), ReleaseTypeB(), \"SPR\")\nreleases = ReleaseLocations([4., 50.], [4.15, 50.03])\nwind = WindAzimuth(2., 45.)\nresult = run_atp(detailed_chem..., releases, wind)\nplot(result)\nsavefig(\"example.png\")","category":"page"},{"location":"#Run-ATP-45:","page":"Home","title":"Run ATP-45:","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The package provides a simple and flexible API to run the proper ATP-45 case, according to the parameters and inputs provided by the user. Setting up the simplified ATP-45 model in case of chemical weapons goes like this:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using ATP45\nsimple_chem = (ChemicalWeapon(), Simplified()) ","category":"page"},{"location":"","page":"Home","title":"Home","text":"After defining the desired categories of ATP-45, we define the location of the release at longitude 4.0 and latitude 50.0, as well as a wind of speed 5.0 m/s and pointing 45° from North:","category":"page"},{"location":"","page":"Home","title":"Home","text":"release = ReleaseLocations([4., 50.]);\nwind = WindAzimuth(5., 45.);\nnothing # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"We finally pass these as arguments to the run_atp function. This function takes as arguments an arbitrary number of categories and inputs, so the splat operator (...) needs to be used on the simple_chem tuple. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"result = run_atp(simple_chem..., release, wind)","category":"page"},{"location":"","page":"Home","title":"Home","text":"The result can be easily plotted with Plots.jl:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Plots\nplot(result)\nsavefig(\"simplified_example.png\"); nothing # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: )","category":"page"},{"location":"","page":"Home","title":"Home","text":"We can also use the string id's corresponding to the categories instead of the Julia objects:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using ATP45\nrun_atp(\"detailed\", \"chem\", \"typeA\", ATP45.Shell(), \"stable\", wind, release)","category":"page"},{"location":"","page":"Home","title":"Home","text":"The id's and their corresponding objects can be seen with ATP45.map_ids:","category":"page"},{"location":"","page":"Home","title":"Home","text":"ATP45.map_ids()","category":"page"},{"location":"","page":"Home","title":"Home","text":"We can have more details about each categories defined in ATP-45 with the ATP45.properties method:","category":"page"},{"location":"","page":"Home","title":"Home","text":"ATP45.properties(\"typeA\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"If some categories or some inputs are missing, you should get an explanatory error about what's missing:","category":"page"},{"location":"","page":"Home","title":"Home","text":"run_atp(\"detailed\", \"chem\", \"typeA\", ATP45.Shell(), wind, release)","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Implementation-of-[GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl)","page":"Home","title":"Implementation of GeoInterface.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The Atp45Result type implements the GeoInterface.jl interface, which means that the coordinates of the ATP-45 zones can be accessed with the GeoInterface.jl methods:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using GeoInterface\nresult = run_atp(\"chem\", \"simplified\", wind, release)\nGeoInterface.coordinates(result)","category":"page"},{"location":"","page":"Home","title":"Home","text":"It also means that the result can be easily converted to GeoJSON:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using GeoJSON\nGeoJSON.write(result)","category":"page"},{"location":"#Documentation","page":"Home","title":"Documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"run_atp\nReleaseLocations\nWindAzimuth\nWindVector\nAtp45Result\nATP45.map_ids","category":"page"},{"location":"#ATP45.run_atp","page":"Home","title":"ATP45.run_atp","text":"run_atp(args...)\n\nHigh level function to run the ATP-45 procedure. The arguments args can be pretty flexible. They can be expressed as :\n\ncategories and input types from ATP45.jl\n\nlocations = ReleaseLocationss([4., 50.])\nwind = WindAzimuth(2.5, 45.)\nrun_atp(Simplified(), ChemicalWeapon(), locations, wind)\n\nstring corresponding to the categories' id's. See map_ids to know the id's of the existing categories:\n\nrun_atp(\"simplified\", \"chem\", locations, wind)\n\na combination of both:\n\nrun_atp(Simplified(), \"chem\", locations, wind)\n\n\n\n\n\n","category":"function"},{"location":"#ATP45.ReleaseLocations","page":"Home","title":"ATP45.ReleaseLocations","text":"ReleaseLocations{N, T}\n\nRepresents the N locations of the release(s).\n\nExamples\n\njulia> coords = [\n    [6., 49.],\n    [6., 51.],\n]\njulia> ReleaseLocations(coords)\nReleaseLocations{2, Float64}(((6.0, 49.0), (6.0, 51.0)))\n\n\n\n\n\n","category":"type"},{"location":"#ATP45.WindAzimuth","page":"Home","title":"ATP45.WindAzimuth","text":"WindAzimuth(speed, azimuth) <: AbstractWind\n\nDefines the wind with its speed in m/s and its azimuth in degrees (with North as reference).\n\n\n\n\n\n","category":"type"},{"location":"#ATP45.WindVector","page":"Home","title":"ATP45.WindVector","text":"WindVector(u, v) <: AbstractWind\n\nDefines the wind with its horizontal coordinates. u is W-E and v is S-N.\n\n\n\n\n\n","category":"type"},{"location":"#ATP45.Atp45Result","page":"Home","title":"ATP45.Atp45Result","text":"Atp45Result\n\nCollection of zones representing the result of an ATP-45 procedure result. Also contains relevant information about the input conditions. It implements the GeoInterface.FeatureCollection trait. The properties can be accessed with ATP45.properties.\n\nExamples\n\nThis is the output type of run_atp:\n\nresult = run_atp(\"chem\", \"simplified\", WindAzimuth(2., 90.), ReleaseLocations([4., 50.]))\n\n# output\nAtp45Result with 2 zones and properties:\nDict{Symbol, Any} with 3 entries:\n  :locations  => ReleaseLocations{1, Float64}(((4.0, 50.0),))\n  :categories => (ChemicalWeapon(), Simplified())\n  :weather    => (WindAzimuth(2.0, 90.0),)\n\nSpecific zones can be access with the get_zones function:\n\nget_zones(result, \"release\")\n\n# output\n1-element Vector{ATP45.AbstractZoneFeature}:\n ReleaseZone{100, Float64}(ATP45.CircleLikeZone{100, Float64}(ReleaseLocations{1, Float64}(((4.0, 50.0),)), 2000.0))\n\n\n\n\n\n","category":"type"},{"location":"#ATP45.map_ids","page":"Home","title":"ATP45.map_ids","text":"map_ids()\n\nDictionnary mapping the existing id's to the ATP45.jl categories.\n\nExamples:\n\njulia> ATP45.map_ids()\nDict{String, Any} with 29 entries:\n  \"MPL\"             => MissilesPayload()\n  \"MSL\"             => Missile()\n  \"chem\"            => ChemicalWeapon()\n  \"typeC\"           => ReleaseTypeC()\n  \"MNE\"             => Mine()\n  ⋮                 => ⋮\n\n\n\n\n\n","category":"function"},{"location":"internals/","page":"Internals","title":"Internals","text":"","category":"page"},{"location":"internals/","page":"Internals","title":"Internals","text":"Modules = [ATP45]","category":"page"},{"location":"internals/#ATP45.AbstractModel","page":"Internals","title":"ATP45.AbstractModel","text":"AbstractModel\n\nDetermine the type of APT-45 that will be run (simplified or detailed).\n\n\n\n\n\n","category":"type"},{"location":"internals/#ATP45.AbstractReleaseType","page":"Internals","title":"ATP45.AbstractReleaseType","text":"AbstractReleaseType <: AbstractCategory\n\nDiscriminate between the release type (ex: Air Contaminating Attack, Ground Contaminating Attacks)\n\n\n\n\n\n","category":"type"},{"location":"internals/#ATP45.AbstractWeapon","page":"Internals","title":"ATP45.AbstractWeapon","text":"AbstractWeapon <: AbstractCategory\n\nDiscriminate between the type of weapon (Chemical, Biological, Radiological, Nuclear)\n\n\n\n\n\n","category":"type"},{"location":"internals/#ATP45.AbstractZoneFeature","page":"Internals","title":"ATP45.AbstractZoneFeature","text":"AbstractZoneFeature{N, T}\n\nAn ATP-45 Zone{N, T} with some properties related to it (typically the type of zone, e.g. release or hazard). It implements the GeoInterface.Feature trait.\n\n\n\n\n\n","category":"type"},{"location":"internals/#ATP45.Zone","page":"Internals","title":"ATP45.Zone","text":"Zone{N, T} <: AbstractZone{N, T}\n\nDefines a closed polygon with N vertices for representing a ATP-45 zone. It implements the GeoInterface.Polygon trait.\n\n\n\n\n\n","category":"type"},{"location":"internals/#ATP45.ZoneBoundary","page":"Internals","title":"ATP45.ZoneBoundary","text":"ZoneBoundary{N, T}\n\nRepresents the border for a ATP45 zone. N is the number of vertices defining the zone. It implements the GeoInterface.LinearRing trait.\n\nExamples\n\n# We create a triangle like border (3 vertices):\njulia> coords = [\n    [6., 49.],\n    [5., 50.],\n    [4., 49.],\n]\njulia> ZoneBoundary(coords)\nZoneBoundary{3, Float64}(((6.0, 49.0), (5.0, 50.0), (4.0, 49.0)))\n\n\n\n\n\n","category":"type"},{"location":"internals/#ATP45.circle_coordinates-Tuple{Number, Number, Number}","page":"Internals","title":"ATP45.circle_coordinates","text":"circle_coordinates(lon::Number, lat::Number, radius::Number, res)\n\nCalculate the coordinates of a circle like zone given the center (lon, lat) and the radius in meters. res is the number of points on the circle.\n\n\n\n\n\n","category":"method"},{"location":"internals/#ATP45.descend-Tuple{ATP45.TreeNode, Any}","page":"Internals","title":"ATP45.descend","text":"descend(node::TreeNode, model_params) :: TreeNode\n\nDiscriminate between the children of node according to the parameters in model_params.\n\nExamples\n\njulia> ex = Simplified => [\n               ChemicalWeapon => [\n                   LowerThan10 => (:_circle_circle, 2_000, 10_000),\n                   HigherThan10 => (:_circle_triangle, 2_000, 10_000),\n               ],\n               BiologicalWeapon => [\n                   LowerThan10 => (:_circle_circle, 1_000, 10_000),\n                   HigherThan10 => (:_circle_triangle, 1_000, 10_000),\n               ],\n           ]\njulia> model_params = (BiologicalWeapon(),)\njulia> descend(TreeNode(ex), model_params)\nBiologicalWeapon()\n├─ LowerThan10()\n│  └─ (:_circle_circle, 1000, 10000)\n└─ HigherThan10()\n   └─ (:_circle_triangle, 1000, 10000)\n\n\n\n\n\n","category":"method"},{"location":"internals/#ATP45.descendall-Tuple{ATP45.TreeNode, Any}","page":"Internals","title":"ATP45.descendall","text":"descendall(node::TreeNode, model_params) :: TreeNode{<:Tuple}\n\nBrowse the tree starting at node, choosing the path following what is specified in model_params.\n\nExamples\n\njulia> ex = Simplified => [\n               ChemicalWeapon => [\n                   LowerThan10 => (:_circle_circle, 2_000, 10_000),\n                   HigherThan10 => (:_circle_triangle, 2_000, 10_000),\n               ],\n               BiologicalWeapon => [\n                   LowerThan10 => (:_circle_circle, 1_000, 10_000),\n                   HigherThan10 => (:_circle_triangle, 1_000, 10_000),\n               ],\n           ]\njulia> model_params = (BiologicalWeapon(), WindAzimuth(45, 2))\njulia> descendall(TreeNode(ex), model_params)\n(:_circle_triangle, 1000, 10000)\n\n\n\n\n\n","category":"method"},{"location":"internals/#ATP45.get_zones-Tuple{ATP45.Atp45Result, String}","page":"Internals","title":"ATP45.get_zones","text":"get_zones(result::Atp45Result, type::String)\n\nGet the zones in the ATP45Result result from reading the type propertie of the zones. See [ATP45.Atp45Result]\n\n\n\n\n\n","category":"method"},{"location":"internals/#ATP45.horizontal_walk-Union{Tuple{T}, Tuple{Vector{T}, T, T}} where T<:Number","page":"Internals","title":"ATP45.horizontal_walk","text":"horizontal_walk(lon::AbstractFloat, lat::AbstractFloat, distance::AbstractFloat, azimuth::AbstractFloat)\n\nCompute the end location given a starting location lon and lat in degrees, a distance distance in meters and an azimuth azimuth in degrees (the reference direction is North)\n\n\n\n\n\n","category":"method"},{"location":"internals/#ATP45.map_ids-Tuple{}","page":"Internals","title":"ATP45.map_ids","text":"map_ids()\n\nDictionnary mapping the existing id's to the ATP45.jl categories.\n\nExamples:\n\njulia> ATP45.map_ids()\nDict{String, Any} with 29 entries:\n  \"MPL\"             => MissilesPayload()\n  \"MSL\"             => Missile()\n  \"chem\"            => ChemicalWeapon()\n  \"typeC\"           => ReleaseTypeC()\n  \"MNE\"             => Mine()\n  ⋮                 => ⋮\n\n\n\n\n\n","category":"method"},{"location":"internals/#ATP45.properties-Tuple{Any}","page":"Internals","title":"ATP45.properties","text":"properties(iid::String)\nproperties(obj)\n\nGive the properties defined on the ATP45 object, given the object itsels obj or its id iid.\n\nExamples\n\njulia> ATP45.properties(ChemicalWeapon())\n4-element Vector{Pair{Symbol, String}}:\n           :id => \"chem\"\n     :longname => \"Chemical\"\n    :paramtype => \"category\"\n :internalname => \"ChemicalWeapon\"\n\n\n\n\n\n","category":"method"},{"location":"internals/#ATP45.run_atp-Tuple{Tuple}","page":"Internals","title":"ATP45.run_atp","text":"run_atp(args...)\n\nHigh level function to run the ATP-45 procedure. The arguments args can be pretty flexible. They can be expressed as :\n\ncategories and input types from ATP45.jl\n\nlocations = ReleaseLocationss([4., 50.])\nwind = WindAzimuth(2.5, 45.)\nrun_atp(Simplified(), ChemicalWeapon(), locations, wind)\n\nstring corresponding to the categories' id's. See map_ids to know the id's of the existing categories:\n\nrun_atp(\"simplified\", \"chem\", locations, wind)\n\na combination of both:\n\nrun_atp(Simplified(), \"chem\", locations, wind)\n\n\n\n\n\n","category":"method"},{"location":"internals/#ATP45.triangle_coordinates-NTuple{5, Any}","page":"Internals","title":"ATP45.triangle_coordinates","text":"triangle_coordinates(lon, lat, azimuth, dhd, back_distance)\n\nCalculate the coordinates of the triangle like zone given the release location, the wind direction azimuth, the downwind hazard distance dhd in meters.\n\n\n\n\n\n","category":"method"}]
}
