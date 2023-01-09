function (procedure::AbstractModel)(inputs...)
    inputs = cast_id.(inputs)
    run_atp(_group_parameters(procedure, inputs)...)
end

"""
    run_atp(model_parameters)

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