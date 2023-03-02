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

# Info messages displayed when certain input types are missing.
missing_message(::Type{<:ReleaseLocations{N}}) where N = "The model requires $N release(s) location(s)."
missing_example(::Type{<:ReleaseLocations}) = "Example: `ReleaseLocations([4., 50.]).`"
missing_message(::Type{AbstractWind}) = "The model requires the wind speed and direction."
missing_example(::Type{AbstractWind}) = "Example: `WindAzimuth(11., 45.)`."
missing_message(::Type{AbstractWeapon}) = "The model requires the weapon category."
missing_example(::Type{AbstractWeapon}) = "Example: `ChemicalWeapon()`"
missing_message(cat::Type{<:AbstractCategory}) = "The model requires the category $(cat)."
missing_example(::Type{AbstractContainerType}) = "Example: `Bomblet()`"
missing_message(::Type{AbstractStability}) = "The model requires a stability class."
missing_example(::Type{AbstractStability}) = "Example: `Unstable()`"

function get_input(inputs, input_type)
    iinput = findfirst(isa.(inputs, Ref(input_type)))
    isnothing(iinput) && error("Element of type $input_type not found in $inputs")
    inputs[iinput]
end