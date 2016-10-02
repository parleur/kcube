module GLModel

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


  function create_cube()
    vao = gl.glGenVertexArrays()
    gl.glBindVertexArray(vao)

    # The six main points of the cube
    A = (-1.,  1. , 1.) 
    B = ( 1.,  1., 1. )   # b 1
    C = ( 1.,  1., -1.)   # c 2
    D = (-1.,  1., -1.)   # e 4
    E = (-1., -1., -1.)   # e 4
    F = ( 1., -1., -1.)   # f 5 
    G = ( 1., -1.,  1.)   # g 6
    H = (-1., -1.,  1.)   # h 7


    # The positions of the vertices in our rectangle
    # The six point are duplicted into six independent faces
    # Needed because at corner same point have three different colors depending
    # on cube faces
    vertex_positions = gt.Point{3,Float32}[A,B,G,H,#0,1,2,3,
                                        A,B,C,D,#4,5,6,7,
                                        A,D,E,H,#8,9,10,11,
                                        B,C,F,G,#12,13,14,15,
                                        E,F,G,H,#16,17,18,19,
                                        D,C,E,F]#20,21,22,23,

    # Each square is two triangles
    elements = gt.Face{3,UInt32,-1}[(0,1,2),#Face 1
                                 (0,2,3),
                                 (4,5,6),#Face 2
                                 (4,6,7),
                                 (8,9,10),#Face 3
                                 (8,10,11),
                                 (12,13,14),#Face 4
                                 (12,14,15),
                                 (16,17,18),#Face 5
                                 (16,18,19),
                                 (20,21,22),# Face 6
                                 (21,22,23)]
    #Face color
    col1 = [ 50. , 107., 211.]/256.
    col2 = [ 212 , 91. , 51. ]/256.
    col3 = [ 204. ,212. , 51.]/256.
    col4 = [ 194. , 42. , 84.]/256.
    col5 = [ 43. , 194. , 91.]/256.
    col6 = [ 43. , 176. , 194.]/256.

    color = gt.Vec3f0[ col1, col1, col1, col1,
                    col2, col2, col2, col2,
                    col3, col3, col3, col3,
                    col4, col4, col4, col4,
                    col5, col5, col5, col5,
                    col6, col6, col6, col6 ]

    vertex_shader = ga.@vert_str("""
    #version 330

    in vec3 position;
    in vec3 color;

    out vec4 frag_color;
    uniform mat4 trans;

    void main()
    {
    frag_color = vec4(color, 1.0);
    gl_Position = trans*vec4(position, 1.0);
    }
    """)

    fragment_shader = ga.@frag_str("""
    # version 330 

    in vec4 frag_color;

    out vec4 Color;

    void main()
    {
        Color = frag_color;
    }
    """)
    projection = ga.perspectiveprojection(Float32, 45., 4./3., 1., 100.)
    view = ga.lookat( gt.Vec3f0(8.5,10., 8.5), gt.Vec3f0(0.,0.,0.), gt.Vec3f0( 0.,1.,0.))

    trans = re.Signal(projection*view)

    # Link everything together, using the corresponding shader variable as
    # the Dict key
    bufferdict = Dict(:position=>ga.GLBuffer(vertex_positions),
                      :color=>ga.GLBuffer(color),
                      :trans=>trans,
                      :indexes=>ga.indexbuffer(elements)) # special for element buffers

    ro = ga.std_renderobject(bufferdict,
                          ga.LazyShader(vertex_shader, fragment_shader))

    return (ro, trans)

  end#function create_cube


  function create_pointer()
    vao = gl.glGenVertexArrays()
    gl.glBindVertexArray(vao)
    
    const BS = 1.
    # The six main points of the pointer
    A = BS*[-0.25,-0.25, 0.35] 
    B = BS*[-0.25, 0.25, 0.35]
    C = BS*[ 0.25, 0.25, 0.35]
    D = BS*[ 0.25,-0.25, 0.35]
    E = BS*[ 0.  , 0.  ,-0.35]

    vertex_positions = gt.Point{3,Float32}[A,B,C,D,E]

    elements = gt.Face{3,UInt32,-1}[(0,1,3),
                                 (1,2,3),
                                 (0,3,4),
                                 (2,3,4),
                                 (1,2,4),
                                 (0,1,4)]

    const col = [ 43. , 176. , 194.]/256.

    color = gt.Vec3f0[ col, col, col, col,
                      col, col]

    vertex_shader = ga.@vert_str("""
    #version 330

    in vec3 position;
    in vec3 color;

    out vec4 frag_color;
    uniform mat4 trans;

    void main()
    {
    frag_color = vec4(color, 1.0);
    gl_Position = trans*vec4(position, 1.0);
    }
    """)

    fragment_shader = ga.@frag_str("""
    # version 330 

    in vec4 frag_color;

    out vec4 Color;

    void main()
    {
        Color = frag_color;
    }
    """)
    projection = ga.perspectiveprojection(Float32, 45., 4./3., 1., 100.)
    view = ga.lookat( gt.Vec3f0(8.5,10., 8.5), gt.Vec3f0(0.,0.,0.), gt.Vec3f0( 0.,1.,0.))

    trans = re.Signal(projection*view)

    # Link everything together, using the corresponding shader variable as
    # the Dict key
    bufferdict = Dict(:position=>ga.GLBuffer(vertex_positions),
                      :color=>ga.GLBuffer(color),
                      :trans=>trans,
                      :indexes=>ga.indexbuffer(elements)) # special for element buffers

    ro = ga.std_renderobject(bufferdict,
                          ga.LazyShader(vertex_shader, fragment_shader))

    return (ro, trans)
  end#function create_pointer


end#module GLModel
