module Kcube

  include("Board.jl")
  include("GLModel.jl")
  include("Anim.jl")
  include("GLtools.jl")

  export GLtools
  export Board
  export GLModel
  export Anim
  
  import Reactive
  import GLAbstraction
  import GeometryTypes
  import GLFW
  import ModernGL

  const ga = GLAbstraction
  const gt = GeometryTypes
  const fw = GLFW
  const gl = ModernGL


  
  const boardtoanim = Dict(
                           ("moveupcube!", true) => ( Anim.MOVETIME, true),
                           ("movedowncube!", true) => ( Anim.MOVETIME, true),
                           ("moveleftcube!", true) => ( Anim.MOVETIME, true),
                           ("moverightcube!", true) => ( Anim.MOVETIME, true),
                           ("moveupcursor!", true) => ( Anim.MOVETIME, false),
                           ("movedowncursor!", true) => ( Anim.MOVETIME, false),
                           ("moverightcursor!", true) => ( Anim.MOVETIME, false),
                           ("moveleftcursor!", true) => ( Anim.MOVETIME, false)
                          )

  """
      function processboardevent(boardevents::Array{Tuple{name::String, args::Kcube, value::Bool}},
                                  animevents::Array{Tuple{Anim.GLobj, Mat{4,4,Float32}, Float64},1})

  Translate logic board events into animation event.
  
  a board event name may be: `{ "addcube!", "move"*or*"cube!", "move"*or*"cursor!" }`
  where `or` maybe `{"up", "down", "right", "left"}`
    
  """
  function processboardevent!(boardevents::Array{Tuple{String,Any,Bool},1},
                             animevents::Array{Tuple{Anim.GLobj, gt.Mat{4,4,Float32}, Float64},1},
                             glcubes::Array{Anim.GLobj},
                             glpointer::Anim.GLobj)
    len = length(boardevents)
    if len != 0
      for i in len
        boardevent =  pop!(boardevents)
        if ( boardevent[1], boardevent[3] ) in keys(boardtoanim)
          animetime, iscube = boardtoanim[ (boardevent[1] , boardevent[3]) ]
          if iscube
            cube = boardevent[2]
            rx, ry, rz = Board.getrotatecoord(cube)
            modelquat = (Anim.ROTATETOPQUA^rz)*(Anim.ROTATERIGHTQUA^ry)*(Anim.ROTATEUPQUA^rx)
            modelmat = ga.rotationmatrix4(modelquat)
            x, y, z = cube.position
            modelmat = ga.translationmatrix(gt.Vec3{Float32}(Anim.CUBE_SIZE*[x,y,z])) * modelmat
            event = (glcubes[boardevent[2].cubeid], modelmat, animetime )
          else
            x, y, z = boardevent[2].position
            modelmat = ga.translationmatrix(gt.Vec3{Float32}(Anim.CUBE_SIZE*[x,y,Anim.CURSORALT]))
            event = (glpointer, modelmat, animetime)
          end#if
        push!(animevents, event)
        end#if
      end#for
    end#if
    return animevents
      
  end#function processboardevent!

  function processanimevent!(animevents::Array{Tuple{Anim.GLobj, gt.Mat{4,4,Float32}, Float64},1})
    
    for i in 1:length(animevents)
      animevent = pop!(animevents)
      Anim.glmoveobj!(animevent[1], animevent[2], animevent[3], time(), animevents)
    end#for
    
  end#function processanimevent!

  function render(glcubes::Array{Anim.GLobj,1},
                  glcursor::Anim.GLobj,
                  cubero::Any,
                  cubetrans,
                  pointerro::Any,
                  pointertrans,
                  projectionview )

    for glcube in glcubes
      modelmat = glcube.interpolation(glcube, time())
      mvpmat = projectionview*modelmat
      push!(cubetrans, mvpmat)
      Reactive.run_till_now()
      ga.render(cubero)
    end#for

    modelmat = glcursor.interpolation(glcursor, time())
    mvpmat = projectionview*modelmat 
    push!(pointertrans, mvpmat)
    Reactive.run_till_now()
    ga.render(pointerro)
      
  end#render


  function init_anim(cursor::Board.Cursor)
    
    grid = cursor.grid
    animevents = Anim.AnimEvents()
    glcubes = Array{Anim.GLobj,1}()
    for i in 1:Board.CUBE_NB
      x,y,z = grid.cubes[i].position
      glcube = Anim.GLobj()
      glcube.lastmodel = ga.translationmatrix(gt.Vec3{Float32}(Anim.CUBE_SIZE*[x,y,z]))
      glcube.targetmodel = glcube.lastmodel
      push!(glcubes, glcube)
    end
    x,y,z = cursor.cube.position
    glcursor = Anim.GLobj()
    glcursor.lastmodel = ga.translationmatrix(gt.Vec3{Float32}(x,y,z + Anim.CURSORALT))
    return (glcubes, glcursor, animevents)
    
  end#function init_anim
  

  function main()
    
    window, keymaps = GLtools.init_gl()
    cursor, boardevents = Board.init_board(keymaps)
    glcubes, glcursor, animevents = init_anim(cursor)
    cubero, cubetrans, pointerro, pointertrans = GLModel.init_model()
    
    # TODO cleaner camera handling
    projection = ga.perspectiveprojection(Float32, 90., 4./3., 1., 100.)
    view = ga.lookat( gt.Vec3f0(10.,10., -15.), gt.Vec3f0(4.,4.,0.), gt.Vec3f0( 0.,0.,1.))
    projectionview = projection*view

    while !GLFW.WindowShouldClose(window)
        t = time()
        gl.glClear(gl.GL_COLOR_BUFFER_BIT)
        gl.glClear(gl.GL_DEPTH_BUFFER_BIT)

        GLFW.PollEvents()
        processboardevent!(boardevents, animevents, glcubes, glcursor)
        processanimevent!(animevents)
        render( glcubes, glcursor, cubero, cubetrans, pointerro, pointertrans, projectionview )

        GLFW.SwapBuffers(window)
        if GLFW.GetKey(window, GLFW.KEY_ESCAPE) == GLFW.PRESS
            GLFW.SetWindowShouldClose(window, true)
        end
    end 

  end#function main

end # module


