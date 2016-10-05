module Anim

import GeometryTypes
import GLAbstraction
import Quaternions

const gt = GeometryTypes
const ga = GLAbstraction
const quat = Quaternions
  
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
    targetmodel::gt.Mat{4,4,Float32}
    lastmodel::gt.Mat{4,4,Float32}
    targettime::Float64# time() return Float64
    lasttime::Float64
    interpolation::Function

    function GLobj()
      new(IDENTITYMAT, IDENTITYMAT, 1., 1., linearanim)
    end#function GLobj
  end#type GLcube

  # globj, movematrix, time for the animation
  AnimEvents = Array{Tuple{GLobj, gt.Mat{4,4,Float32}, Float64},1}

  const CUBE_SIZE = Float32(2.2)
  const CURSORALT = Float32(-3.)
  
  const MOVEUPMAT = ga.translationmatrix_x(CUBE_SIZE)
  const MOVEDOWNMAT = ga.translationmatrix_x(-CUBE_SIZE)
  const MOVELEFTMAT = ga.translationmatrix_y(-CUBE_SIZE)
  const MOVERIGHTMAT = ga.translationmatrix_y(CUBE_SIZE)
  const MOVETOPMAT = ga.translationmatrix_z(CUBE_SIZE)
  const MOVEBOTTOMMAT = ga.translationmatrix_z(CUBE_SIZE)

  const ROTATEUPQUA = quat.qrotation(Array{Float32}([0.,1.,0.]), Float32(-pi/2.))
  const ROTATEDOWNQUA = quat.qrotation(Array{Float32}([0.,1.,0.]), Float32(pi/2.))
  const ROTATELEFTQUA = quat.qrotation(Array{Float32}([1.,0.,0.]), Float32(-pi/2.))
  const ROTATERIGHTQUA = quat.qrotation(Array{Float32}([1.,0.,0.]), Float32(pi/2.))
  const ROTATETOPQUA = quat.qrotation(Array{Float32}([0.,0.,1.]), Float32(pi/2.))
  const ROTATEBOTTOMQUA = quat.qrotation(Array{Float32}([0.,0.,1.]), Float32(-pi/2.))

  const MOVETIME = 1.
  const ACCELERATION = 2./3.

  function glmoveobj!(globj::GLobj,
                     newtarget::gt.Mat{4,4,Float32},
                     movetime::Float64,
                     curtime::Float64,
                     animevents::AnimEvents)#time in s

    if curtime >= globj.targettime #No animation pending
      globj.lastmodel = globj.targetmodel
      globj.targetmodel = newtarget
      globj.lasttime = curtime
      globj.targettime = curtime + movetime
    else # Animation still pending, accelerating it and push-delay a new anim in stack
      Δtime = ACCELERATION * (globj.targettime - curtime) #time to finish animation
      Δpast = ACCELERATION * (curtime - globj.lasttime)
      globj.lasttime = curtime - Δpast #the relative position in animation mustn't change
      globj.targettime = curtime + Δtime
      event = (globj, newtarget, ACCELERATION * movetime)
      unshift!(animevents, event)
    end#if

  end#function glmoveup

  function linearanim(globj::GLobj, curtime::Float64)
    if curtime >= globj.targettime
      return globj.targetmodel
    else
      λ = (curtime - globj.lasttime )/(globj.targettime - globj.lasttime)
      return λ*globj.targetmodel + (1. - λ)* globj.lastmodel
    end#if
  end#function linearanim

end#module Anim
