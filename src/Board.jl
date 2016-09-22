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
    cubeposition::Tuple{Integer, Integer, Integer}#position
    cubeconfiguration::Tuple{Integer, Integer}#first the top face, then the front face

    function Kcube(cubeid::Integer, cubeposition::Tuple{Integer, Integer, Integer})
      new(cubeid, CUBE_NORMAL, cubeposition, (FACE_RED, FACE_BLUE))
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

  export(addcube)
end#module Board
