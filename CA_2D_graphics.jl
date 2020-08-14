# Cellular Automata: 1D
# graphics
# https://www.juliabloggers.com/automata/
#
# By: Jantine Broek
##########################################################
using Luxor
using Colors
using ColorSchemes

include("CA_2D.jl")

function draw(ca::CA, cellwidth=10)
    lng = length(ca.cells)
    for i in 1:lng
        if ca.cells[i] == true
            pt = Point(-(lng ÷ 2) * cellwidth + i * cellwidth, 0)
            box(pt, cellwidth, cellwidth, :fill)
        end
    end
end

# @png begin
#     ca = CA(30, 200)
#     sidelength = 4
#     # start at the top
#     translate(boxtopcenter(BoundingBox()) + sidelength)
#     for i in 1:200
#         draw(ca, sidelength)
#         nextgeneration(ca)
#         translate(Point(0, sidelength))
#     end
# end #800 850 "images/automata/simple-ca.png"

# call nextgeneration() without displaying the results
@png begin
    ca = CA(110, 200)
    translate(boxtopcenter(BoundingBox()) + sidelength)
    sidelength = 4
    # into the future
    for _ in 1:200_000
        nextgeneration(ca)
    end
    for _ in 1:195
        draw(ca, sidelength)
        nextgeneration(ca)
        translate(Point(0, sidelength))
    end
end

# drawing them from left to right looks better
@png begin
    ca = CA(30)
    translate(boxmiddleleft(BoundingBox()) + sidelength)
    rotate(-π/2)
    sidelength = 3.5
    for i in 1:320
        draw(ca, sidelength)
        nextgeneration(ca)
        translate(Point(0, sidelength))
    end
end

# The nextgeneration() function can be updated with
# instructions about how to modify the color of the next
# generation, based on the current set of three cells.
function nextgeneration(ca::CA)
    l = length(ca.cells)
    nextgen = falses(l)
    for i in 1:l
        left   = ca.cells[mod1(i - 1, l)]
        me     = ca.cells[mod1(i, l)]
        right  = ca.cells[mod1(i + 1, l)]
        nextgen[i] = rules(ca, left, me, right)
        if me == 1
            ca.colorstops[i] = mod(ca.colorstops[i] + 0.1, 1)
        elseif left == 1 && right == 1
            ca.colorstops[i] = mod(ca.colorstops[i] - 0.1, 1)
        else
            ca.colorstops[i] = 0
        end
    end
    ca.cells = nextgen
    ca.generation += 1
    return ca
end


# draw() function can be adapted to make use of the
# color information
function drawcolor(ca::CA, cellwidth=10;
        scheme=ColorSchemes.leonardo)
    lng = length(ca.cells)
    for i in 1:lng
        if ca.cells[i] == true
            sethue(get(scheme, ca.colorstops[i]))
            pt = Point(-(lng ÷ 2) * cellwidth + (i * cellwidth), 0)
            box(pt, cellwidth, cellwidth, :fill)
        end
    end
end

@svg begin
    background("darkorchid4")
    ca = CA(135, 65)
    # randomize start state
    ca.cells = rand(Bool, length(ca.cells))
    sidelength = 5
    translate(boxmiddleleft(BoundingBox()) + sidelength)
    rotate(-π/2)
    for i in 1:195
        drawcolor(ca, sidelength, scheme=ColorSchemes.cubehelix)
        nextgeneration(ca)
        translate(Point(0, sidelength))
    end
end
