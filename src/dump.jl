function json_merged(tape)
    return JSON.json(tape)
end

function dump_merged(tape, filename)
    open(filename, "w") do f
        JSON.print(f, tape)
     end
end
