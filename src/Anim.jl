module Anim

using GeometryTypes
using GLAbstraction
  
  """
      type GLobj
        
          targetmodel::Mat{4,4,Float32}
          lastmodel::Mat{4,4,Float32}
          targetime::Integer
          lasttime::Integer

  Object containing model matrices.

  """

  const IDENTITYMAT = ga.rotationmatrix_x(Float32(0.))

  type GLobj
    targetmodel::Mat{4,4,Float32}
    lastmodel::Mat{4,4,Float32}
    targetime::Float64# time() return Float64
    lasttime::Float64
    interpolation::Function

    function GLobj()
      new(IDENTITYMAT, IDENTITYMAT, 0., 0., linearanim)
    end#function GLobj
  end#type GLcube

  # globj, movematrix, time for the animation
  globaleventstack = Array{Tuple{GLobj, Mat{4,4,Float32}, Float64},1}

  const CUBE_SIZE = Float32(1.)
  
  const MOVECUBEUPMAT = translationmatrix_x(CUBE_SIZE) *
                        rotationmatrix_x(Float32(pi/2.))
  const MOVECUBEDOWNMAT = translationmatrix_x(-CUBE_SIZE) *
                          rotationmatrix_x(Float32(-pi/2.))
  const MOVECUBELEFTMAT = translationmatrix_y(-CUBE_SIZE) *
                          rotationmatrix_y(Float32(-pi/2.))
  const MOVECUBERIGHTMAT = translationmatrix_y(CUBE_SIZE) *
                           rotationmatrix_y(Float32(pi/2.))

  const MOVETIME = 1.
  const ACCELERATION = 2./3.

  function glmoveobj(globj::GLobj,
                     movematrix::Mat{4,4,Float32},
                     movetime::Float64,
                     curtime::Float64)#time in s

    if curtime >= globj.targetime #No animation pending
      globj.lastmodel = globj.targetmodel
      globj.targetmodel = movematrix * globj.targetmodel
      globj.lasttime = curtime
      globj.targettime = curtime + movetime
    else # Animation still pending, accelerating it and push-delay a new anim in stack
      Δtime = ACCELERATION * (targettime - curtime) #time to finish animation
      Δpast = ACCELERATION * (curtime - globj.lasttime)
      globj.lasttime = curtime - Δpast #the relative position in animation mustn't change
      globj.targettime = curtime + Δtime
      event = (globj, movematrix, ACCELERATION * movetime)
      push!(globaleventstack, event)
    end#if

  end#function glmoveup

  function linearanim(globj::GLobj, curtime::Float64)
    if curtime >= targettime
      return globj.targetmodel
    else
      λ = (curtime - globj.lasttime )/(globj.targettime - globj.lasttime)
      return λ*globj.lastmodel + (1. - λ)* globj.targetmodel
    end#if
  end#function linearanim

end#module Anim
