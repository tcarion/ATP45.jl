```@meta
CurrentModule = ATP45
```

# ATP45

[ATP45](https://github.com/tcarion/ATP45.jl) implements the NATO ATP-45 impact assesment model for CBRN-type incidents.

# Getting started

The package provides a simple and flexible API to run the proper ATP-45 case, according to the parameters and inputs provided by the user.
For example, setting up the simplified ATP-45 model in case of chemical weapons goes like this:
```@example simple
using ATP45
simple_chem = Simplified(ChemicalWeapon()) 
```


# Documentation
```@docs
run_atp
```
