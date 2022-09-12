@recipe function f(w::ATP45.AbstractWind; x_origin = 0., y_origin = 0., w_scale = 1.)
    wc = convert(WindCoords, w)
    coords = w_scale .* [wc.u, wc.v]
    seriestype --> :quiver
    quiver --> ([coords[1]], [coords[2]])
    [x_origin], [y_origin]
end

@userplot ResultPlot

@recipe function f(h::ResultPlot)
    result = first(h.args)
    coll = result.collection
    for coll in result.collection
        coords = GeoJSON.coordinates(coll)[1]
        tuple = Tuple.(push!(copy(coords), coords[1]))
        @series begin
            tuple
        end
    end

    for loc in result.input.locations
        @series begin
            color := :red
            seriestype := :scatter
            [Tuple(loc)]
        end
    end
end
