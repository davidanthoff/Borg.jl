using Borg

function dtlz2(vars, objs, consts)
    nvars = length(vars)
    nobjs = length(objs)
    
    k = nvars - nobjs + 1
    g = 0.0

    for i=nvars-k:nvars-1
        g += (vars[i+1] - 0.5)^2.0
    end

    for i=0:nobjs-1
        objs[i+1] = 1.0 + g
    
        for j=0:nobjs-i-1-1
            objs[i+1] *= cos(0.5*pi*vars[j+1])
        end

        if i != 0
            objs[i+1] *= sin(0.5*pi*vars[nobjs-i-1+1])
        end
    end    
end

nvars = 11
nobjs = 2

lowerBounds = ones(nvars) * 0.0
upperBounds = ones(nvars) * 1.0
epsilons = ones(nobjs) * 0.01
    
problem = createProblem(lowerBounds, upperBounds, epsilons, 0, dtlz2)

result = solve(problem, 1000000)
