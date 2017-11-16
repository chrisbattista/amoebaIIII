

require 'entity'
require 'lifeEntity'
require 'particles'
require 'membranes'
require 'constructionTools'

vector = require 'vector'
Camera = require 'camera'
require 'timer'



ProFi = require 'ProFi'
proFiEnabled = false

loops = 0
simTimeElapsed = 0
wallTimeElapsed = 0
speed = 0

lastSpawn = 0




function love.load()

  math.randomseed(6545538)

  Cam = Camera(0, 0)
  Root = LifeEntity.new(nil, 'root')
  World = love.physics.newWorld(0, 0, true)

  love.physics.setMeter(100)
  love.keyboard.setKeyRepeat(true)

  for i=1,math.random(100) do
    constructDeformableCell(vector(math.random(-BOUNDS_RADIUS/1.2, BOUNDS_RADIUS/1.2),
                                    math.random(-BOUNDS_RADIUS/1.2, BOUNDS_RADIUS/1.2)))
  end
  -- for i=1,math.random(1) do
  --   constructRigidCell(vector(math.random(-BOUNDS_RADIUS/1.2, BOUNDS_RADIUS/1.2),
  --                                 math.random(-BOUNDS_RADIUS/1.2, BOUNDS_RADIUS/1.2)))
  -- end

end

function oneStep(t)
  World:update(t)
  for id, lf in pairs(Root:getComponents()) do

    --lf:boop()
    local a = true
    -- if (lf:hasQuality('physical')) then
    --   local v = lf:getRoughPosition()
    --   if (v.x > BOUNDS_RADIUS or v.x < -(BOUNDS_RADIUS)
    --   or v.y > BOUNDS_RADIUS or v.y < -(BOUNDS_RADIUS)) then
    --     Root:destroyComponent(lf)
    --     a = false
    --     print(v)
    --   end
    -- end
    if (loops%THINK_PERIOD==0 and a and (lf:hasQuality('mental'))) then
      --print("tried ':think' on "..lf:__tostring())
      --print(dt*speed/100)
      lf:think(t*THINK_PERIOD)
    end
  end
end

function love.update(dt)

  if loops%10 == 0 then collectgarbage() end

  for i=1,speed do
    oneStep(1/60)
  end


  if love.keyboard.isDown("=") then
    Cam:zoom(CAM_ZOOM_SPEED)
  end
  if love.keyboard.isDown("-") then
    Cam:zoom(1/CAM_ZOOM_SPEED)
  end
  if love.keyboard.isDown("a") then
    Cam:move(-CAM_PAN_SPEED/Cam.scale,0)
  end
  if love.keyboard.isDown("d") then
    Cam:move(CAM_PAN_SPEED/Cam.scale,0)
  end
  if love.keyboard.isDown("w") then
    Cam:move(0,-CAM_PAN_SPEED/Cam.scale)
  end
  if love.keyboard.isDown("s") then
    Cam:move(0,CAM_PAN_SPEED/Cam.scale)
  end
  if love.keyboard.isDown("]") then
    speed = speed + 1
  end
  if love.keyboard.isDown("[") then
    speed = speed - 1
    if speed < 0 then speed = 0 end
  end
  if love.keyboard.isDown("\\") then
    speed = 1
  end
  if love.keyboard.isDown("r") then
    speed = 1
    Cam.scale = 1
    Cam:lookAt(0,0)
  end
  if proFiEnabled == false and love.keyboard.isDown("p") then
    ProFi:start()
    proFiEnabled = true
  end
  if love.keyboard.isDown("g") then
    DEBUG_GRAPHICS_ON = not DEBUG_GRAPHICS_ON
  end

  loops = loops + 1
  simTimeElapsed = simTimeElapsed + speed/60
  wallTimeElapsed = wallTimeElapsed + dt

end

function love.draw()

  Cam:attach()
  Root:draw()
  Cam:detach()

  love.graphics.setLineWidth(1)

  love.graphics.setColor(255, 255, 255, 150)
  love.graphics.print("fps "..love.timer.getFPS(), 10, 10)
  love.graphics.print("sim speed "..speed.."x", 10, 30)
  love.graphics.print("physics bodies "..World:getBodyCount(), 10, 50)
  love.graphics.print("scale "..Cam.scale.."x", 10, 70)

  love.graphics.print(string.format("wall clock time: %.4fs", wallTimeElapsed), 10, love.graphics.getHeight()-20)
  love.graphics.print(string.format("sim clock time: %.4fs", simTimeElapsed), 10, love.graphics.getHeight()-40)

  love.graphics.circle("line", love.graphics.getWidth()/2, love.graphics.getHeight()/2, 5, 20)

end


function love.quit()
  if (proFiEnabled) then
    ProFi:stop()
    ProFi:writeReport("profile.txt")
  end
  return false
end
