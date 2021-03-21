-- This file is where you enable and configure your installed mods
--
-- Example:
--[[
return {
  ["workshop-350811795"] = { enabled = true },
  ["workshop-387028143"] = { enabled = true },
  ["workshop-361336115"] = { enabled = true,
      configuration_options =
      {
          hunt_time = 6,
          ["String Phrase Option Name"] = "some value",
      }
  },
  ["workshop-336882447"] = { enabled = true }
}
--]]

return {
  ["workshop-2078243581"]={
    configuration_options={ Blue=0, Display="target", Green=0, Projectile=true, Red=1, Type="both" },
    enabled=true 
  },
  ["workshop-2281925291"]={
    configuration_options={ ACTIVEITEM=true, ["Client and server options"]=0, INGREDIENT=true, TINT=7 },
    enabled=true 
  },
  ["workshop-2323750553"]={ configuration_options={ DropWholeStack=true, MAXSTACKSIZE=99 }, enabled=true } 
}
