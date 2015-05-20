module BorgC

const borglib = joinpath(normpath(joinpath(dirname(Base.source_path()), "..", "deps", "usr", "lib")),"borg")

typealias BORG_Problem Ptr{Void}
typealias BORG_Archive Ptr{Void}

function BORG_Problem_create(numberOfVariables::Int, numberOfObjectives::Int, numberOfConstraints::Int, fn::Function, userParams)
    c_fn = cfunction(fn, Void, (Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{Void}))

    ret = ccall(
        (:BORG_Problem_create, borglib),
        BORG_Problem,
        (Int32, Int32, Int32, Ptr{Void}, Any),
        numberOfVariables, numberOfObjectives, numberOfConstraints, c_fn, userParams)
    return ret
end

function BORG_Problem_set_bounds(problem::BORG_Problem, index::Int, lowerBound::Float64, upperBound::Float64)
    ccall(
        (:BORG_Problem_set_bounds, borglib),
        Void,
        (BORG_Problem, Int32, Float64, Float64),
        problem, index-1, lowerBound, upperBound)
end

function BORG_Problem_set_epsilon(problem::BORG_Problem, index::Int, epsilon::Float64)
    ccall(
        (:BORG_Problem_set_epsilon, "borg"),
        Void,
        (BORG_Problem, Int32, Float64),
        problem, index-1, epsilon)
end

function BORG_Algorithm_run(problem::BORG_Problem,maxEvaluations::Int)
    ret = ccall(
        (:BORG_Algorithm_run, "borg"),
        BORG_Archive,
        (BORG_Problem, Int32),
        problem, maxEvaluations)
    return ret
end

function BORG_Archive_print(archive::BORG_Archive, fp)
    ccall(
        (:BORG_Archive_print, "borg"),
        Void,
        (BORG_Archive, Ptr{Void}),
        archive, C_NULL)
end

end # module
