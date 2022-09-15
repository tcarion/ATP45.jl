@recipe function f(w::ATP45.AbstractWind; w_origin = [0., 0.], w_scale = 1., w_normalize = false)
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

@userplot ResultPlot

@recipe function f(h::ResultPlot)
    result = first(h.args)
    coll = result.collection
    legend --> false
    for coll in result.collection
        coords = GeoJSON.coordinates(coll)[1]
        tuple = Tuple.(push!(copy(coords), coords[1]))
        @series begin
            label := GeoJSON.properties(coll)["type"] * " area"
            tuple
        end
    end

    for loc in result.input.locations
        @series begin
            color := :red
            seriestype := :scatter
            label := "release point"
            [Tuple(loc)]
        end
    end
end