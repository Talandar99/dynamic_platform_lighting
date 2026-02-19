local function update_platform(surface)
	if not surface.platform then
		return
	end

	local platform = surface.platform
	local solar
	if platform.space_connection and platform.space_connection.from and platform.space_connection.to then
		local from_s = platform.space_connection.from.solar_power_in_space
		local to_s = platform.space_connection.to.solar_power_in_space
		if from_s and to_s then
			solar = from_s * (1 - platform.distance) + to_s * platform.distance
		end
	end
	if not solar and platform.space_location then
		solar = platform.space_location.solar_power_in_space
	end
	if solar then
		storage.platform_memory[surface.index] = solar
	else
		solar = storage.platform_memory[surface.index]
	end
	if not solar then
		return
	end
	surface.freeze_daytime = true
	local min_s = storage.solar_min
	local max_s = storage.solar_max
	local normalized = (solar - min_s) / (max_s - min_s)
	surface.daytime = 0.5 + math.min(math.max(normalized, 0), 1) * 0.5
end

local function ensure_storage()
	storage.platform_memory = storage.platform_memory or {}
	storage.solar_min = 0
	storage.solar_max = settings.startup["max_solar_power_in_space"].value
end
local function on_init()
	ensure_storage()
end
local function on_configuration_changed()
	ensure_storage()
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)

script.on_event(defines.events.on_tick, function(event)
	if event.tick % 60 ~= 0 then
		return
	end
	ensure_storage()
	for _, surface in pairs(game.surfaces) do
		if surface.platform then
			update_platform(surface)
		end
	end
end)
