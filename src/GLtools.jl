
module GLtools

  import GLFW
  import ModernGL
  import GeometryTypes
  import GLAbstraction
  import Reactive
  const re = Reactive
  const gl = ModernGL
  const fw = GLFW
  const gt = GeometryTypes
  const ga = GLAbstraction
  # La fonction de création de contexte, retourne une fenêtre GLFW

  function create_context()
    window_hint = [
      ( fw.SAMPLES,   4), # antialiasing 4
      ( fw.DEPTH_BITS,  32), # taille du buffer de profondeur
      ( fw.ALPHA_BITS,  8),
      ( fw.RED_BITS,    8),
      ( fw.BLUE_BITS,   8),
      ( fw.STENCIL_BITS,  8),
      ( fw.AUX_BUFFERS, 0),
      ( fw.CONTEXT_VERSION_MAJOR, 3 ), #minimum OpenGL v.3
      ( fw.CONTEXT_VERSION_MINOR, 3 ), # same for minimum version 
      ( fw.OPENGL_PROFILE, fw.OPENGL_CORE_PROFILE ),
      ( fw.OPENGL_FORWARD_COMPAT, gl.GL_TRUE),
      ( fw.RESIZABLE, gl.GL_FALSE ),
    ]

    for (key, value) in window_hint
      fw.WindowHint( key, value )
    end

    window = fw.CreateWindow( 800 , 600, "Kcube revenge")
    fw.MakeContextCurrent( window )
    fw.SetInputMode( window, fw.STICKY_KEYS, gl.GL_TRUE )
    gl.glClearColor(1,1,1,1)
    return window
  end


  function init_gl()
    
    window = GLtools.create_context()
    keymapping = Dict()
    function key_callback(window, key::Integer, scancode::Integer, action::Integer, mods::Integer)
      if key in keys(keymapping) && action == fw.PRESS
        keymapping[key][1](keymapping[key][2])
      end
    end#function key_callback   window = GLModel.create_context()

    fw.SetKeyCallback(window, key_callback)
    return window, keymapping

  end#function init_gl


  type CubesInstance
    cubenb::Integer
    #grid::Dict{Tuple{Integer, Integer}, Integer}
    mvpmatrix::Array{gt.FixedSizeArrays.Mat{4,4,Float32},1}
    rendermvpmatrix
    function CubesInstance(rendermvpmatrix, cubenb::Integer)
      mvpmatrix = Array{gt.FixedSizeArrays.Mat{4,4,Float32},1}(cubenb)
      for n in 1:cubenb
        mvpmatrix[n] = ga.translationmatrix_x(Float32(2.5*( n - 1 - div(cubenb,2) )))
      end
      new(cubenb, mvpmatrix, rendermvpmatrix) 
    end#function CubesInstance
  end#type CubesInstance

    # Define the rotation matrix (could also use rotationmatrix_z)
    # By wrapping it in a Signal, we can easily update it.

end#module GLtools

