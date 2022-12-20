@recipe function f(w::AbstractWind; w_origin = [0., 0.], w_scale = 1., w_normalize = false)
    wc = convert(WindVector, w)
    coords = [wc.u, wc.v]
    if w_normalize
        coords = coords ./ sqrt(sum(coords.^2))
    end
    coords = w_scale .* coords
    seriestype --> :quiver
    quiver --> ([coords[1]], [coords[2]])
    [w_origin[1]], [w_origin[2]]
end

@recipe function f(ps::ReleaseLocation)
    @series begin
        seriestype := :scatter
        collect(GI.coordinates(ps))
    end
end

@recipe function f(zoneb::ZoneBoundary)
    gcoords = GI.coordinates(zoneb)
    @series begin
        seriestype := :line
        Tuple.(gcoords)
    end
end

@recipe function f(zone::Zone)
    gcoords = GI.coordinates(zone)
    # tuple = Tuple.(gcoords[1])
    # tuple = tuple[1] !== tuple[end] ? vcat(tuple..., tuple[1]) : tuple
    # println(tuple)
    @series begin
        seriestype := :line
        gcoords
    end
end

@recipe function f(feat::AbstractZoneFeature)
    props = properties(feat)
    @series begin
        seriestype := :line
        label := get(props, "type", "")
        geometry(feat)
    end
end

@userplot ResultPlot

@recipe function f(h::ResultPlot)
    result = first(h.args)
    coll = result.collection
    legend --> false
    for coll in result.collection
        coords = GI.coordinates(coll)[1]
        # tuple = Tuple.(push!(copy(coords), coords[1]))
        tuple = Tuple.(coords)
        @series begin
            label := GI.properties(coll)["type"] * " area"
            tuple
        end
    end

    # for loc in result.input.locations
    #     @series begin
    #         color := :red
    #         seriestype := :scatter
    #         label := "release point"
    #         [Tuple(loc)]
    #     end
    # end
end