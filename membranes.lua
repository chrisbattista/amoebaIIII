


ProFi = require 'ProFi'

vector = require 'vector'

require 'constants'
lifeEntity = require 'lifeEntity'




RigidMembrane = {}
RigidMembrane.__index = RigidMembrane
setmetatable(RigidMembrane, {__index=LifeEntity})

function RigidMembrane.new(parent, tag, pos, args)
  local o = LifeEntity.new(parent, tag)
  setmetatable(o, RigidMembrane)

  local radius = args['radius'] or STANDARD_CELL_RADIUS
  local segments = args['segments'] or STANDARD_CIRCLE_FIDELITY
  local thickness = args['thickness'] or STANDARD_MEMBRANE_THICKNESS

  o.MembraneThickness = thickness
  o.MembraneColor = args['mColor'] or {240, 50, 50}


  o.Body = love.physics.newBody(World, pos.x, pos.y, "dynamic")

  local v = vector.new(0, radius)

  o.Shape = {}
  for i=0,segments-1 do
    local v1inner = v:rotated(2*math.pi/segments*i)
    local p1outer = v1inner + v1inner:normalized() * thickness
    local p1inner = v1inner

    local v2inner = v:rotated(2*math.pi/segments*(i+1))
    local p2outer = v2inner + v2inner:normalized() * thickness
    local p2inner = v2inner

    local s = love.physics.newPolygonShape(p1inner.x, p1inner.y, p1outer.x, p1outer.y, p2outer.x, p2outer.y, p2inner.x, p2inner.y)
    table.insert(o.Shape, s)

  end

  o.Fixture = {}
  for k, s in pairs(o.Shape) do
    table.insert(o.Fixture, love.physics.newFixture(o.Body, s))
  end


  o.Qualities['physical'] = true
  o.Qualities['drawable'] = true

  return o
end


function RigidMembrane:draw()
  local offset = vector(self.Body:getX(), self.Body:getY())

  love.graphics.setColor({255, 255, 255, 255})
  love.graphics.circle("line", offset.x, offset.y, 5, 20)     --    DEBUG CENTER PT

  love.graphics.setColor(unpack(self.MembraneColor))
  for k, seg in pairs(self.Shape) do
    local ps = {seg:getPoints()}
    local ops = {}
    for i=1,#ps,2 do
      local ov = (vector(ps[i],ps[i+1]):rotated(self.Body:getAngle()) + offset)
      table.insert(ops, ov.x)
      table.insert(ops, ov.y)
    end

    love.graphics.polygon("fill", unpack(ops))
  end

end

function RigidMembrane:getRoughPosition()
  return vector(self.Body:getX(), self.Body:getY())
end

function RigidMembrane:destroy()
  self.Fixture:destroy()
  LifeEntity.destroy(self)  --   NOT DONE!!!!!  <<<<<<<<<<
end

function RigidMembrane:__tostring()
  return "RigidMembrane id=" .. self.Id
end












DeformableMembrane = {}
DeformableMembrane.__index = DeformableMembrane
setmetatable(DeformableMembrane, LifeEntity)

function DeformableMembrane.new(parent, tag, pos, args)
  local o = LifeEntity.new(parent, tag)
  setmetatable(o, DeformableMembrane)

  DeformableMembrane.setupFields(o, parent, tag, pos, args)
  DeformableMembrane.setupBody(o, pos, args)
  o.JointLength = (args['thickness'] or STANDARD_JOINT_LENGTH) / (2 * (args['segments'] or STANDARD_CIRCLE_FIDELITY) )
  DeformableMembrane.setupJoints(o, pos, o.JointLength, args)

  return o

end

function DeformableMembrane.newFromExisting(existing, start, stop)
  local o = LifeEntity.new(parent, tag)
  setmetatable(o, DeformableMembrane)

  local args = existing:PackUpArgs()

  DeformableMembrane.setupFields(o, existing.Parent, existing.Tag.." child", existing:getRoughPosition(), args)
  DeformableMembrane.setBodyAndJoints(o, existing, start, stop, args)

  return o
end

