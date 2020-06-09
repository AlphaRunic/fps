
function init(player, firesound, velo, accel, damage, penetration, maxbullethits, bodymult)

  local chr = player.Character
  local rs = game:GetService('ReplicatedStorage')

  firesound = firesound:clone()
  firesound.Parent = chr.Head
  firesound.Playing = false
  firesound.Playing = true

  local projectile = require(rs.assets.fps.projectile)

  bullet = projectile.new(chr.Head, rs.assets.fps.vfx.bullet:clone(), {velo, (accel/100) * 196.2, 5})

  touchDebounce = false
  touchDebounceTime = .75

  hits = 1

  limbs = {'LeftArm','RightArm','LeftLeg','RightLeg','LeftHand','LeftLowerArm','LeftUpperArm','RightUpperArm','RightLowerArm','RightHand','LeftFoot','LeftLowerLeg','LeftUpperLeg','RightFoot','RightLowerLeg','RightUpperLeg'}
  chest = {'LowerTorso','UpperTorso','Torso'}

  bullet.Touched:connect(function(hit)

    local hum = hit.Parent:FindFirstChildOfClass('Humanoid');

    local dmg = math.random(table.unpack(damage))

    if hum then

      if touchDebounce or hit.Parent.Name == 'viewmodel' or hit.Parent.Name == player.Name then return end
      touchDebounce = true

      if limbs[hit.Name] ~= nil then
        dmg = dmg * bodymult[1]
      elseif chest[hit.Name] ~= nil then
        dmg = dmg * bodymult[2]
      elseif hit.Name == 'Head' then
        dmg = dmg * bodymult[3]
      end

      game.Debris:AddItem(bullet,0)
      hum:TakeDamage(dmg)

      local hitsound = rs.assets.fps.sfx.bodyhit:clone()
      hitsound.Parent = chr.Head
      hitsound.Playing = true
      game.Debris:AddItem(hitsound, hitsound.TimeLength)

      wait(touchDebounceTime)
      touchDebounce = false

    else

      local hitsound = rs.assets.fps.sfx.hit:clone()
      local soundpart = Instance.new('Part')
      soundpart.Transparency = 1
      soundpart.Anchored = true
      soundpart.CanCollide = false
      soundpart.Position = bullet.CFrame.p
      soundpart.Parent = workspace
      hitsound.Parent = soundpart
      hitsound.Playing = true
      game.Debris:AddItem(soundpart, hitsound.TimeLength)

      --penetration
      if hit.Size.magnitude >= penetration then
        game.Debris:AddItem(bullet,0)
      end

      --ricochet
      local rot = bullet.Orientation
      local velo = bullet.Velocity
      rot.x = -rot.x
      rot.y = -rot.y
      rot.z = -rot.z
      velo = velo * (maxbullethits - hits / maxbullethits)
      velo.x = -velo.x
      velo.y = -velo.y
      velo.z = -velo.z

      hits = hits + 1
      if hits > maxbullethits then 
        hits = 1
        game.Debris:AddItem(bullet,0) 
      end
      
    end
    
  end)

end

return init;