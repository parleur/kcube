module Board

  import GLFW
  const fw = GLFW
  
  const CUBE_NORMAL = 1  
  const CUBE_NOCUBE = 0
    
  # Arbitrary colors (coresponding with a cube on my desktop)
  # The order depart from a face, going altenatively bottom then right (and so on ..)
  const FACE_RED = 1
  const FACE_BLUE = 2
  const FACE_GREY = 3
  const FACE_YELLOW = 4
  const FACE_GREEN = 5
  const FACE_BLACK = 6
  
  const GRIDSIZE = (5,5,1)
  const CUBE_NB = 5

  const BoardEvents = Array{Tuple{String, Any, Bool},1}

  function init_board(keymap::Dict{Any, Any})

    grid = KcubeGrid(GRIDSIZE)
    for i in 1:CUBE_NB
      addcube!(grid)
    end#for
    cursor = Cursor(grid, grid.cubes[1])
  
    function prtdebug(cursor)
      debug = "position: "*string(cursor.cube.position)*"\n"
      debug *= "orientation: "*string(cursor.cube.orientation)*"\n"
      println(debug)
    end

    merge!(keymap, Dict(fw.KEY_UP => (moveupcursor!, cursor),
                            fw.KEY_DOWN => (movedowncursor!, cursor),
                            fw.KEY_LEFT => (moveleftcursor!,cursor),
                            fw.KEY_RIGHT => (moverightcursor!,cursor),
                            fw.KEY_P => (prtdebug, cursor)) )

    return cursor, cursor.grid.boardevents

  end#function init_board

  """
      type Kcube
      
        cubeid::Integer
        cubetype::Integer
        position::Tuple{Integer, Integer, Integer}
        orientation::Tuple{Integer, Integer}

  A type representing a cube. Supposed to be instanciated inside a `KcubeGrid` using 
  `addcube!` function.

  `orientation` represent the top face, then the front face of the cube.
  """
  type Kcube
  
    cubeid::Integer
    cubetype::Integer
    position::Tuple{Integer, Integer, Integer}#position
    orientation::Tuple{Integer, Integer}#first the top face, then the front face
    function Kcube(cubeid::Integer, cubetype::Integer, position::Tuple{Integer,Integer,Integer},orientation::Tuple{Integer,Integer})
      new(cubeid, cubetype, position, orientation)
    end#function Kcube
    function Kcube(cubeid::Integer, position::Tuple{Integer, Integer, Integer})
      new(cubeid, CUBE_NORMAL, position, (FACE_RED, FACE_BLUE))
    end#function Kcube
  
  end#type Kcube
  
  """
      const KCUBE_NOCUBE

  The special cube, representing absence of cube, `cubeid` is 0, and `position` is 
  `(0,0,0)`. 
  """
  const KCUBE_NOCUBE = Kcube(0, CUBE_NOCUBE, (0,0,0),(FACE_RED, FACE_BLUE))
  
  const SQUARE_NORMAL = 0
  
  """
      type Ksquare

  A square of game. Used to store square type in field `casetype`. Contains `cube`
  """
  type Ksquare

    casetype::Integer
    cube::Kcube
    function Ksquare()
      new( SQUARE_NORMAL, KCUBE_NOCUBE )
    end#function Ksquare

  end#type Ksquare
  
  """
      ksquaregetcube!(square::Ksquare, cube::Kcube)
  
  Pop `cube` in `square` if empty, return `true` if so, `false` else.
  """
  function ksquaregetcube!(square::Ksquare, cube::Kcube)
    if is(square.cube,KCUBE_NOCUBE)
      square.cube = cube
      return true#true if no error
    else
      return false
    end#if
  end#function ksquaregetcube

  """
      type KcubeGrid
        
        cubenb::Integer
        grid::Array{Ksquare, 3}# coordinate, 
        cubes::Array{Kcube,1} #Direct reference to the cubes
        size::Tuple{Integer,Integer,Integer}
  
  The main grid, signature means.
  """

  type KcubeGrid
    
    cubenb::Integer
    grid::Array{Ksquare, 3}# coordinate, 
    cubes::Array{Kcube,1} #Direct reference to the cubes
    size::Tuple{Integer,Integer,Integer}
    boardevents::BoardEvents

    function KcubeGrid( size::Tuple{Integer,Integer,Integer})
      grid = Array{Any}(size...)
      for i in 1:size[1]
        for j in 1:size[2]
          for k in 1:size[3]
            grid[i,j,k] = Ksquare()
          end#for
        end#for
      end#for
      cubes = Array{Kcube}(0)
      boardevents = BoardEvents()
      new(0, grid, cubes, size, boardevents)
    end#function KcubeGrid
  
  end#type KcubeGrid

  function firstempty(grid::KcubeGrid)
    for i in 1:grid.size[1]
      for j in 1:grid.size[2]
        for k in 1:grid.size[3]
          if grid.grid[i,j,k].cube == KCUBE_NOCUBE
            return (i,j,k)
          end#if
        end#for
      end#for
    end#for
    return (0,0,0)
  end

  """
      addcube!(grid::KcubeGrid, position::Tuple{Integer,Integer,Integer})

  Pop a newly instancied cube into `grid` at `position`. 
  Return `0` if error, a `cubeid` else
  """
  function addcube!(grid::KcubeGrid,
                    position::Tuple{Integer,Integer,Integer})
    if all( [1,1,1] .<= [position...] & [position...] .<= [grid.size...])
      cubeid = length(grid.cubes) + 1
      cube = Kcube( cubeid, position )
      square = grid.grid[position...]
      if ksquaregetcube!(square, cube)#Square accept the cube
        push!(grid.cubes,cube)
        push!(grid.boardevents,("addcube!", cube, true))
        return cubeid
      end#if
    end#if
    return 0
  end#function addcube

  function addcube!(grid::KcubeGrid)
    position = firstempty(grid)
    if position != (0,0,0)
      cubeid = length(grid.cubes) + 1
      cube = Kcube(cubeid, position)
      square = grid.grid[position...]
      if ksquaregetcube!(square, cube)
        push!(grid.cubes,cube)
        push!(grid.boardevents,("addcube!", cube, true))
        return cubeid
      end#if
    end#if
    return 0
  end

  export(addcube!)
  
  const RIGHT_ROTATION_TABLE = 
        Dict(
             (FACE_RED, FACE_BLACK)     =>  (FACE_GREEN, FACE_BLACK),
             (FACE_RED, FACE_BLUE)      =>  (FACE_BLACK, FACE_BLUE),
             (FACE_RED, FACE_GREY)      =>  (FACE_BLUE, FACE_GREY),
             (FACE_RED, FACE_GREEN)     =>  (FACE_GREY, FACE_GREEN),
             (FACE_YELLOW, FACE_BLACK)  =>  (FACE_BLUE, FACE_BLACK),
             (FACE_YELLOW, FACE_BLUE)   =>  (FACE_GREY, FACE_BLUE),
             (FACE_YELLOW, FACE_GREY)   =>  (FACE_GREEN, FACE_GREY),
             (FACE_YELLOW, FACE_GREEN)  =>  (FACE_BLACK, FACE_GREEN),
             (FACE_GREEN, FACE_BLACK)   =>  (FACE_YELLOW, FACE_BLACK),
             (FACE_GREEN, FACE_RED)     =>  (FACE_BLACK, FACE_RED),
             (FACE_GREEN, FACE_GREY)    =>  (FACE_RED, FACE_GREY),
             (FACE_GREEN, FACE_YELLOW)  =>  (FACE_GREY, FACE_YELLOW),
             (FACE_BLUE, FACE_BLACK)    =>  (FACE_RED, FACE_BLACK),
             (FACE_BLUE, FACE_RED)      =>  (FACE_GREY, FACE_RED),
             (FACE_BLUE, FACE_GREY)     =>  (FACE_YELLOW, FACE_GREY),
             (FACE_BLUE, FACE_YELLOW)   =>  (FACE_BLACK, FACE_YELLOW),
             (FACE_GREY, FACE_BLUE)     =>  (FACE_RED, FACE_BLUE),
             (FACE_GREY, FACE_YELLOW)   =>  (FACE_BLUE, FACE_YELLOW),
             (FACE_GREY, FACE_GREEN)    =>  (FACE_YELLOW, FACE_GREEN),
             (FACE_GREY, FACE_RED)      =>  (FACE_GREEN, FACE_RED),
             (FACE_BLACK, FACE_BLUE)    =>  (FACE_YELLOW, FACE_BLUE),
             (FACE_BLACK, FACE_YELLOW)  =>  (FACE_GREEN, FACE_YELLOW),
             (FACE_BLACK, FACE_GREEN)   =>  (FACE_RED, FACE_GREEN),
             (FACE_BLACK, FACE_RED)     =>  (FACE_BLUE, FACE_RED),
            )
  # Then left is three time right
  const _rr = RIGHT_ROTATION_TABLE
  const LEFT_ROTATION_TABLE = 
        Dict(key => _rr[_rr[_rr[key]]] for key = keys(_rr))

  const UP_ROTATION_TABLE =
        Dict(
             (FACE_RED, FACE_BLACK)     =>    (FACE_BLACK, FACE_YELLOW),
             (FACE_RED, FACE_BLUE)      =>    (FACE_BLUE, FACE_YELLOW),
             (FACE_RED, FACE_GREY)      =>    (FACE_GREY, FACE_YELLOW),
             (FACE_RED, FACE_GREEN)     =>    (FACE_GREEN, FACE_YELLOW),
             (FACE_YELLOW, FACE_BLACK)  =>    (FACE_BLACK, FACE_RED),
             (FACE_YELLOW, FACE_BLUE)   =>    (FACE_BLUE, FACE_RED),
             (FACE_YELLOW, FACE_GREY)   =>    (FACE_GREY, FACE_RED),
             (FACE_YELLOW, FACE_GREEN)  =>    (FACE_GREEN, FACE_RED),
             (FACE_GREEN, FACE_BLACK)   =>    (FACE_BLACK, FACE_BLUE),
             (FACE_GREEN, FACE_RED)     =>    (FACE_RED, FACE_BLUE),
             (FACE_GREEN, FACE_GREY)    =>    (FACE_GREY, FACE_BLUE),
             (FACE_GREEN, FACE_YELLOW)  =>    (FACE_YELLOW, FACE_BLUE),
             (FACE_BLUE, FACE_BLACK)    =>    (FACE_BLACK, FACE_GREEN),
             (FACE_BLUE, FACE_RED)      =>    (FACE_RED, FACE_GREEN),
             (FACE_BLUE, FACE_GREY)     =>    (FACE_GREY, FACE_GREEN),
             (FACE_BLUE, FACE_YELLOW)   =>    (FACE_YELLOW, FACE_GREEN),
             (FACE_GREY, FACE_BLUE)     =>    (FACE_BLUE, FACE_BLACK),
             (FACE_GREY, FACE_YELLOW)   =>    (FACE_YELLOW, FACE_BLACK),
             (FACE_GREY, FACE_GREEN)    =>    (FACE_GREEN, FACE_BLACK),
             (FACE_GREY, FACE_RED)      =>    (FACE_RED, FACE_BLACK),
             (FACE_BLACK, FACE_BLUE)    =>    (FACE_BLUE, FACE_GREY),
             (FACE_BLACK, FACE_YELLOW)  =>    (FACE_YELLOW, FACE_GREY),
             (FACE_BLACK, FACE_GREEN)   =>    (FACE_GREEN, FACE_GREY),
             (FACE_BLACK, FACE_RED)     =>    (FACE_RED, FACE_GREY),
            )
  # Then down is three time up
  const _ru = UP_ROTATION_TABLE
  const DOWN_ROTATION_TABLE = 
        Dict(key => _ru[_ru[_ru[key]]] for key = keys(_rr))
  
  const COORD_ROTATION_TABLE = #UPROTATION, RIGHTROTATION, TOPROTATION
      Dict(
             (FACE_RED, FACE_BLUE)      =>    (0,0,0),
             (FACE_RED, FACE_BLACK)     =>    (0,0,3),
             (FACE_RED, FACE_GREY)      =>    (0,0,1),
             (FACE_RED, FACE_GREEN)     =>    (0,0,2),
             (FACE_YELLOW, FACE_BLACK)  =>    (2,0,3),
             (FACE_YELLOW, FACE_BLUE)   =>    (2,0,2),
             (FACE_YELLOW, FACE_GREY)   =>    (2,0,1),
             (FACE_YELLOW, FACE_GREEN)  =>    (2,0,0),
             (FACE_GREEN, FACE_BLACK)   =>    (3,0,3),
             (FACE_GREEN, FACE_RED)     =>    (3,0,0),
             (FACE_GREEN, FACE_GREY)    =>    (3,0,1),
             (FACE_GREEN, FACE_YELLOW)  =>    (3,0,2),
             (FACE_BLUE, FACE_BLACK)    =>    (1,0,3),
             (FACE_BLUE, FACE_RED)      =>    (1,0,2),
             (FACE_BLUE, FACE_GREY)     =>    (1,0,1),
             (FACE_BLUE, FACE_YELLOW)   =>    (1,0,0),
             (FACE_GREY, FACE_BLUE)     =>    (0,3,0),
             (FACE_GREY, FACE_YELLOW)   =>    (0,3,1),
             (FACE_GREY, FACE_GREEN)    =>    (0,3,2),
             (FACE_GREY, FACE_RED)      =>    (0,3,3),
             (FACE_BLACK, FACE_BLUE)    =>    (0,1,0),
             (FACE_BLACK, FACE_YELLOW)  =>    (0,1,3),
             (FACE_BLACK, FACE_GREEN)   =>    (0,1,2),
             (FACE_BLACK, FACE_RED)     =>    (0,1,1)
            )

  function getrotatecoord(cube::Kcube)
    return COORD_ROTATION_TABLE[cube.orientation]
  end#function getrotatecoordcube

  function rotateupcube!(cube::Kcube)#never failing function
    cube.orientation = UP_ROTATION_TABLE[cube.orientation]
  end#function rotateupcube

  function rotatedowncube!(cube::Kcube)#never failing function
    cube.orientation = DOWN_ROTATION_TABLE[cube.orientation]
  end#function rotatedowncube

  function rotateleftcube!(cube::Kcube)#never failing function
    cube.orientation = LEFT_ROTATION_TABLE[cube.orientation]
  end#function rotateleftcube

  function rotaterightcube!(cube::Kcube)#never failing function
    cube.orientation = RIGHT_ROTATION_TABLE[cube.orientation]
  end#function rotaterightcube

  for (funcstr, changedline) in [("moveupcube!", :(x+=1)),
                                ("movedowncube!", :(x-=1)),
                                ("moverightcube!", :(y+=1)),
                                ("moveleftcube!", :(y-=1))]
    funcname = Symbol(funcstr)
    @eval begin
      function ($funcname)(grid::KcubeGrid, cube::Kcube)
        x,y,z = deepcopy(cube.position)
        $changedline
        if (all([1,1,1] .<= [x,y,z] .<= [grid.size...]) &&
          is(grid.grid[x,y,z].cube , KCUBE_NOCUBE));
            grid.grid[x,y,z].cube = cube;
            grid.grid[cube.position...].cube = KCUBE_NOCUBE;
            cube.position = (x, y, z);
            push!(grid.boardevents,($funcstr, cube, true))
            return true;
        else
            push!(grid.boardevents,($funcstr, cube, false))
            return false;
        end
      end#function
    end#block
  end#for
  

  """
      type Cursor

  The controled element in the game.
  """
  type Cursor
  
    position::Tuple{Integer,Integer,Integer}
    cube::Kcube
    grid::KcubeGrid

    function Cursor(grid::KcubeGrid, position::Tuple{Integer,Integer,Integer})
      cube = grid.grid[position...].cube
      if !is(cube, KCUBE_NOCUBE)
        return new(position, cube, grid)
      else
        assert(false) #TODO can do better here
      end#if
    end#function Cursor
  
    function Cursor(grid::KcubeGrid, cube::Kcube)
      position = cube.position
      assert(cube in grid.cubes)
      if !is(cube, KCUBE_NOCUBE)
        return new(position, cube, grid)
      else
        assert(false) #TODO can do better here
      end#if
    end#function Cursor

  end#type Cursor
  
  # create moveupcursor!, movedowncursor!, moverightcursor!, moveleftcursor!
  for (name, changedline ) in [("up", :(x+=1)),
                               ("down", :(x-=1)),
                               ("right", :(y+=1)),
                                ("left", :(y-=1))]
    funcstr = string("move",name,"cursor!")
    funcname = Symbol(funcstr)
    movecube = Symbol(string("move",name,"cube!")) 
    rotatecube = Symbol(string("rotate",name,"cube!")) 
    @eval begin
      function ($funcname)(cursor::Cursor)
        grid = cursor.grid
        x, y, z = deepcopy(cursor.position)
        $changedline
        if (all([1,1,1] .<= [x,y,z] .<= [grid.size...]))
          if $movecube(grid, cursor.cube)
            cursor.position = (x,y,z)
            $rotatecube(cursor.cube)
            push!(grid.boardevents, ($funcstr, cursor.cube, true) )
            return true
          else
            cursor.position = (x,y,z)
            cursor.cube = grid.grid[x,y,z].cube
            push!(grid.boardevents, ($funcstr, cursor.cube, true) )
          end#if
          push!(grid.boardevents, ($funcstr, cursor.cube, false) )
        end#if
      end#function moveupcursor!
    end#block
  end#for

end#module Board
