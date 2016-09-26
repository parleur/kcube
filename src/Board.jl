module Board
  
  const CUBE_NORMAL = 0  
    
  # Arbitrary colors (coresponding with a cube on my desktop)
  # The order depart from a face, going altenatively bottom then right (and so on ..)
  const FACE_RED = 1
  const FACE_BLUE = 2
  const FACE_GREY = 3
  const FACE_YELLOW = 4
  const FACE_GREEN = 5
  const FACE_BLACK = 6

  type Kcube
  
    cubeid::Integer
    cubetype::Integer
    position::Tuple{Integer, Integer, Integer}#position
    orientation::Tuple{Integer, Integer}#first the top face, then the front face

    function Kcube(cubeid::Integer, position::Tuple{Integer, Integer, Integer})
      new(cubeid, CUBE_NORMAL, position, (FACE_RED, FACE_BLUE))
    end#function Kcube
  
  end#type Kcube

  const KCUBE_NOCUBE = Kcube(0, (0,0,0))
  
  const SQUARE_NORMAL = 0

  type Ksquare

    casetype::Integer
    cube::Kcube
    function Ksquare()
      new( SQUARE_NORMAL, KCUBE_NOCUBE )
    end#function Ksquare

  end#type Ksquare

  function ksquaregetcube!(square::Ksquare, cube::Kcube)
    if is(square.cube,KCUBE_NOCUBE)
      square.cube = cube
      return true#true if no error
    else
      return false
    end#if
  end#function ksquaregetcube

  type KcubeGrid
    
    cubenb::Integer
    grid::Array{Ksquare, 3}# coordinate, 
    cubes::Array{Kcube,1} #Direct reference to the cubes
    size::Tuple{Integer,Integer,Integer}

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
      new(0, grid, cubes, size)
    end#function KcubeGrid
  
  end#type KcubeGrid

  function addcube!(grid::KcubeGrid, position::Tuple{Integer,Integer,Integer})
    if all( [1,1,1] .<= [position...] & [position...] .<= [grid.size...])
      cubeid = length(grid.cubes) + 1
      cube = Kcube( cubeid, position )
      square = grid.grid[position...]
      if ksquaregetcube!(square, cube)#Square accept the cube
        push!(grid.cubes,cube)
        return cubeid
      else
        return 0#error
      end#if
    else  
      return 0#cubeid null means error
    end#if
  end#function addcube

  export(addcube!)
  
  const UP = UInt8(1)
  const DOWN = UInt8(2)
  const RIGHT = UInt8(3)
  const LEFT = UInt8(4)

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

  template = :(function (grid::KcubeGrid, cube::Kcube) #1
    x,y,z = cube.position
    x +=1 # target position
    lx,ly,lz = grid.size  
    lx -= 1 # limit
    if (cube.position > (0, 0, 0)) &
      (cube.position <= (lx,ly,lz))
      if is(grid.grid[x,y,z].cube , KCUBE_NOCUBE)
        grid.grid[x,y,z].cube = cube
        grid.grid[x,y,z].cube = KCUBE_NOCUBE
        cube.position = (x, y, z)
        return true
      end#if
    end#if
    return false
  end#function
 )
  
  ex1 = copy(template)
  moveupcube! = eval(ex1)

  ex2 = copy(template)
  ex2.args[2].args[2] = :( x-=1 )
  ex2.args[2].args[4] = :( lx+=1 )
  movedowncube! = eval(ex2)

  ex3 = copy(template)
  ex3.args[2].args[2] = :( y+=1 )
  ex3.args[2].args[4] = :( ly -= 1)
  moverightcube! = eval(ex3)

  ex4 = copy(template)
  ex4.args[2].args[2] = :( y-=1 )
  ex4.args[2].args[4] = :( ly += 1)
  moveleftcube! = eval(ex4)

end#module Board
