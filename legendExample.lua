local data = {}

data.name = 'Octane'
data.nickname = 'High-speed Daredevil'

data.abilities = {
  passive = function()

  end,
  tactical = {name = 'Stim', source = function()

  end, cooldown = 15},
  ultimate = {name = 'Jump Pad', source = function()
  
  end, cooldown = 30},
}

data.quips = {}
spawn(function()
  for i,v in script.Parent.quips do
    table.insert(data.quips, #data.quips+1, v.SoundId)
  end
end

return data