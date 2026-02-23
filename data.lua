local render_parameters = data.raw["space-platform-hub"]["space-platform-hub"].surface_render_parameters
if not render_parameters then
	render_parameters = {}
	data.raw["space-platform-hub"]["space-platform-hub"].surface_render_parameters = render_parameters
end
local daytime_lut
if settings.startup["dynamic_platform_deep_darkness"].value then
	daytime_lut = {
		{ 0.0, "__core__/graphics/color_luts/identity-lut.png" },
		{ 0.2, "__core__/graphics/color_luts/identity-lut.png" },
		{ 0.8, "__dynamic_platform_lighting__/graphics/max-dark.png" },
		{ 0.99, "__dynamic_platform_lighting__/graphics/max-dark.png" },
		{ 0.9905, "__core__/graphics/color_luts/lut-night.png" },
		{ 1.0, "__core__/graphics/color_luts/identity-lut.png" },
	}
else
	daytime_lut = {
		{ 0.0, "__core__/graphics/color_luts/identity-lut.png" },
		{ 0.2, "__core__/graphics/color_luts/identity-lut.png" },
		{ 0.8, "__dynamic_platform_lighting__/graphics/max-dark.png" },
		{ 0.99, "__core__/graphics/color_luts/lut-night.png" },
		{ 1.0, "__core__/graphics/color_luts/identity-lut.png" },
	}
end
render_parameters.day_night_cycle_color_lookup = daytime_lut
