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
locations = ReleaseLocations([4., 50.])
wind = WindDirection(2.5, 45.)
run_atp(Simplified(), ChemicalWeapon(), locations, wind)
```

- string corresponding to the categories' id's. See [`ATP45.map_ids`](@ref) to know the id's of the existing categories:
```julia
run_atp("simplified", "chem", locations, wind)
```

- a combination of both:
```julia
run_atp(Simplified(), "chem", locations, wind)
```

The results can be easily plotted using `Plots`.
```jldoctest; filter = r"example.png"
using ATP45, Plots
locations = ReleaseLocation([4., 50.])
wind = WindDirection(5., 45.)
result = run_atp("simplified", "chem", locations, wind)
r = plot(result)
savefig(r, "build/simple_example.png");
# output
```

![simple example](simple_example.png)
"""
function run_atp(model_parameters::Tuple)
    model_parameters = cast_id.(model_parameters)
    leave = descendall(ATP45_TREE, model_parameters)
    nodeval = nodevalue(leave)
    method, args = nodeval.fname, nodeval.args
    geometry = eval(method)(model_parameters, args...)
    Atp45Result(geometry |> collect, Dict("tobe" => "designed"))
end
run_atp(args...) = run_atp(Tuple(args))