local function update_platform(surface)
	local platform = surface.platform
	surface.freeze_daytime = true

	if settings.startup["dynamic_platform_always_dark"].value then
		surface.daytime = 0.995
		return
	end

	local solar = nil

	local connection = platform.space_connection
	if connection and connection.from and connection.to then
		local from_s = connection.from.solar_power_in_space
		local to_s = connection.to.solar_power_in_space
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
		solar = storage.platform_memory[surface.index] or 10
	end

	local min_s = storage.solar_min
	local max_s = storage.solar_max

	local normalized = (solar - min_s) / (max_s - min_s)
	normalized = math.min(math.max(normalized, 0), 1) * storage.brightness

	surface.daytime = 0.995 + (normalized * 0.005)
end

local function ensure_storage()
	storage.platform_memory = storage.platform_memory or {}
	storage.solar_min = settings.startup["dynamic_platform_solar_min"].value
	local mod_data = prototypes.mod_data["dynamic_platform_lighting-solar-power"]
	storage.solar_max = mod_data and mod_data.data.max_solar_power_in_space
	storage.brightness = settings.startup["dynamic_platform_brightness"].value / 100
end

local function on_init()
	ensure_storage()
end

local function on_configuration_changed()
	ensure_storage()
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)

script.on_nth_tick(120, function()
	ensure_storage()
	for _, surface in pairs(game.surfaces) do
		if surface.platform then
			update_platform(surface)
		end
	end
end)
