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

# @recipe function f(zoneb::ZoneBoundary)
#     gcoords = GI.coordinates(zoneb)
#     @series begin
#         seriestype := :line
#         Tuple.(gcoords)
#     end
# end

@recipe function f(zone::AbstractZone)
    coordinates = _format_coords(GI.coordinates(zone)[1])
    @series begin
        seriestype := :path
        coordinates[:, 1], coordinates[:, 2]
    end
end

@recipe function f(feat::AbstractZoneFeature)
    props = properties(feat)
    @series begin
        seriestype := :path
        label := get(props, :type, "")
        GI.geometry(feat)
    end
end

@recipe function f(collection::Atp45Result)
    for feat in zonecollection(collection)
        @series begin
            feat
        end
    end
end

_format_coords(coordinates) = permutedims(reshape(vcat((collect.(collect(coordinates)))...), (2, length(coordinates))))
