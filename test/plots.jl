using Test
using ATP45
using Plots
using ATP45: properties, geometry, GI

@testset "plot recipes" begin
    result = ATP45.run(Simplified(), ChemicalWeapon(), WindDirection(5, 45), ReleaseLocation([4., 50.]))
    p = plot(result)
end

