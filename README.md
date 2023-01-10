# ATP45

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tcarion.github.io/ATP45.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tcarion.github.io/ATP45.jl/dev/)
[![Build Status](https://github.com/tcarion/ATP45.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/tcarion/ATP45.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/tcarion/ATP45.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/tcarion/ATP45.jl)

ATP45.jl provides a flexible API to run the NATO ATP-45 impact assessment model for CBRN-type incidents.

The results of the model implement the [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl) interface so it can easily interoperate with other geospatial softwares.

## Installation:
The package is not registered, so you need to install it with:
```julia
using Pkg; Pkg.add(url="https://github.com/tcarion/ATP45.jl")
```
## Example:
The following snippet runs the simplified version of ATP-45 for a chemical incident and some release and weather conditions and plots the results:

```julia
using ATP45
simple_chem = Simplified(ChemicalWeapon())
release = ReleaseLocation([4., 50.])
wind = WindDirection(5., 45.)
result = simple_chem(release, wind)
plot(result)
```

![Simplified procedure for chemical release](https://tcarion.github.io/ATP45.jl/dev/example.png)

## Documentation:
Please see the [Documentation](https://tcarion.github.io/ATP45.jl/dev/) for more detailed examples and description of the package features.

## Caveat:
Every ATP-45 have not been implemented yet. You might get an error if you try to run cases that are currently missing.
