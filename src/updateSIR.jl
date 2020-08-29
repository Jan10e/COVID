function updateSIR(population)
    S = population[1]
    I = population[2]
    R = population[3]

    S_new = S - λ * S * I * dt
    I_new = I + λ * S * I * dt - γ * I * dt
    R_new = R + γ * I * dt

    return [S_new I_new R_new]
end
