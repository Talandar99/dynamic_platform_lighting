local deep_darkness = settings.startup["dynamic_platform_deep_darkness"].value

local function get_lut_from_proto(proto)
	if proto.surface_render_parameters and proto.surface_render_parameters.day_night_cycle_color_lookup then
		return proto.surface_render_parameters.day_night_cycle_color_lookup
	elseif
		proto.platform_surface_render_parameters
		and proto.platform_surface_render_parameters.day_night_cycle_color_lookup
	then
		return proto.platform_surface_render_parameters.day_night_cycle_color_lookup
	end
	return nil
end

local function compress_lut(original_lut)
	local compressed = {}

	if deep_darkness then
		table.insert(compressed, { 0.0, "__core__/graphics/color_luts/identity-lut.png" })
		table.insert(compressed, { 0.8, "__dynamic_platform_lighting__/graphics/max-dark.png" })
		table.insert(compressed, { 0.99, "__dynamic_platform_lighting__/graphics/max-dark.png" })
	else
		table.insert(compressed, { 0.0, "__core__/graphics/color_luts/identity-lut.png" })
		table.insert(compressed, { 0.8, "__dynamic_platform_lighting__/graphics/max-dark.png" })
		table.insert(compressed, { 0.99, "__core__/graphics/color_luts/lut-night.png" })
	end

	if original_lut and #original_lut > 0 then
		for _, entry in ipairs(original_lut) do
			local time = entry[1]
			local lut_path = entry[2]
			local new_time = 0.99 + (time * 0.01)
			table.insert(compressed, { new_time, lut_path })
		end
	else
		table.insert(compressed, { 0.9905, "__core__/graphics/color_luts/lut-night.png" })
	end

	table.insert(compressed, { 1.0, "__core__/graphics/color_luts/identity-lut.png" })
	return compressed
end

local function apply_compressed_lut(proto)
	proto.platform_surface_render_parameters = proto.platform_surface_render_parameters or {}
	local raw_lut = get_lut_from_proto(proto)
	proto.platform_surface_render_parameters.day_night_cycle_color_lookup = compress_lut(raw_lut)
end

if data.raw["utility-constants"] then
	for _, constants in pairs(data.raw["utility-constants"]) do
		if constants.default_platform_surface_render_parameters then
			local raw_lut = constants.default_platform_surface_render_parameters.day_night_cycle_color_lookup
			constants.default_platform_surface_render_parameters.day_night_cycle_color_lookup = compress_lut(raw_lut)
		end
	end
end

if data.raw["space-location"] then
	for name, location in pairs(data.raw["space-location"]) do
		apply_brak = apply_compressed_lut(location)

		if name == "space-location-unknown" then
			location.platform_surface_render_parameters.day_night_cycle_color_lookup = {
				{ 0.0, "__core__/graphics/color_luts/identity-lut.png" },
				{ 0.99, "__dynamic_platform_lighting__/graphics/max-dark.png" },
				{ 1.0, "__core__/graphics/color_luts/identity-lut.png" },
			}
		end
	end
end

if data.raw["planet"] then
	for _, planet in pairs(data.raw["planet"]) do
		apply_compressed_lut(planet)
	end
end
