struct MissingInputsException <: Exception 
    inputs::Vector{<:Any}
end

function Base.showerror(io::IO, e::MissingInputsException)
    println(io, "Some inputs are missing:")
    for input in e.inputs
        println(io, "\t $(missing_message(input))")
    end
end

required_inputs(o::T) where T = required_inputs(T) 
required_inputs(::Type{Simplified}) = (AbstractReleaseLocation{1, <:Number}, AbstractWind)


missing_message(::Type{AbstractReleaseLocation{N, <:Number}}) where N = "The model requires $N release(s) location(s)."
missing_message(::Type{AbstractWind}) = "The model requires the wind speed and direction."
# missing_message(::Type{AbstractReleaseLocation{N, <:Number}}) = "The model requires 2 release"
# function (procedure::T)(args::Int) where {T <: AbstractProcedure}
#     println(args)
# end

function (procedure::Simplified)(inputs...)
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    println(inputs)
end

function missing_inputs(procedure::AbstractProcedure, inputs...)::Vector{Any}
    requireds = required_inputs(procedure)
    missing_in = []
    # inputs_supertypes = supertype.(typeof.(inputs))
    # inputs_type = typeof.(inputs)
    for required in requireds
        is_require_in_input = any(isa.(inputs, Ref(required)))
        if !is_require_in_input
            push!(missing_in, required)
        end
    end
    missing_in
end