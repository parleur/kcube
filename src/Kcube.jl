module Kcube

  include("Board.jl")
  include("GLModel.jl")
  include("Anim.jl")
  include("GLtools.jl")

  export GLtools
  export Board
  export GLModel
  export Anim

  import GLFW
  const fw = GLFW

  const CUBE_NB = 5

  function init_gl()

    keymapping = Dict()
    function key_callback(window, key::Integer, scancode::Integer, action::Integer, mods::Integer)
      if key in keymapping && action == fw.PRESS
        keymapping[key][1](keymapping[key][2])
      end
    end#function key_callback   window = GLModel.create_context()

    fw.SetKeyCallback(window, key_callback)
    return keymapping

  end#function init_gl
  
  function init_model()

    cubero, cubetrans = GLModel.create_cube()
    pointerro, pointertrans = GLModel.create_pointer()
    return cubero, cubetrans, pointerro, pointertrans
    
  end#function init_model
  

  function init_board(keymap::Dict{Any, Any})

    grid = Board.KcubeGrid((10,10,1))
    for i in 1:CUBE_NB
      Board.addcube!(grid)
    end#for
    cursor = Board.Cursor(grid, grid.cubes[1])


    merge!(keymap, Dict(fw.KEY_Z => (Board.moveupcursor!, cursor),
                            fw.KEY_S => (Board.movedowncursor!, cursor),
                            fw.KEY_Q => (Board.moveleftcursor!,cursor),
                            fw.KEY_D => (Board.moverightcursor!,cursor)) )

    return cursor, cursor.grid.boardevents

  end#function init_board
  
  const boardtoanim = Dict(
                           ("moveupcube!", true) => (Anim.MOVECUBEUPMAT, 1., true),
                           ("movedowncube!", true) => (Anim.MOVECUBEDOWNMAT, 1., true),
                           ("moveleftcube!", true) => (Anim.MOVECUBELEFTMAT, 1., true),
                           ("moverightcube!", true) => (Anim.MOVECUBERIGHTMAT, 1., true),
                           ("moveupcursor!", true) => (Anim.MOVEUPMAT, 1., false),
                           ("movedowncursor!", true) => (Anim.MOVEDOWNMAT, 1., false),
                           ("moverightcursor!", true) => (Anim.MOVERIGHTMAT, 1., false),
                           ("moverleftcursor!", true) => (Anim.MOVELEFTMAT, 1., false),
                          )

  """
      function processboardevent(boardevents::Array{Tuple{name::String, args::Kcube, value::Bool}},
                                  animevents::Array{Tuple{GLobj, Mat{4,4,Float32}, Float64},1})

  Translate logic board events into animation event.
  
  a board event name may be: `{ "addcube!", "move"*or*"cube!", "move"*or*"cursor!" }`
  where `or` maybe `{"up", "down", "right", "left"}`
    
  """
  function processboardevent!(boardevents::Array{Tuple{name::String, args::Any, value::Bool}},
                             animevents::Array{Tuple{GLobj, Mat{4,4,Float32}, Float64},1},
                             glcubes::Array{Anim.GLobj},
                             glpointer::Anim.GLobj)

    for i in length(boardevents)
      boardevent =  pop!(boardevents)
      if ( boardevent[1], boardevent[3] ) in boardtoanim
        modelmat, animetime, iscube = boardtoanim[ (boardevent[1] , boardevent[3]) ]
        if iscube
          event = (glcubes[boardevent[2].cubeid], modelmat, animetime )
        else
          event = (glpointer, modelmat, animetime)
        end#if
      push!(animevents, event)
      end#if
    end#for
    return animevents
      
  end#function processboardevent!

  function processanimevent!(animevents::Array{Tuple{GLobj, Mat{4,4,Float32}, Float64},1})
    
    for i in 1:length(animevents)
      animevent = pop!(animevents)
      Anim.glmoveobj(animevent[1], animevent[2], animevent[3], time())
    end#for
    
  end#function processanimevent!

  function render(glcubes::Array{Anim.GLobj,1}, glpointer::Anim.GLobj)

    for glcube in glcubes
      modelmat = glcube.interpolation(glcube, time())
      mvpmat = projection*view*modelmat
      push!(cubetrans, mvpmat)
      ga.render(cubero)
    end#for

    modelmat = glpointer.interpolation(glpointer, time())
    mvpmat = projection*view*modelmat #TODO finish to define projection and view matrix
    push!(pointertrans, mvpmat)
    ga.render(pointerro)
      
  end#render


  function init_anim()
    
    animevents = Anim.AnimEvents()
    glcubes = Array{Anim.GLobj,1}()
    for i in 1:CUBE_NB
      push!(glcubes, Anim.GLobj())
    end
    glcursor = Anim.GLobj()
    return (glcubes, glcursor, animevents)
    
  end#function init_anim
  

  function main()
    
    keymaps = init_gl()
    cursor, boardevents = init_board(keymaps)
    glcubes, glcursor, animevents = init_anim()
    cubero, cubetrans, pointerro, pointertrans = init_model()

  end#function main

end # module


