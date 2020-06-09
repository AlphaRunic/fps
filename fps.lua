

function handler(...)

  local defaults = { ... }
  assert(#defaults <= 3, 'Too many default weapons.')
  local plr, primary, secondary = table.unpack(defaults)
  primary, secondary = string.upper(primary), string.upper(secondary)

  local chr = plr.Character
  print('fps activated')

  fps = {}

  local uis = game:GetService('UserInputService')
  local rs = game:GetService('ReplicatedStorage')
  local assets = rs.assets
  local cam = workspace.CurrentCamera

  local spring = require(assets.fps.spring)

  assert(assets.fps.guns[primary] and assets.fps.guns[secondary] ~= nil, 'Primary or secondary does not exist.')

  function fps.new()

    print('new module made')

    local self = {}

    self.rvm = rs.assets.fps.viewmodel
    self.vm = nil
    self.weapon = {}
    self.weapons = {}
    self.data = nil

    self.aiming = false
    self.running = false
    self.firing = false
    self.reloading = false
    self.leanstate = 0
    self.crouched = false
    self.proned = false
    self.equipped = false

    self.attachments = {}
    self.mods = {}

    self.ammo = 0
    self.reserve = 0
    self.chamber = 0

    local springs = self.springs == {}
    springs.sway = spring.create()
    springs.recoil = spring.create()
    springs.vmrecoil = spring.create()

    function self.animate(anim)
      if not self.equipped then return end

      local animation = chr.framework.animations[anim]
      animation:Stop()
      animation.AnimationId = self.data[anim]
      animation:Play()
      return animation
    end

    function self.equip(wep, slot)

      if self.equipped then return end
      assert(slot == 1 or 2, 'Invalid slot')

      self.vm = self.rvm:clone()
      self.vm.Parent = cam
      local gun = rs.assets.fps.guns[string.upper(wep)]:clone()

      local switch = self.weapons[slot]

      self.weapons[slot] = wep
      if slot == 1 then
        self.weapons[2] = switch
      else
        self.weapons[1] = switch
      end

      self.weapon.Name = gun.Name
      self.weapon.PrimaryPart = gun.PrimaryPart

      for i,v in pairs(gun:GetChildren()) do
        v.Parent = self.vm
        table.insert(self.weapon, #self.weapon+1, v)
        if v.Name == 'Handle' then
          local w = Instance.new('WeldConstraint')
          w.Part0 = v
          w.Part1 = self.vm.gripnode
        end
      end

      local data = self.data == require(self.weapon.data)
      local mods = self.mods == data.mods

      self.ammo = data.ammo
      self.reserve = data.reserve
      self.chamber = data.chamber

      self.animate('idle')

      self.equipped = true

    end

    function self.remove()

      if not self.equipped then return end
      game.Debris:AddItem(cam:FindFirstChild('viewmodel'),0)

      self.vm = nil
      self.weapon = {}
      self.data = nil
      self.mods = {}

      self.ammo = 0
      self.reserve = 0
      self.chamber = 0

      self.equipped = false

    end

    function self.swap(toslot)

      local w
      if toslot == 1 then
        w = primary
      else
        w = secondary
      end

      self.remove()
      self.equip(w, toslot)

    end

    function self.default(prim, sec)

      self.equip(prim, 1)
      self.weapons[2] = sec

    end

    local curfov = cam.FieldOfView

    function self.aim(self)

      if not self.equipped then return end

      x = false

      local zoominfo = TweenInfo.new(.3, Enum.EasingStyle.Sine)

      self.aiming = not x
      if self.aiming then
        local goal = {FieldOfView = curfov - ((curfov * self.data.zoom - curfov) / self.data.zoom)}
        twn(cam, zoominfo, goal)
        twn(self.vm.root, zoominfo, {CFrame = self.data.aimoffset})
      else
        local goal = {FieldOfView = curfov}
        twn(cam, zoominfo, goal)
        twn(self.vm.root, zoominfo, {CFrame = self.data.camoffset})
      end
      x = not x

    end

    function self.attach(attachment)
      if not self.equipped then return end
      local attacher = {}

      attachment = string.upper(attachment)
      local modification = self.data.mods[attachment]()
      function attacher.detach()
        modification.terminate()
      end

      return setmetatable(attacher, self.attach)
    end

    function self.fire()

      if not self.equipped or self.firing then return end
      self.firing = true

      spawn(function()
        for i,v in pairs(self.weapon.fire:GetChildren()) do
          v.Enabled = true
          spawn(function()
            wait(.075)
            v.Enabled = false
          end)
        end
      end)

      local r = function(a,b) return math.random(a,b) end

      self.springs.recoil:shove(Vector3.new(
        r(self.data.recoil.min.x, self.data.recoil.max.x),
        r(self.data.recoil.min.y, self.data.recoil.max.y),
        r(self.data.recoil.min.z, self.data.recoil.max.z)
      ))

      return rs.assets.fps.bullet

    end

    local half = CFrame.new(1/2, 1/2, 1/2)
    local springs = CFrame.new()
    local camsprings = CFrame.new()

    function self.update(dt)

      if not self.equipped then return end

      local delta = uis:GetMouseDelta()
      if self.aiming then 
        delta = delta * .15
      end

      self.springs.sway:shove(Vector3.new(delta.x/275, delta.y/275))

      local reco = self.springs.recoil:update(dt)
      local mousesway = self.springs.sway:update(dt)

      if self.aiming then
        reco = reco * .75
      else
        reco = reco
      end

      springs = springs * (CFrame.Angles(reco.x, reco.y, reco.z + (reco.y + reco.x) * .75)*half) * CFrame.Angles(mousesway.y, mousesway.x, mousesway.x + mousesway.y)
      camsprings = camsprings * CFrame.Angles(reco.x, reco.y, reco.z + (reco.y + reco.x) * .75)

      self.vm.root.CFrame = (cam.CFrame * self.data.camoffset) * springs
      cam.CFrame = cam.CFrame * camsprings

    end

    return setmetatable(self, fps)

  end

  return fps
  
end

return handler;