function DeformableMembrane.setupFields(o, parent, tag, pos, args)

  o.Damping = args['damping'] or STANDARD_MEMBRANE_DAMPING
  o.Segments = args['segments'] or STANDARD_CIRCLE_FIDELITY
  o.MembraneThickness = args['thickness'] or STANDARD_MEMBRANE_THICKNESS
  o.MembraneColor = args['mColor'] or {240, 50, 50}
  o.Pressure = args['pressure'] or STANDARD_CELL_PRESSURE

  o.Qualities['physical'] = true
  o.Qualities['drawable'] = true
  o.Qualities['mental'] = true

  o.MembraneContinuous = true

  return o
end

function DeformableMembrane.setupBody(o, pos, args)

  local radius = args['radius'] or STANDARD_CELL_RADIUS
  local segments = args['segments'] or STANDARD_CIRCLE_FIDELITY
  local thickness = args['thickness'] or STANDARD_MEMBRANE_THICKNESS
  local damping = args['damping'] or STANDARD_MEMBRANE_DAMPING

  local v = vector.new(0, radius)
  o.SegmentLength = 2*radius*math.tan(math.pi/segments)
  local sl = o.SegmentLength

  o.Body = {}
  o.LastBodyAngle = {}
  o.Shape = {}
  o.Fixture = {}
  for i=1,segments do
    local vp = v:rotated(2*math.pi/segments*i)
    o.Shape[i] = love.physics.newRectangleShape(sl, thickness)
    o.Body[i] = love.physics.newBody(World, vp.x, vp.y, "dynamic")
    o.Body[i]:setLinearDamping(damping)
    o.Fixture[i] = love.physics.newFixture(o.Body[i], o.Shape[i])
    o.Body[i]:setAngle(vp:angleTo()-math.pi/2)
  end

  for i=1,#o.Body do
    local p = vector(o.Body[i]:getPosition()) + pos
    o.Body[i]:setPosition(p.x, p.y)
  end
end

function DeformableMembrane.setupJoints(o, pos, jointLength, args)

  local radius = args['radius'] or STANDARD_CELL_RADIUS
  local segments = args['segments'] or STANDARD_CIRCLE_FIDELITY
  local thickness = args['thickness'] or STANDARD_MEMBRANE_THICKNESS

  local sl = 2*radius*math.tan(math.pi/segments)

  o.Joints = {}
  for i=1,segments do
    local j
    if i==1 then
      j = segments
    else
      j = i-1
    end
    local cp1 = vector(o.Body[i]:getX(), o.Body[i]:getY())
    local cp2 = vector(o.Body[j]:getX(), o.Body[j]:getY())
    local ep1 = cp1 - (vector(-1, 0) * sl/2):rotated(o.Body[i]:getAngle())
    local ep2 = cp2 - (vector(1, 0) * sl/2):rotated(o.Body[j]:getAngle())
    o.Joints[i] = love.physics.newDistanceJoint(o.Body[i], o.Body[j], ep1.x, ep1.y, ep2.x, ep2.y, false)
    o.Joints[i]:setDampingRatio(STANDARD_MEMBRANE_DAMPING or 0.2)
    o.Joints[i]:setFrequency(STANDARD_MEMBRANE_FREQUENCY or 10)
    o.Joints[i]:setLength(jointLength)
  end

  return o
end

function DeformableMembrane.setupJointsV2(o, jointLength, args)
  return o
end

function DeformableMembrane.setBodyAndJoints(o, existing, start, stop, args)
  o.Body = existing:giveSegments(start, stop)
  DeformableMembrane.setupJointsV2(o, existing.JointLength, args)
  return o

end

function DeformableMembrane:giveSegments(start, stop)
  
end

function DeformableMembrane:packUpArgs()
  return {
    segments = self.Segments,
    thickness = self.MembraneThickness,
    damping = self.MembraneDamping
  }
end

