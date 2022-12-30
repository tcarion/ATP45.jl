using Test
using ATP45
import ATP45: Simplified, Detailed
import ATP45: ChemicalWeapon, BiologicalWeapon, RadiologicalWeapon, NuclearWeapon
import ATP45: ReleaseTypeA, ReleaseTypeB, ReleaseTypeC
import ATP45: Shell
import ATP45: WindDirection, ReleaseLocation
import ATP45: Unstable, Stable
import ATP45: _group_parameters

@testset "Models" begin
    @testset "group" begin
        simple = Simplified(ChemicalWeapon())
        inputs = (WindDirection(5., 45), ReleaseLocation([4., 50.]))
        grouped = _group_parameters(simple, inputs)
        comp = [simple, simple.categories..., inputs...]
        b = map(enumerate(grouped)) do (i, g) 
            g == comp[i]
        end
        @test all(b)
    end
end