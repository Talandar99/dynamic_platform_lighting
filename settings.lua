local lut_choices = { "dynamic", "nauvis", "vulcanus", "gleba", "fulgora", "aquilo" }

data.extend({
	{
		type = "int-setting",
		name = "dynamic_platform_brightness",
		setting_type = "startup",
		minimum_value = 25,
		maximum_value = 100,
		default_value = 100,
		order = "dynamic_platform_lighting_a",
	},
	{
		type = "bool-setting",
		name = "dynamic_platform_always_dark",
		setting_type = "startup",
		default_value = false,
		order = "dynamic_platform_lighting_b",
	},
	{
		type = "string-setting",
		name = "dynamic_platform_lut",
		setting_type = "startup",
		default_value = "dynamic",
		allowed_values = lut_choices,
		order = "dynamic_platform_lighting_c",
	},
	{
		type = "int-setting",
		name = "dynamic_platform_solar_limit",
		setting_type = "startup",
		minimum_value = 0,
		maximum_value = 1000000,
		default_value = 600,
		order = "dynamic_platform_lighting_d",
	},
	{
		type = "bool-setting",
		name = "dynamic_platform_max_dark_lut",
		setting_type = "startup",
		default_value = false,
		order = "dynamic_platform_lighting_e",
	},
	{
		type = "int-setting",
		name = "dynamic_platform_solar_min",
		setting_type = "startup",
		minimum_value = 0,
		maximum_value = 1000000,
		default_value = 60,
		order = "dynamic_platform_lighting_f",
	},
})
