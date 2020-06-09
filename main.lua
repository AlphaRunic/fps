local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local chr = script.Parent

local fw = chr.framework
local anims = fw.animations
local 

local rs = game:GetService('ReplicatedStorage')
local rt = game:GetService('RunService')
local assets = rs.assets
mod = require(assets.fps.handler)(plr, 'AR-15', 'Beretta');
fps = mod.new()
fps.default(primary, secondary)

local network = {} do

  local n = {'RemoteEvent', 'RemoteFunction'};

  function network:send(remote, ...)
    local rem = assets.network[remote]
    if rem:IsA(n[1]) then
     rem:FireServer(...)
    elseif rem:IsA(n[2]) then
      rem:InvokeServer(...)
    end
  end

  function network:receive(remote, handler)
    local rem = assets.network[remote]
    if rem:IsA(n[1]) then
      rem.OnClientEvent:connect(handler)
    elseif rem:IsA(n[2]) then
      rem.OnClientInvoke = handler
    end
  end

end;

function fire()
  bullet = fps.fire()
  network:send('Bullet', bullet, assets.fps.guns[fps.weapon.Name].sounds.fire, fps.data.velocity, fps.data.acceleration, fps.data.dmg, fps.data.penetration, fps.data.maxbullethits, fps.data.bodymult)
end

debounce = false
down = false
mouse.Button1Down:connect(function()
  if debounce or not fps.equipped then return end
  debounce = true
  if fps.data.firetype == 'Single' then
    fire()
    wait(fps.data.firerate)
    debounce = false
  elseif fps.data.firetype == 'Auto' then
    down = true
    repeat
      fire()
      wait(fps.data.firerate)
    until not down
    debounce = false
  elseif fps.data.firetype == 'Burst' then
    down = true
    local x = 0
    repeat
      fire()
      x = x + 1
      wait(fps.data.firerate)
    until x == fps.data.burstamount or not down
    x = 0
    debounce = false
  elseif fps.data.firetype == 'AutoBurst' then
    down = true
    repeat
      local x = 0
      repeat
        fire()
        x = x + 1
        wait(fps.data.firerate)
      until x == fps.data.burstamount or not down
      wait(fps.data.firerate * x)
      x = 0
    until not down
  end
end)

mouse.Button1Up:connect(function()
  if fps.data.firetype == 'Auto' or fps.data.firetype == 'Burst' or fps.data.firetype == 'AutoBurst' then
    down = false
  end
end)

mouse.Button2Down:connect(function()
  fps:aim()
end)

mouse.Button2Up:connect(function()
  fps:aim()
end)

rt.RenderStepped:connect(function(dt)
  fps:update(dt)
end)

