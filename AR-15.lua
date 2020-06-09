local rpm = function(x) return 60/x end

local rs = game:GetService('ReplicatedStorage')
local assets = rs.assets

local weapontype = 'ASSAULT RIFLE'
local calibre = '5.56x45mm'

local recoil = {
  min = Vector3.new(.03,.02,.01),
  max = Vector3.new(.075,.03,.015)
}

local firesound = script.Parent.sounds.fire.SoundId
local supressedfiresound = script.Parent.sounds.firesupressed.SoundId

local ammo = 30

local deg = math.rad

local data = {

  weapontype = weapontype,
  ammotype = 'HEAVY AMMO',
  calibre = calibre,
  weaponname = script.Parent.Name..' '..weapontype..' [ '..calibre..' ]',

  dmg = {22, 28}, --dmg1, dmg2
  bodymult = {.85, 1.1, 1.75}, --limbs, chest, head
  velocity = 1000,--meters
  acceleration = 95,--% acceleration

  firetype = 'Auto',
  burstamount = 3,
  firerate = rpm(750),
  maxbullethits = 5,
  penetration = 3,

  ammo = ammo,
  reserve = ammo * 5,
  chamber = 1,

  recoil = recoil,

  firesound = firesound,
  supressedfiresound = supressedfiresound,

  camoffset = CFrame.new(0,-1.4,0), --viewmodel offset
  aimoffset = CFrame.new(-1,1.1,-.5),

  zoom = 1.25,--x zoom

  anims = {
    ["idle"] = '',
    ["reload"] = '',
    ["inspect"] = '',
  },

}

mods = {

    ['SELECT FIRE'] = function()
      local mod = {}

      local selections = {
        [1] = 'Auto',
        [2] = 'Burst',
        [3] = 'Single',
      }
      local selected = 1
      local debounce = false
      local inputBind
      inputBind = game:GetService('UserInputService').InputBegan:connect(function(key)
        key = key.KeyCode
        local keys = Enum.KeyCode
        if key == keys['V'] then
          if debounce then return end
          debounce = true
          if selected == 1 then
            selected = 2
          elseif selected == 2 then
            selected = 3
          else
            selected = 1
          end
          data.firetype = selections[selected]
          wait(.25)
          debounce = false
        end
      end)

      mod.terminate = function()
        inputBind:Disconnect()
      end

      return setmetatable(mod, data)
    end

    ['SUPRESSOR'] = function()
      local mod = {}

      local recoildamppercent = 10
      data.recoil.min = data.recoil.min * (1 - (1/recoildamppercent))
      data.recoil.max = data.recoil.max * (1 - (1/recoildamppercent))
      script.Parent.sounds.fire.SoundId = data.supressedfiresound
      local supressor = assets.fps.guns.attachments.supressor:clone()
      supressor.Parent = script.Parent
      supressor.CFrame = script.Parent.attachment_nodes.barrel.CFrame
      local w = Instance.new('WeldConstraint')
      w.Part0 = supressor
      w.Part1 = script.Parent.attachment_nodes.barrel.CFrame
      w.Parent = supressor

      mod.terminate = function()
        data.recoil = recoil
        script.Parent.sounds.fire.SoundId = firesound
        game.Debris:AddItem(script.Parent.supressor,0)
      end

      return setmetatable(mod, data)
    end

    ['2X RANGER'] = function()
      local mod = {}

      local optic = assets.fps.guns.attachments.rangersight:clone()
      optic.Parent = script.Parent
      optic.CFrame = script.Parent.attachment_nodes.optic.CFrame
      local w = Instance.new('WeldConstraint')
      w.Part0 = optic
      w.Part1 = script.Parent.attachment_nodes.optic.CFrame
      w.Parent = optic

      mod.terminate = function()
        game.Debris:AddItem(script.Parent.rangersight,0)
      end

      return setmetatable(mod, data)
    end

  }

return data