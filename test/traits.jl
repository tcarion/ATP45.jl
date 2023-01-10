using ATP45
import ATP45: id, description, paramtype, content, ParamType
import ATP45: map_ids
using ATP45: Category, Group
using ATP45: add_ids_to_map!, cast_id, byid, filter_paramtype
using Test

@testset "methods on new type" begin
    abstract type Abstract end 
    struct Foo <: Abstract end
    struct Bar
        name
        content
    end
    ATP45.description(::Type{Foo}) = "bar"
    @test description(Foo()) == "bar"
    
    ATP45.id(::Type{Foo}) = "foo"

    ATP45.ParamType(::Type{Foo}) = Category()
    @test paramtype(Foo()) == "category"

    ATP45.ParamType(::Type{Bar}) = Group()
    bar = Bar(:Bar, [Foo(), Foo()])
    ATP45.id(bar::Bar) = string(bar.name)
    @test id(bar) == "Bar"
    @test content(bar) == ["foo", "foo"]

    @testset "add ids and filter" begin
        add_ids_to_map!(Abstract)
        @test byid("foo") == Foo()
        @test_throws ErrorException byid("bar")

        @test cast_id("foo") == Foo()
        @test cast_id(Foo()) == Foo()

        @test filter_paramtype([Foo(), bar], Category()) == [Foo()]
    end
end