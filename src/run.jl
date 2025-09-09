"""
    run_atp(args...)
High level function to run the ATP-45 procedure. The arguments `args` can be pretty flexible. They can be expressed as
:

- categories and input types from `ATP45.jl`
```julia
locations = ReleaseLocations([4., 50.])
wind = WindAzimuth(2.5, 45.)
run_atp(Simplified(), ChemicalAgent(), ChemicalWeapon(), locations, wind)
```

- string corresponding to the categories' id's. See [`map_ids`](@ref ATP45.map_ids) to know the id's of the existing categories:
```julia
run_atp("simplified", "chem", "chem_weapon", locations, wind)
```

- a combination of both:
```julia
run_atp(Simplified(), "chem", "chem_weapon", locations, wind)
```
"""
function run_atp(model_parameters::Tuple)
    model_parameters = cast_id.(model_parameters)
    wind_params = [x for x in model_parameters if typeof(x) <: ATP45.AbstractWind]
    isempty(wind_params) && throw(MissingInputsException([ATP45.AbstractWind]))
    leave = descendall(ATP45_TREE([x for x in model_parameters if typeof(x) <: ATP45.AbstractWind][1]), model_parameters)
    nodeval = nodevalue(leave)
    method, args = nodeval.fname, nodeval.args
    geometry = eval(method)(model_parameters, args...)
    categories = (filter_paramtype(model_parameters, Category())..., filter_paramtype(model_parameters, Group())..., filter_paramtype(model_parameters, Procedure())...)
    props = Dict(
        :locations => get_location(model_parameters),
        :weather => filter_paramtype(model_parameters, Meteo()),
        :categories => categories,
    )
    Atp45Result(geometry |> collect, props)
end
run_atp(args...) = run_atp(Tuple(args))
