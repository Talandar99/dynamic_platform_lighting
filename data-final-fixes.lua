local function report(message)
	if log then
		log("[dynamic_platform_lighting] " .. message)
	end
end

local function get_own_lut(location)
	if
		location.platform_surface_render_parameters
		and location.platform_surface_render_parameters.day_night_cycle_color_lookup
	then
		return location.platform_surface_render_parameters.day_night_cycle_color_lookup
	end

	if location.surface_render_parameters and location.surface_render_parameters.day_night_cycle_color_lookup then
		return location.surface_render_parameters.day_night_cycle_color_lookup
	end

	return nil
end

local function get_default_lut()
	local constants = data.raw["utility-constants"]
	if constants and constants.default and constants.default.daytime_color_lookup then
		return constants.default.daytime_color_lookup
	end

	return nil
end

local function compress_lut(original_lut)
	local compressed = {}

	for _, entry in ipairs(original_lut) do
		local time = entry[1]
		if time <= 0.5 then
			table.insert(compressed, { time, entry[2] })
		end
		if time >= 0.5 then
			table.insert(compressed, { 0.995 + ((time - 0.5) * 0.01), entry[2] })
		end
	end

	return compressed
end

local function set_lut(location, lut)
	location.platform_surface_render_parameters = location.platform_surface_render_parameters or {}
	location.platform_surface_render_parameters.day_night_cycle_color_lookup = lut
end

local planet_luts = {}

for name, planet in pairs(data.raw["planet"] or {}) do
	local source_lut = get_own_lut(planet) or get_default_lut()
	if source_lut then
		local compressed = compress_lut(source_lut)
		planet_luts[name] = compressed
		set_lut(planet, compressed)
	end
end

for _, location in pairs(data.raw["space-location"] or {}) do
	local source_lut = get_own_lut(location) or get_default_lut()
	if source_lut then
		set_lut(location, compress_lut(source_lut))
	end
end

local planet_names = {}
for name in pairs(planet_luts) do
	planet_names[#planet_names + 1] = name
end
table.sort(planet_names)

local lut_setting = settings.startup["dynamic_platform_lut"]
local lut_choice = lut_setting and lut_setting.value or "dynamic"
report("lut choice: " .. tostring(lut_choice) .. ", planets: " .. table.concat(planet_names, ", "))

if lut_choice ~= "dynamic" then
	local chosen_lut = planet_luts[lut_choice]
	if chosen_lut then
		for _, planet in pairs(data.raw["planet"] or {}) do
			set_lut(planet, chosen_lut)
		end
		for _, location in pairs(data.raw["space-location"] or {}) do
			set_lut(location, chosen_lut)
		end
	else
		report("unknown planet: " .. tostring(lut_choice))
	end
end

local max_solar = 0
for _, planet in pairs(data.raw["planet"] or {}) do
	max_solar = math.max(max_solar, planet.solar_power_in_space or 0)
end
for _, location in pairs(data.raw["space-location"] or {}) do
	max_solar = math.max(max_solar, location.solar_power_in_space or 0)
end

data:extend({
	{
		type = "mod-data",
		name = "dynamic_platform_lighting-solar-power",
		data_type = "dynamic_platform_lighting",
		data = { max_solar_power_in_space = max_solar },
	},
})
