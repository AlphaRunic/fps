function init(plr)

  local legend = {}

  local pmodel = plr.Character

  function legend:equip(name)
    local self = {}
    local char = assets.legends[string.upper(name)]
    plr:LoadCharacter(char)
    local legenddata = require(char.data)
    local taccooldown = legenddata.abilities.tactical.cooldown
    local ultcooldown = legenddata.abilities.ultimate.cooldown
    local tdb, udb = false, false
    function self.passive()
      legenddata.abilities.passive()
    end
    function self.tactical()
      if tdb then return end
      tdb = true
      legenddata.abilities.tactical.source()
      wait(taccooldown)
      tdb = false
    end
    function self.ultimate()
      if udb then return end
      udb = true
      legenddata.abilities.ultimate.source()
      wait(ultcooldown)
      udb = false
    end
    return setmetatable(self, legend)
  end

  return legend

end

return init