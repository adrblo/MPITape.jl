include("mpifix.jl")
using MPITape
using MPI
using Test

MPI.Init()
rank = MPI.Comm_rank(MPI.COMM_WORLD)

function basic_communication()
    MPI.Init()
    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    com_size = MPI.Comm_size(comm)
    msg = rand(10)
    if rank != 0
        MPI.Send(msg, comm; dest = 0)
    else
        for r in 1:(com_size - 1)
            MPI.Recv!(msg, comm; source = r)
        end
    end
    MPI.Barrier(comm)
end

@test isnothing(@record basic_communication())
@test isnothing(MPITape.print_mytape())
tape_merged = MPITape.merge()
if rank == 0 # Master
    @test typeof(tape_merged) == Vector{MPITape.MPIEvent}
    @test isnothing(MPITape.print_merged(tape_merged))
else
    @test isnothing(tape_merged)
end