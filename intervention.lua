





Poker = {}
Poker.__index = Poker
setmetatable(Poker, {__index=Entity})

function Poker:new(radius)
  radius = radius or STANDARD_GLOBULE_RADIUS

  o = {}
  setmetatable(o, Poker)

  o.Body = love.physics.newBody(World, 0, 0, 'dynamic')
  o.Shape = love.physics.newCircleShape(radius)
  o.Fixture = love.physics.newFixture(o.Body, o.Shape)

  o.Body:setActive(false)

  return o
end

function Poker:mouseEvent(type)
end
