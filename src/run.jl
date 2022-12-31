function (procedure::Simplified{T})(inputs...) where T
    inputs = cast_id.(inputs)
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    
    run(_group_parameters(procedure, inputs))
end

function (procedure::Detailed{T})(inputs...) where T
    inputs = cast_id.(inputs)
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    run(_group_parameters(procedure, inputs))
end

function run(model_parameters)
    model_parameters = cast_id.(model_parameters)
    leave = descendall(ATP45_TREE, model_parameters)
    nodeval = nodevalue(leave)
    nodeval isa Tuple{<:Nothing} && error("This case has not been implemented yet.")
    method, args... = nodeval
    geometry = eval(method)(model_parameters, args...)
    Atp45Result(geometry |> collect, Dict("tobe" => "designed"))
end