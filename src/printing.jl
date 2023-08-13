const COLORS = [:white, :yellow, :blue, :green, :red, :magenta, :cyan]

_timestr(time) = @sprintf("%.2E", time)

drop_mpiprefix(f::AbstractString) = replace(f, "MPI_" => "")

function _print_tape_func(::Any, DistributedEvent; showrank = false, prefix = "\t", color = :normal)
    tstr = " (Δt=" * _timestr(DistributedEvent.t_start) * ")"
    fargsstr = _fargs_str(DistributedEvent)
    fstr = rpad(drop_mpiprefix(DistributedEvent.f) * fargsstr, 20)
    rstr = showrank ? string(DistributedEvent.rank, ": ") : ""
    # println(prefix, rstr, fstr, tstr)
    printstyled(prefix, rstr, fstr, tstr, "\n"; color)
end

ispartof(rank, g::Integer) = rank == g
ispartof(rank, s::AbstractString) = s == "all"

matches(rank, g::Integer) = rank == g
matches(rank, s::AbstractString) = false

function _fargs_str(ev::Any)
    rank = ev.rank
    args = ev.args_subset
    if !isempty(args) && haskey(args, :src) && haskey(args, :dest)
        if matches(rank, args[:src])
            return " -> $(args[:dest])"
        end
        if matches(rank, args[:dest])
            return " <- $(args[:src])"
        end
        if ispartof(rank, args[:src])
            return " -> $(args[:dest])"
        end
        if ispartof(rank, args[:dest])
            return " <- $(args[:src])"
        end
        # src != rank && dest != rank
        return ", $(args[:src]) -> $(args[:dest])"
    end
    return ""
end

"""
$(SIGNATURES)
Print the local tape (of the calling MPI rank).
"""
function print_mytape(; showrank = false)
    rank = getrank()
    println("Rank: ", rank)
    for DistributedEvent in unsafe_gettape()
        _print_tape_func(DistributedEvent.f, DistributedEvent; showrank)
    end
    println()
    return nothing
end

"""
$(SIGNATURES)
Prints the given tape with the assumption that it contains events from multiple MPI ranks.
Typically, the input should be the result of `MPITape.readll_and_merge()` or similar.
"""
function print_merged(tape; color = true)
    nranks = length(unique(ev.rank for ev in tape))
    printstyled("Merged Tape of ", nranks, " MPI Ranks: \n"; color = :white, bold = true)
    usecolors = color && nranks <= length(COLORS)
    for DistributedEvent in tape
        _print_tape_func(DistributedEvent.f, DistributedEvent; showrank = true,
                         color = usecolors ? COLORS[DistributedEvent.rank + 1] : :normal)
    end
    return nothing
end
