using Kcube
using Base.Test

grid = Board.KcubeGrid( (10,10,1) )

@test isa(grid,Board.KcubeGrid)

@test !Bool(Board.addcube!(grid, (5,5,2)))#out of grid limit
@test 1 == Board.addcube!(grid, (5,5,1))#normal return id
@test 0 == Board.addcube!(grid, (5,5,1))#can't overwrite cube 
@test 2 == Board.addcube!(grid,(10,10,1))#on the line

cube1 = grid.grid[5,5,1].cube
cube2 = grid.grid[10,10,1].cube

@test Board.moveupcube!(grid, cube1)
@test !Board.moveupcube!(grid, cube2)

