extends Node

const SETTINGS_FILE = "user://browser_settings.json"

var settings_data = {
	"startup_new_tab": true,
	"startup_specific_page": true,
	"startup_url": "gurt://phoenix.clank/",
	"search_engine_url": "gurt://search.web?q=",
	"download_confirmation": true,
	"dns_url": "104.168.74.86:4000",
	"dns_fallback_url": "135.125.163.131:4878"
}

var _loaded = false

func _ready():
	load_settings()

func load_settings():
	if _loaded:
		return
		
	if not FileAccess.file_exists(SETTINGS_FILE):
		save_settings()
		_loaded = true
		return
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if not file:
		print("Failed to open settings file")
		_loaded = true
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("Failed to parse settings JSON")
		_loaded = true
		return
	
	var loaded_data = json.data
	if loaded_data is Dictionary:
		# Merge loaded settings with defaults
		for key in loaded_data:
			if key in settings_data:
				settings_data[key] = loaded_data[key]
	
	_loaded = true
	print("Settings loaded: ", settings_data)

func save_settings():
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if not file:
		print("Failed to open settings file for writing")
		return
	
	var json_text = JSON.stringify(settings_data)
	file.store_string(json_text)
	file.close()
	print("Settings saved: ", settings_data)

func get_download_confirmation() -> bool:
	return settings_data.download_confirmation

func get_search_engine_url() -> String:
	return settings_data.search_engine_url

func get_dns_url() -> String:
	return settings_data.dns_url

func get_dns_fallback_url() -> String:
	return settings_data.dns_fallback_url

func get_startup_behavior() -> Dictionary:
	return {
		"new_tab": settings_data.startup_new_tab,
		"specific_page": settings_data.startup_specific_page,
		"url": settings_data.startup_url
	}

func set_download_confirmation(value: bool):
	settings_data.download_confirmation = value
	save_settings()

func set_search_engine_url(value: String):
	settings_data.search_engine_url = value
	save_settings()

func set_dns_url(value: String):
	settings_data.dns_url = value
	save_settings()

func set_dns_fallback_url(value: String):
	settings_data.dns_fallback_url = value
	save_settings()

func set_startup_new_tab(value: bool):
	settings_data.startup_new_tab = value
	if value:
		settings_data.startup_specific_page = false
	save_settings()

func set_startup_specific_page(value: bool):
	settings_data.startup_specific_page = value
	if value:
		settings_data.startup_new_tab = false
	save_settings()

func set_startup_url(value: String):
	settings_data.startup_url = value
	save_settings()

func get_setting(key: String, default_value = null):
	if key in settings_data:
		return settings_data[key]
	return default_value
