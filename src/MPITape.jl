module MPITape

using MPI
using Cassette
using MacroTools
using Printf
using Serialization
using DocStringExtensions
using JSON

Cassette.@context MPITapeCtx

include("utils.jl")
include("distributedevent.jl")
include("api.jl")
include("mpifuncs_overdubbing.jl")
include("printing.jl")
include("fileio.jl")
include("communication_graph.jl")
include("plotting.jl")
include("dump.jl")

const TIME_START = Ref(0.0)
const TAPE = DistributedEvent[]
const MYRANK = Ref(-1)
const GLOBAL_COMM_SIZE = Ref(-1)

export @record

end
