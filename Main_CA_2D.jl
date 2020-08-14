 # Simulate 1D cellular automaton
 # https://www.juliabloggers.com/automata/
 #
 # By: Jantine Broek
 ##########################################################

include("CA_2D.jl")
include("CA_2D_graphics.jl")

# create a cellular automaton by providing a rule number
ca = CA(30)

# update the automaton
nextgeneration(ca)

# show a historical diagram of its evolution
for i in 1:30
    display(nextgeneration(ca))
end

# rule 110 (emulating activity of Turing machine)


function frame(scene, framenumber, ca, cahistory, sidelength;
            smoothscrolling=10)
    background(colorant"navy")
    fontsize(12)
    sethue(colorant"azure")
    text(string(ca.generation), boxtopright(BoundingBox()) + (-30, 20),
        halign=:right)
    setline(0.1)

    # get in position for the first row
    translate(boxmiddleleft(BoundingBox()))
    rotate(-π/2)

    # for smooth scrolling
    translate(0, -(mod1(framenumber, smoothscrolling))
        * sidelength/smoothscrolling)

    lng = length(ca.cells)
    for gen in cahistory
        for (n, cell) in enumerate(gen)
            if cell == true
                pt = Point(-(lng / 2) * sidelength + (n * sidelength), 0)
                box(pt, sidelength - 2, sidelength - 2, :fill)
            end
        end
        translate(Point(0, sidelength))
    end
    # "beautiful buttery scrolling"
    if framenumber % smoothscrolling == 0
        # drop oldest, add a new generation
        popfirst!(cahistory)
        nextgeneration(ca)
        push!(cahistory, ca.cells)
    end
end

function makeanimation(rule, filename)
    width, height = (1920, 1080)
    sidelength = 6
    cellularmovie = Movie(width, height, "cellularmovie")
    ca = CA(rule, convert(Int, height÷sidelength))
    cahistory = []
    # initial
    for _ in 1:width÷sidelength
        push!(cahistory, ca.cells)
        nextgeneration(ca)
    end
    animate(cellularmovie,
        [Scene(cellularmovie, (s, f) ->
            frame(s, f, ca, cahistory, sidelength, smoothscrolling=4),
                1:500)],
    pathname="$(filename)")
end

makeanimation(110, "animated-cellular-automaton.gif")
