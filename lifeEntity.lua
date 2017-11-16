





LifeEntity = {}
LifeEntity.__index = LifeEntity
setmetatable(LifeEntity, Entity)

function LifeEntity.new(parent, tag)
  local o = Entity.new(parent, tag)
  setmetatable(o, LifeEntity)

  return o
end

function LifeEntity:getDrawables()
  return self.ComponentsByQuality['drawable']
end


function LifeEntity:draw()
  --print("drawin")
  for i, comp in pairs(self.ComponentsByQuality['drawable'] or {}) do
    --print("drawing "..tostring(comp))
    comp:draw()
  end
end

function LifeEntity:getRoughPosition()
  if self.ComponentsById then
    for k,v in pairs(self.ComponentsById) do
      return v:getRoughPosition()
    end
  end
end

function LifeEntity:__tostring()
  return "LifeEntity, ID="..tostring(self.Id)
end






--