function DeformableMembrane:draw()

  love.graphics.setLineJoin("bevel")
  love.graphics.setLineWidth(self.MembraneThickness)

  if self.MembraneContinuous then
    local drawPts = {}
    for i=1,#self.Joints do
      local x1, y1, x2, y2 = self.Joints[i]:getAnchors()
      table.insert(drawPts, (x1+x2)/2)
      table.insert(drawPts, (y1+y2)/2)
    end
    table.insert(drawPts, drawPts[1])
    table.insert(drawPts, drawPts[2])

    love.graphics.setColor(unpack(self.MembraneColor))
    love.graphics.line(unpack(drawPts))
  else
    for i=1,#self.Body do
      local b = self.Body[i]
      local cp = vector(b:getX(), b:getY())
      local ep1 = cp - (vector(-1, 0) * self.SegmentLength/2):rotated(b:getAngle())
      local ep2 = cp - (vector(1, 0) * self.SegmentLength/2):rotated(b:getAngle())
      love.graphics.line(ep1.x, ep1.y, ep2.x, ep2.y)
    end
  end

  if DEBUG_GRAPHICS_ON then
    self:debugDraw()
  end
end

function DeformableMembrane:debugDraw()
    love.graphics.setLineWidth(1)
    for i=1, #self.Shape do
      local offset = vector(self.Body[i]:getX(), self.Body[i]:getY())

      local ps = {self.Shape[i]:getPoints()}
      local ops = {}
      for j=1,#ps,2 do
        local ov = vector(ps[j],ps[j+1]):rotated(self.Body[i]:getAngle()) + offset
        table.insert(ops, ov.x)
        table.insert(ops, ov.y)
      end

      love.graphics.setColor(unpack(self.MembraneColor))
      love.graphics.polygon("fill", unpack(ops))
      love.graphics.setColor({255, 0, 0, 255})              --
      love.graphics.circle("line", offset.x, offset.y, 5, 20)   -- DEBUG
    end

    for i=1,#self.Joints do
      local x1, y1, x2, y2 = self.Joints[i]:getAnchors()
      love.graphics.setColor({0, 0, 255, 255})
      love.graphics.circle("line", x1, y1, 5, 20)   -- debug
      love.graphics.circle("line", x2, y2, 5, 20)   -- debug
      love.graphics.line(x1, y1, x2, y2)
    end

    -- love.graphics.setColor({255, 255, 255, 255})               --
    -- love.graphics.circle("line", offset.x, offset.y, 5, 20)     --    DEBUG CENTER PT

end


function DeformableMembrane:think(dt)
  --print(tostring(self).." thought")

  for k,v in pairs(self.ComponentsById) do
    if (v.hasQuality('mental')) then v.think(dt) end
  end

  if self.Thought%20 == 0 then
    local e = #self.Joints
    local i = 1
    while i<=e do
      local b1, b2 = self.Joints[i]:getBodies()
      if vector(b1:getPosition()):dist(vector(b2:getPosition())) > self.SegmentLength*STANDARD_MEMBRANE_BREAKAGE_FACTOR then
        self.Joints[i]:destroy()
        table.remove(self.Joints, i)
        self.MembraneContinuous = false
        e =  e -1
      else i = i + 1 end
    end
  end
    if self.MembraneContinuous then
      for i=1,#self.Body do
        j = self.Body[i]
        li = self.LastBodyAngle[i] or j:getAngle()
        local a = (j:getAngle()+li*STANDARD_MEMBRANE_ANGLE_AVERAGE_WEIGHT)
        --a = a + ((self.Body[i+1] or self.Body[1]):getAngle() + (self.Body[i-1] or self.Body[#self.Body]):getAngle())
        a = a / (STANDARD_MEMBRANE_ANGLE_AVERAGE_WEIGHT+1)

        self.LastBodyAngle[i] = a
        local v = vector(self.Pressure, 0):rotated(a + math.pi/2)*dt
        j:applyForce(v.x, v.y)
        --print("applied"..tostring(v))
      end
    end
end


function DeformableMembrane:getRoughPosition()
  return vector(self.Body[1]:getPosition())
end


function DeformableMembrane:destroy()
  for k,v in pairs(self.Fixture) do
    v:destroy()
  end
  LifeEntity.destroy(self)
end

function DeformableMembrane:__tostring()
  return "DeformableMembrane id=" .. self.Id
end

function DeformableMembrane:boop()
end

--
