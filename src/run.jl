function (procedure::AbstractModel)(inputs...)
    inputs = cast_id.(inputs)
    run_atp(_group_parameters(procedure, inputs)...)
end

"""
    run_atp(args...)
High level function to run the ATP-45 procedure. The arguments `args` can be pretty flexible. They can be expressed as
:

- categories and input types from `ATP45.jl`
```julia
locations = ReleaseLocationss([4., 50.])
wind = WindAzimuth(2.5, 45.)
run_atp(Simplified(), ChemicalWeapon(), locations, wind)
```

- string corresponding to the categories' id's. See [`map_ids`](@ref ATP45.map_ids) to know the id's of the existing categories:
```julia
run_atp("simplified", "chem", locations, wind)
```

- a combination of both:
```julia
run_atp(Simplified(), "chem", locations, wind)
```
"""
function run_atp(model_parameters::Tuple)
    model_parameters = cast_id.(model_parameters)
    leave = descendall(ATP45_TREE, model_parameters)
    nodeval = nodevalue(leave)
    method, args = nodeval.fname, nodeval.args
    geometry = eval(method)(model_parameters, args...)
    props = Dict(
        :locations => get_location(model_parameters),
        :weather => filter_paramtype(model_parameters, Meteo()),
        :categories => (filter_paramtype(model_parameters, Category())..., filter_paramtype(model_parameters, Group())...),
    )
    Atp45Result(geometry |> collect, props)
end
run_atp(args...) = run_atp(Tuple(args))