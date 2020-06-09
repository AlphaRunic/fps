local rs = game:GetService('ReplicatedStorage')
local assets = rs.assets

local chr = script.Parent;
local plr = game.Players:GetPlayerFromCharacter(chr);

local network = {} do

  local n = {'RemoteEvent', 'RemoteFunction'};

  network:send = function(remote, ...)
    local rem = assets.network[remote]
    if rem:IsA(n[1]) then
     rem:FireClient(plr, ...)
    elseif rem:IsA(n[2]) then
      rem:InvokeClient(plr, ...)
    end
  end

  network:receive = function(remote, handler)
    local rem = assets.network[remote]
    if rem:IsA(n[1]) then
      rem.OnServerEvent:connect(handler)
    elseif rem:IsA(n[2]) then
      rem.OnServerInvoke = handler
    end
  end

end;

network:receive('Bullet',function(bullet, firesound, velo, accel, dmg, penetration, maxbullethits, bodymult)
  require(bullet)(firesound, velo, accel, dmg, penetration, maxbullethits, bodymult)
end)