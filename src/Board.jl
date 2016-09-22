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
  
  const CASE_NORMAL = 0

  type Kcase

    casetype::Integer
    cube::Integer#0 if void, cube index otherwise
    function Kcase()
      new( CASE_NORMAL, 0 )
    end#function Kcase

  end#type Kcase

  type KcubeGrid
    
    cubenb::Integer
    grid::Array{Kcase, 3}# coordinate, cubeid
    cubes::Array{Integer,1} #Direct reference to the cubes

    function KcubeGrid( x_size::Integer, y_size::Integer, z_size::Integer)
      grid = Array{Any}(x_size, y_size, z_size )
      for i in 1:x_size
        for j in 1:y_size
          for k in 1:z_size
            grid[i,j,k] = Kcase()
          end
        end
      end
      cubes = Array{Kcube}(0)
      new(0, grid, cubes)
    end#function KcubeGrid
  
  end#type KcubeGrid

end#module Board
