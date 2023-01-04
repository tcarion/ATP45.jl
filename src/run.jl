function (procedure::Simplified)(inputs...)
    inputs = cast_id.(inputs)
    run(_group_parameters(procedure, inputs))
end

function (procedure::Detailed)(inputs...)
    inputs = cast_id.(inputs)
    run(_group_parameters(procedure, inputs))
end

function run(model_parameters)
    model_parameters = cast_id.(model_parameters)
    leave = descendall(ATP45_TREE, model_parameters)
    nodeval = nodevalue(leave)
    method, args = nodeval.fname, nodeval.args
    geometry = eval(method)(model_parameters, args...)
    Atp45Result(geometry |> collect, Dict("tobe" => "designed"))
end