```@meta
CurrentModule = ATP45
```

# ATP45

[ATP45](https://github.com/tcarion/ATP45.jl) implements the NATO ATP-45 impact assessment model for CBRN-type incidents.

# Getting started

```@setup generate_readme
using ATP45
using Plots
detailed_chem = (ChemicalAgent(), ChemicalWeapon(), Detailed(), ReleaseTypeB(), "SPR")
releases = ReleaseLocations([4., 50.], [4.15, 50.03])
wind = WindAzimuth(2., 45.)
result = run_atp(detailed_chem..., releases, wind)
plot(result)
savefig("example.png")
```
### Run ATP-45:
The package provides a simple and flexible API to run the proper ATP-45 case, according to the parameters and inputs provided by the user.
Setting up the simplified ATP-45 model in case of chemical agents goes like this:
```@example getstarted
using ATP45
simple_chem = (ChemicalAgent(), ChemicalWeapon(), Simplified()) 
```

After defining the desired categories of ATP-45, we define the location of the release at longitude 4.0 and latitude 50.0, as well as a wind of speed 5.0 m/s and pointing 45° from North:
```@example getstarted
release = ReleaseLocations([4., 50.]);
wind = WindAzimuth(5., 45.);
nothing # hide
```
We finally pass these as arguments to the [`run_atp`](@ref run_atp) function. This function takes as arguments an arbitrary number of categories and inputs, so the splat operator (`...`) needs to be used on the `simple_chem` tuple. 
```@example getstarted
result = run_atp(simple_chem..., release, wind)
```

The result can be easily plotted with [Plots.jl](https://github.com/JuliaPlots/Plots.jl):
```@example getstarted
using Plots
plot(result)
savefig("simplified_example.png"); nothing # hide
```

![](simplified_example.png)


We can also use the string id's corresponding to the categories instead of the Julia objects:
```@example getstarted
using ATP45
run_atp("detailed", "chem", "chem_weapon", "typeA", ATP45.Shell(), "stable", wind, release)
```

The id's and their corresponding objects can be seen with [`ATP45.map_ids`](@ref ATP45.map_ids):
```@example getstarted
ATP45.map_ids()
```

We can have more details about each categories defined in ATP-45 with the [`ATP45.properties`](@ref ATP45.map_ids) method:
```@example getstarted
ATP45.properties("typeA")
```

If some categories or some inputs are missing, you should get an explanatory error about what's missing:
```@repl getstarted
run_atp("detailed", "chem", "chem_weapon", "typeA", ATP45.Shell(), wind, release)
```

```
```

### Implementation of [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl)
The `Atp45Result` type implements the [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl) interface, which means that the coordinates of the ATP-45 zones can be accessed with the `GeoInterface.jl` methods:
```@example getstarted
using GeoInterface
result = run_atp("chem", "chem_weapon", "simplified", wind, release)
GeoInterface.coordinates(result)
```

It also means that the result can be easily converted to GeoJSON:
```@example getstarted
using GeoJSON
GeoJSON.write(result)
```

# Documentation
```@docs
run_atp
ReleaseLocations
WindAzimuth
WindVector
Atp45Result
ATP45.map_ids
```
