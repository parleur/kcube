using Kcube
using Base.Test

grid = Board.KcubeGrid( (10,10,1) )

@test isa(grid,Board.KcubeGrid)

@test !Bool(Board.addcube!(grid, (5,5,2)))#out of grid limit
@test 1 == Board.addcube!(grid, (5,5,1))#normal return id
@test 0 == Board.addcube!(grid, (5,5,1))#can't overwrite cube 
@test 2 == Board.addcube!(grid,(10,10,1)) #on the top line
@test 3 == Board.addcube!(grid,(5,10,1))  #on the right line
@test 4 == Board.addcube!(grid,(5,1,1))   #on the left line
@test 5 == Board.addcube!(grid,(1,5,1))   #on the bottom line

#middle cube
cube1 = grid.grid[5,5,1].cube
#top cube
cube2 = grid.grid[10,10,1].cube
#right cube
cube3 = grid.grid[5,10,1].cube
#left cube
cube4 = grid.grid[5,1,1].cube
#bottom cube
cube5 = grid.grid[1,5,1].cube

@test Board.moveupcube!(grid, cube1)
@test !Board.moveupcube!(grid, cube2)
@test Board.movedowncube!(grid, cube1)
@test !Board.movedowncube!(grid, cube5)
@test Board.moverightcube!(grid, cube1)
@test !Board.moverightcube!(grid, cube3)
@test Board.moveleftcube!(grid, cube1)
@test !Board.moveleftcube!(grid, cube4)

cursor = Board.Cursor(grid, cube1)
@test Board.moveupcursor!(cursor)
@test Board.movedowncursor!(cursor)
@test Board.moverightcursor!(cursor)
@test Board.moveleftcursor!(cursor)

Kcube.main()
