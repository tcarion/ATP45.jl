struct SphereC{T}
    phi::T
    theta::T
end

struct CartC{T}
    x::T
    y::T
    z::T
end

struct StereoC{T}
    x::T
    y::T
end

"""
    CartC(phi, theta)

Convert spherical coordinates (`phi`, `theta`) to cartesian coordinates. 

# Examples
```julia-repl
julia> sphere_to_cart(0, 0)
CartC{Float64}(6.371e6, 0.0, 0.0)
```
See also: [`CartC(coord::SphereC)`](@ref)
"""
function CartC(phi, theta)
    CartC(
        EARTH_RADIUS * cos(phi) * cos(theta),
        EARTH_RADIUS * sin(phi) * cos(theta),
        EARTH_RADIUS * sin(theta)
    )
end
CartC(coord::SphereC) = CartC(coord.phi, coord.theta)

"""
    StereoC(x, y, z)

Convert cartesian coordinates (`x`, `y`, `z`) to 2D stereographical coordinates. 

See also: [`StereoC(coord::CartC)`](@ref), `sphere_to_stereo(coord::SphereC)`](@ref)
"""
function StereoC(x, y, z)
    den = EARTH_RADIUS - z
    StereoC(
        EARTH_RADIUS * x / den,
        EARTH_RADIUS * y / den
    )
end
StereoC(coord::CartC) = StereoC(coord.x, coord.y, coord.z)
StereoC(coord::SphereC) = StereoC(CartC(coord))

"""
    earth_coord(n::Int = 20)

Return the (`x`, `y`, `z`) cartesian coordinate of the spherical earth with `n` points for meridional and parallel directions.

"""
function earth_coord(n::Int = 20)
    phi = range(0, stop=2*π, length=n)
    theta = range(-π/2, stop=π/2, length=n)

    x = EARTH_RADIUS * cos.(phi) .* cos.(theta)'
    y = EARTH_RADIUS * sin.(phi) .* cos.(theta)'
    z = EARTH_RADIUS * ones(n) * sin.(theta)'

    return (x, y, z)
end

"""
    poly_bilinear_interp(X::Vector{T}, Y::Vector{T}, values::Vector{T}) where T <: Real

Compute the coefficients for a bilinear polynomial interpolation

# Arguments
- `X::Vector{T}` and `Y::Vector{T}` : the 4 coordinates
- `values::Vector{T}` : the values at each coordinate

See also : [`poly_bilinear_interp(c::StereoC, values)`](@ref), [`poly_bilinear_interp(c::SphereC, values)`](@ref)
"""
function poly_bilinear_interp(X::Vector{T}, Y::Vector{T}, values::Vector{T}) where T <: Real
    A = [X[i]^(j%2) * Y[i]^(j÷2) for i in 1:4, j in 0:3]
    return A\values
end
poly_bilinear_interp(c::StereoC, values) = poly_bilinear_interp(c.x, c.y, values)
function poly_bilinear_interp(c::SphereC, values) 
    sph = sphere_to_stereo(c)
    poly_bilinear_interp(sph.x, sph.y, values)
end

"""
evaluate_interp(c::StereoC, coefs)

Evalute the bilinear polynomial with coefficients `coefs` at point `c`

See also : [`evaluate_interp(c::SphereC, coefs)`](@ref), [`evaluate_interp(phi, theta, coefs)`](@ref)
"""
function evaluate_interp(c::StereoC, coefs)
    sum([1, c.x, c.y, c.x*c.y] .* coefs)
end
evaluate_interp(c::SphereC, coefs) = evaluate_interp(sphere_to_stereo(c), coefs)
evaluate_interp(phi, theta, coefs) = evaluate_interp(SphereC(phi, theta), coefs)

"""
GC_distance(c1::SphereC, c2::SphereC)

Compute the great circle distance between points `c1` and `c2`

See also : [`GC_distance(phi1, theta1, phi2, theta2)`](@ref)
"""
function GC_distance(c1::SphereC, c2::SphereC)
    return 2 * EARTH_RADIUS * asin.(sqrt.(sin.((c2.theta .- c1.theta) / 2).^2 
        + cos.(c1.theta) * cos.(c2.theta) * sin.((c2.phi - c1.phi)/2).^2))
end
GC_distance(phi1, theta1, phi2, theta2) = GC_distance(SphereC(phi1, theta1), SphereC(phi2, theta2))
