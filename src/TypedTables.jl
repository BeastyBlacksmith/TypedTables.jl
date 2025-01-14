module TypedTables

using Unicode
using Tables
using SplitApplyCombine
import Adapt
using Dictionaries
using Indexing
using RecipesBase

using Base: @propagate_inbounds, @pure, OneTo, Fix2
import Tables.columns, Tables.rows

export @Compute, @Select, getproperties, deleteproperty, deleteproperties
export Table, FlexTable, DictTable, columns, rows, columnnames, showtable

# Resultant element type of given column arrays
@generated function _eltypes(a::NamedTuple{names, T}) where {names, T <: Tuple}
    Ts = []
    for V in T.parameters
        push!(Ts, eltype(V))
    end
    return NamedTuple{names, Tuple{Ts...}}
end

_ndims(::NamedTuple{<:Any, T}) where {T} = _ndims(T)
_ndims(::Type{<:Tuple{Vararg{AbstractArray{<:Any, n}}}}) where {n} = n

# The following code causes newer versions of Julia to hang in precompilation
# and the workaround should not be needed after JuliaLang/julia#30577 was
# merged.
if VERSION < v"1.2.0-DEV.291"
    # Workaround for JuliaLang/julia#29970
    let
        for n in 1:32
            Ts = [Symbol("T$i") for i in 1:n]
            xs = [:(x[$i]) for i in 1:n]
            NT = :(Core.NamedTuple{names, Tuple{$(Ts...)}})
            eval(quote
                $NT(x::Tuple{$(Ts...)}) where {names, $(Ts...)} = $(Expr(:new, NT, xs...))
            end)
        end
    end
end

# Apparently by default this is slower than necessary because we go through generic introspection.
# TODO - we should probably make a PR for Base.
Base.propertynames(::NamedTuple{names}) where {names} = names

include("properties.jl")
include("Table.jl")
include("FlexTable.jl")
include("DictTable.jl")
include("columnops.jl")
include("show.jl")
include("plot.jl")

end # module
