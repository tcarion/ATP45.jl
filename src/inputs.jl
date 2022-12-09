struct MissingInputsException <: Exception 
    inputs::Vector{<:Any}
end

function Base.showerror(io::IO, e::MissingInputsException)
    println(io, "Some inputs are missing:")
    for input in e.inputs
        print(io, "\t $(missing_message(input))")
        try 
            print(io, " ", missing_example(input))
        catch e
            e isa MethodError || rethrow(e)
        end
        println(io)
    end
end

"""
    AbstractModel
Determine the type of APT-45 will be run. Each model is a callable object that takes the needed inputs as arguments.

"""
abstract type AbstractModel end

required_inputs(o::T) where {T <: AbstractModel} = required_inputs(T) 


# Info messages displayed when certain input types are missing.
missing_message(::Type{AbstractReleaseLocation{N, <:Number}}) where N = "The model requires $N release(s) location(s)."
missing_example(::Type{AbstractReleaseLocation{N, <:Number}}) where N = "Example: `ReleaseLocation([4., 50.]).`"
missing_message(::Type{AbstractWind}) = "The model requires the wind speed and direction."
missing_example(::Type{AbstractWind}) = "Example: `WindDirection(11., 45.)`."
missing_message(::Type{AbstractWeapon}) = "The model requires the weapon category."
missing_example(::Type{AbstractWeapon}) = "Example: `ChemicalWeapon()`"


# function (procedure::T)(args::Int) where {T <: AbstractModel}
#     println(args)
# end

function missing_inputs(model::AbstractModel, inputs...)::Vector{Any}
    requireds = required_inputs(model)
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