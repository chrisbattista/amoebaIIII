

nId = 0
function NextId()
  nId = nId+1
  return tostring(nId - 1)
end


Entity = {}
Entity.__index = Entity
setmetatable(Entity, {})

function Entity.new(parent, tag)
  local o = {}
  setmetatable(o, Entity)
  o.Id = NextId()
  o.Tag = tag
  o.Parent = parent
  o.Qualities = {}
  o.ComponentsById = {}
  o.ComponentsByTag = {}
  o.ComponentsByQuality = {}
  o.Destroyed = false

  o.Thought = 0

  return o;
end

function Entity:add(component)
  self.ComponentsById[component.Id] = component
  self.ComponentsByTag[component.Tag] = component
  for k,v in pairs(component:getQualities()) do
    if self.ComponentsByQuality[k] == nil then
      self.ComponentsByQuality[k] = {}
      --print("creating list of type "..tostring(k))
    end
    table.insert(self.ComponentsByQuality[k], component)
    --print(tostring(component).." has quality "..tostring(k))
  end
end

function Entity:destroy()
  for id, comp in pairs(self.ComponentsById) do
    comp:destroy()
  end
  print("destroyed " .. tostring(self))
  self.Destroyed = true
end

function Entity:destroyComponent(comp)
  self.ComponentsById[comp.Id] = nil
  self.ComponentsByTag[comp.Tag] = nil
  print("trying to purge "..tostring(comp))
  for k,v in pairs(comp:getQualities()) do
    print("checking quality "..k)
    for i = 1,#self.ComponentsByQuality[k] do
      if self.ComponentsByQuality[k][i] == comp then
        table.remove(self.ComponentsByQuality, i)
        print("removed "..tostring(comp).." from "..k)
      end
    end
  end
  comp:destroy()
end

function Entity:getById(id)
  return self.ComponentsById[id]
end

function Entity:getByTag(tag)
  return self.ComponentsByTag[tag]
end

function Entity:getComponents()
  return self.ComponentsById
end

function Entity:hasQuality(name, recursive)
  recursive = recursive or true
  if self.Qualities[name] then return true
  else
    for k,c in pairs(self.ComponentsById) do
      if c:hasQuality(name, true) then return true end
    end
  end
  return false
end

function Entity:getQualities(recursive)
  recursive = recursive or true
  local m = {}
  for k,q in pairs(self.Qualities) do m[k] = true end
  if recursive then
    for d,c in pairs(self.ComponentsByQuality) do
      m[d] = true
    end
  end
  return m
end

function Entity:think(dt)
  for k,v in pairs(self.ComponentsByQuality['mental'] or {}) do
    v:think(dt)
  end
end

function Entity:__tostring()
  return "I'm just an Entity. ID="..tostring(self.Id)
end



--
