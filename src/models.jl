struct Simplified <: AbstractModel end
# id(::Type{Simplified}) = "simplified"
# longname(::Type{Simplified}) = "Simplified procedure"

struct Detailed <: AbstractModel end
# id(::Type{Simplified}) = "detailed"
# longname(::Type{Simplified}) = "Detailed procedure"

required_inputs(::Type{Simplified}) = (AbstractWeapon, AbstractReleaseLocation{1, <:Number}, AbstractWind)

function (procedure::Simplified)(inputs...)
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    println(inputs)
end