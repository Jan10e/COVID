# Cellular Automata: 1D
# functions 
# https://www.juliabloggers.com/automata/
#
# By: Jantine Broek
##########################################################

# Create Julia structure
mutable struct CA
    rule::Int64
    cells::BitArray{1}
    colorstops::Array{Float64, 1}
    ruleset::BitArray{1}
    generation::Int64
    function CA(rule, ncells = 100)
        cells                    = falses(ncells)
        colorstops               = zeros(Float64, ncells)
        ruleset                  = binary_to_array(rule)
        cells[length(cells) ÷ 2] = true
        generation               = 1
        new(rule, cells, colorstops, ruleset, generation)
    end
end


# converts a binary number to a bit array
function binary_to_array(n)
    a = BitArray{1}()
    for c in 7:-1:0
        k = n >> c
        push!(a, (k & 1 == 1 ? true : false))
    end
    return a
end


# takes the values of an individual and its neighbours
# and applies the rule that determines its state for the next generation
function rules(ca::CA, a, b, c)
    lng = length(ca.ruleset)
    return ca.ruleset[mod1(lng - (4a + 2b + c), lng)]
end



# applies the rule to all the cells. I decided to make
# it wrap around, so that the final cell considers the
# first cell as one of its neighbours
function nextgeneration(ca::CA)
    l = length(ca.cells)
    nextgen = falses(l)
    for i in 1:l
        left   = ca.cells[mod1(i - 1, l)]
        me     = ca.cells[mod1(i, l)]
        right  = ca.cells[mod1(i + 1, l)]
        nextgen[i] = rules(ca, left, me, right)
    end
    ca.cells = nextgen
    ca.generation += 1
    return ca
end


# how to show an automaton in the terminal
Base.show(io::IO, ::MIME"text/plain", ca::CA) =
    print(io, join([c ? "■" : " " for c in ca.cells]))
