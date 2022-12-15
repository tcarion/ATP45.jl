struct Simplified <: AbstractModel end
# id(::Type{Simplified}) = "simplified"
# longname(::Type{Simplified}) = "Simplified procedure"
description(::Type{Simplified}) = "The simplified procedure is primarily used for immediate warning. As soon as possible the detailed procedures must be carried out. A typical situation where simplified procedures will be used is when the substance type and persistency are not known."

struct Detailed <: AbstractModel end
# id(::Type{Simplified}) = "detailed"
# longname(::Type{Simplified}) = "Detailed procedure"

required_inputs(::Type{Simplified}) = (AbstractWeapon, AbstractReleaseLocation{1, <:Number}, AbstractWind)

function (procedure::Simplified)(inputs...)
    mismes = missing_inputs(procedure, inputs...)
    isempty(mismes) || throw(MissingInputsException(mismes)) 

    println(inputs)
end