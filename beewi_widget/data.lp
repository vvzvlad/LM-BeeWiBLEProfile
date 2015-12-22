<?
require('genohm-scada')
require('apps')

local alias= { 
	power = "BeeWi SmartLite - Power",
	color = "BeeWi SmartLite - RGB color",
	brightness = "BeeWi SmartLite - Brightness",
	status_power = "BeeWi SmartLite - Power status", 
	status_color = "BeeWi SmartLite - RGB color status", 
	status_brightness = "BeeWi SmartLite - Brightness Status", 
}

local result = {} 

local color = getvar("color") and tonumber(getvar("color"))
color = color and color>=0 and color<=0xFFFFFF and color or nil 

local power = getvar("power") and tonumber(getvar("power"))
power = power~=nil and power>=0 and power<=1 and power or nil 

local brightness = getvar("brightness") and tonumber(getvar("brightness"))
brightness = brightness and brightness>=0 and brightness<=100 and brightness or nil 


if power~=nil then 
	grp.write(alias.power, power)
	result.changed_power = true 
end 

if color~=nil then 
	grp.write(alias.color, color) 
	result.changed_color = true 
end 

if brightness~=nil then 
	grp.write(alias.brightness, math.ceil(brightness/10-0.5)) 
	result.changed_brightness = true 
end 


if result.changed_power or result.changed_color or result.changed_brightness then 
	os.sleep(1.5) 	
end 

result.power = grp.getvalue(alias.status_power)
result.color = grp.getvalue(alias.status_color)
result.brightness = grp.getvalue(alias.status_brightness) * 10 
 
write(json.encode(result))





