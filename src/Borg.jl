module Borg

include("BorgC.jl")

export createProblem, solve

function eval_wrapper(vars_raw::Ptr{Float64}, objs_raw::Ptr{Float64}, consts_raw::Ptr{Float64}, userParams::Ptr{Void})
    problem = unsafe_pointer_to_objref(userParams)::BorgProblem

    vars = pointer_to_array(vars_raw, problem.numberOfVariables)
    objs = pointer_to_array(objs_raw, problem.numberOfObjectives)
    consts = pointer_to_array(consts_raw, problem.numberOfConstraints)

    problem.eval_fn(vars, objs, consts)

    return
end

type BorgProblem
	ref::BorgC.BORG_Problem

	numberOfVariables::Int64
	numberOfObjectives::Int64
	numberOfConstraints::Int64

	eval_fn::Function

	function BorgProblem(
            numberOfVariables::Int,
            numberOfObjectives::Int,
            numberOfConstraints::Int,
            eval_fn::Function)

		problem = new()

        problem.numberOfVariables = numberOfVariables
        problem.numberOfObjectives = numberOfObjectives
        problem.numberOfConstraints = numberOfConstraints
        problem.eval_fn = eval_fn
		problem.ref = BorgC.BORG_Problem_create(numberOfVariables, numberOfObjectives, numberOfConstraints, eval_wrapper, problem)

        return problem
	end
end

function createProblem(
    varLowerBounds::Vector{Float64},
    varUpperBounds::Vector{Float64},
    objEpsilons::Vector{Float64},
    numberOfConstraints::Int,
    eval_fn::Function)

    if length(varLowerBounds) != length(varUpperBounds)
        error("varLowerBounds and varUpperBounds must be of same length.")
    end

    numberOfVariables = length(varLowerBounds)
    numberOfObjectives = length(objEpsilons)

    problem = BorgProblem(numberOfVariables, numberOfObjectives, numberOfConstraints, eval_fn)

    for i in 1:numberOfVariables
        BorgC.BORG_Problem_set_bounds(problem.ref, i, varLowerBounds[i], varUpperBounds[i])
    end

    for i in 1:numberOfObjectives
        BorgC.BORG_Problem_set_epsilon(problem.ref, i, objEpsilons[i])
    end

    return problem
end

function solve(problem::BorgProblem, maxIt::Int)
    archive = BorgC.BORG_Algorithm_run(problem.ref, maxIt)
    return archive
end

end
