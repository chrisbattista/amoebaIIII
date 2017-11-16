
require 'constants'

require 'membranes'
require 'particles'

vector = require 'vector'

function randomGlobule()
  local a = {}
  a['mColor'] = {math.random(50, 255), math.random(50, 255), math.random(50, 255), math.random(100, 255)}
  a['fColor'] = {math.random(50, 255), math.random(50, 255), math.random(50, 255), math.random(100, 255)}
  a['radius'] = math.random(STANDARD_GLOBULE_RADIUS/CONSTRUCTION_TOOLS_RANDOM_FACTOR, STANDARD_GLOBULE_RADIUS*CONSTRUCTION_TOOLS_RANDOM_FACTOR)
  a['fidelity'] = math.random(1, STANDARD_CIRCLE_FIDELITY*CONSTRUCTION_TOOLS_RANDOM_FACTOR)
  return a
end

function randomRigidMembrane()
  local a = {}
  a['mColor'] = {math.random(50, 255), math.random(50, 255), math.random(50, 255), math.random(100, 255)}
  a['radius'] = math.random(STANDARD_CELL_RADIUS/CONSTRUCTION_TOOLS_RANDOM_FACTOR, STANDARD_CELL_RADIUS*CONSTRUCTION_TOOLS_RANDOM_FACTOR)
  a['thickness'] = math.random(STANDARD_MEMBRANE_THICKNESS/CONSTRUCTION_TOOLS_RANDOM_FACTOR, STANDARD_MEMBRANE_THICKNESS*CONSTRUCTION_TOOLS_RANDOM_FACTOR)
  a['segments'] = STANDARD_CIRCLE_FIDELITY
  return a
end

function randomDeformableMembrane()
  local a = {}
  a['mColor'] = {math.random(50, 255), math.random(50, 255), math.random(50, 255), math.random(100, 255)}
  a['radius'] = math.random(STANDARD_CELL_RADIUS/CONSTRUCTION_TOOLS_RANDOM_FACTOR, STANDARD_CELL_RADIUS*CONSTRUCTION_TOOLS_RANDOM_FACTOR)
  a['thickness'] = math.random(STANDARD_MEMBRANE_THICKNESS/CONSTRUCTION_TOOLS_RANDOM_FACTOR, STANDARD_MEMBRANE_THICKNESS*CONSTRUCTION_TOOLS_RANDOM_FACTOR)
  a['segments'] = STANDARD_CIRCLE_FIDELITY
  a['pressure'] = math.random(STANDARD_CELL_PRESSURE/CONSTRUCTION_TOOLS_RANDOM_FACTOR, STANDARD_CELL_PRESSURE*CONSTRUCTION_TOOLS_RANDOM_FACTOR)
  return a
end



function constructRigidCell(pos)
  local lf = LifeEntity.new(Root, 'billybob')
  local args = randomRigidMembrane()
  lf:add(RigidMembrane.new(lf, 'memby', pos, args))
  for i=1,math.random(1, 5) do
    local g = Globule.new(lf, '', pos+vector(math.random(-args['radius']/1.5, args['radius']/1.5), math.random(-args['radius']/1.5, args['radius']/1.5)), randomGlobule())
    g.Body:setLinearVelocity(math.random(-130*CONSTRUCTION_TOOLS_RANDOM_FACTOR, 130*CONSTRUCTION_TOOLS_RANDOM_FACTOR), math.random(-130*CONSTRUCTION_TOOLS_RANDOM_FACTOR, 130*CONSTRUCTION_TOOLS_RANDOM_FACTOR))
    Root:add(g)
  end
  lf:getByTag('memby').Body:setAngularVelocity(math.random(-0.2, 0.2))
  lf:getByTag('memby').Body:setLinearVelocity(math.random(-10, 10), math.random(-10, 10))
  Root:add(lf)
end


function constructDeformableCell(pos)
  local lf = LifeEntity.new(Root, 'topolocillus')
  local args = randomDeformableMembrane()
  lf:add(DeformableMembrane.new(lf, 'membrane', pos, args))
  --print("made a "..tostring(lf).." tag="..tostring(lf.Tag))
  for i=1,math.random(1, 5) do
    local g = Globule.new(lf, 'glucose', pos+vector(math.random(-args['radius']/1.5, args['radius']/1.5), math.random(-args['radius']/1.5, args['radius']/1.5)), randomGlobule())
    g.Body:setLinearVelocity(math.random(-130*CONSTRUCTION_TOOLS_RANDOM_FACTOR, 130*CONSTRUCTION_TOOLS_RANDOM_FACTOR), math.random(-130*CONSTRUCTION_TOOLS_RANDOM_FACTOR, 130*CONSTRUCTION_TOOLS_RANDOM_FACTOR))
    Root:add(g)
  end
  --lf:getByTag('memby').Body:setAngularVelocity(math.random(-0.2, 0.2))
  --lf:getByTag('memby').Body:setLinearVelocity(math.random(-10, 10), math.random(-10, 10))
  Root:add(lf)
  --print(lf:hasQuality("drawable"))
  --print("lf cbq=")
  --for k,v in pairs(lf.ComponentsByQuality) do
  --  print(k..": "..tostring(v))
  --end
end








--
