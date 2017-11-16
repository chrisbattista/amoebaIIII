

vector = require 'vector'

require 'constants'
lifeEntity = require 'lifeEntity'





Globule = {}
Globule.__index = Globule
setmetatable(Globule, {__index=LifeEntity})

function Globule.new(parent, tag, pos, args)
  local o = LifeEntity.new(parent, tag)
  setmetatable(o, Globule)

  o.Body = love.physics.newBody(World, pos.x, pos.y, "dynamic")
  o.Shape = love.physics.newCircleShape(args.radius or STANDARD_GLOBULE_RADIUS)
  o.Fixture = love.physics.newFixture(o.Body, o.Shape)
  o.Fixture:setRestitution(0.9)

  o.MembraneThickness = args['mThickness'] or STANDARD_MEMBRANE_THICKNESS
  o.MembraneColor = args.mColor or {0, 204, 102, 255}
  o.FillColor = args.fColor or {102, 255, 178, 155}
  o.Fidelity = args['fidelity'] or STANDARD_CIRCLE_FIDELITY

  o.Qualities['physical'] = true
  o.Qualities['drawable'] = true

  return o
end


function Globule:draw()
  local ap = vector.new(self.Body:getX(), self.Body:getY())
  local rad = self.Shape:getRadius()
  love.graphics.setColor(unpack(self.FillColor))
  love.graphics.setLineWidth(self.MembraneThickness)
  love.graphics.circle("line", ap.x, ap.y, rad, self.Fidelity)
  love.graphics.setColor(unpack(self.MembraneColor))
  love.graphics.circle("fill", ap.x, ap.y, rad, self.Fidelity)
end

function Globule:destroy()
  self.Fixture:destroy()
  self.Body:destroy()
  LifeEntity.destroy(self)
end

function Globule:getRoughPosition()
  return vector(self.Body:getPosition())
end

function Globule:__tostring()
  return "Globule id=" .. self.Id
end
