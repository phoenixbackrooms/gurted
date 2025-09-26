extends PopupPanel

const SETTINGS_FILE = "user://browser_settings.json"

# Tab references
@onready var tab_general: Button = $HSplitContainer/Sidebar/VBoxContainer/TabGeneral
@onready var tab_privacy: Button = $HSplitContainer/Sidebar/VBoxContainer/TabPrivacy
@onready var tab_downloads: Button = $HSplitContainer/Sidebar/VBoxContainer/TabDownloads
@onready var tab_advanced: Button = $HSplitContainer/Sidebar/VBoxContainer/TabAdvanced
@onready var tab_about: Button = $HSplitContainer/Sidebar/VBoxContainer/TabAbout

# Panel references
@onready var general_panel: VBoxContainer = $HSplitContainer/Content/ScrollContainer/ContentStack/GeneralPanel
@onready var privacy_panel: VBoxContainer = $HSplitContainer/Content/ScrollContainer/ContentStack/PrivacyPanel
@onready var downloads_panel: VBoxContainer = $HSplitContainer/Content/ScrollContainer/ContentStack/DownloadsPanel
@onready var advanced_panel: VBoxContainer = $HSplitContainer/Content/ScrollContainer/ContentStack/AdvancedPanel
@onready var about_panel: VBoxContainer = $HSplitContainer/Content/ScrollContainer/ContentStack/AboutPanel

# Settings controls - General
@onready var startup_new_tab: CheckBox = $HSplitContainer/Content/ScrollContainer/ContentStack/GeneralPanel/StartupSection/VBoxContainer/StartupNewTab
@onready var startup_specific_page: CheckBox = $HSplitContainer/Content/ScrollContainer/ContentStack/GeneralPanel/StartupSection/VBoxContainer/StartupSpecificPage
@onready var startup_url_container: HBoxContainer = $HSplitContainer/Content/ScrollContainer/ContentStack/GeneralPanel/StartupSection/VBoxContainer/StartupURLContainer
@onready var startup_url_input: LineEdit = $HSplitContainer/Content/ScrollContainer/ContentStack/GeneralPanel/StartupSection/VBoxContainer/StartupURLContainer/URLInput
@onready var search_input: LineEdit = $HSplitContainer/Content/ScrollContainer/ContentStack/GeneralPanel/SearchEngineSection/VBoxContainer/HBoxContainer/SearchInput

# Settings controls - Privacy
@onready var clear_history_button: Button = $HSplitContainer/Content/ScrollContainer/ContentStack/PrivacyPanel/ClearDataSection/VBoxContainer/ButtonsContainer/ClearHistoryButton
@onready var clear_cookies_button: Button = $HSplitContainer/Content/ScrollContainer/ContentStack/PrivacyPanel/ClearDataSection/VBoxContainer/ButtonsContainer/ClearCookiesButton
@onready var clear_downloads_button: Button = $HSplitContainer/Content/ScrollContainer/ContentStack/PrivacyPanel/ClearDataSection/VBoxContainer/ButtonsContainer/ClearDownloadsButton

# Settings controls - Downloads
@onready var download_confirm_checkbox: CheckBox = $HSplitContainer/Content/ScrollContainer/ContentStack/DownloadsPanel/DownloadConfirmSection/VBoxContainer/ConfirmCheckBox

# Settings controls - Advanced
@onready var dns_input: LineEdit = $HSplitContainer/Content/ScrollContainer/ContentStack/AdvancedPanel/DNSSection/VBoxContainer/HBoxContainer/DNSInput
@onready var dns_fallback_input: LineEdit = $HSplitContainer/Content/ScrollContainer/ContentStack/AdvancedPanel/DNSSection/VBoxContainer/HBoxContainer2/DNSFallbackInput

@onready var version_label: Label = $HSplitContainer/Content/ScrollContainer/ContentStack/AboutPanel/AboutSection/VBoxContainer/VersionLabel

# Settings are now managed by SettingsManager singleton

var tab_buttons = []
var content_panels = []

func _ready():
	version_label.text = "v" + ProjectSettings.get_setting("application/config/version")
	
	tab_buttons = [tab_general, tab_privacy, tab_downloads, tab_advanced, tab_about]
	content_panels = [general_panel, privacy_panel, downloads_panel, advanced_panel, about_panel]
	
	tab_general.toggled.connect(_on_tab_toggled.bind("general"))
	tab_privacy.toggled.connect(_on_tab_toggled.bind("privacy"))
	tab_downloads.toggled.connect(_on_tab_toggled.bind("downloads"))
	tab_advanced.toggled.connect(_on_tab_toggled.bind("advanced"))
	tab_about.toggled.connect(_on_tab_toggled.bind("about"))
	
	startup_new_tab.toggled.connect(_on_startup_new_tab_toggled)
	startup_specific_page.toggled.connect(_on_startup_specific_page_toggled)
	startup_url_input.text_changed.connect(_on_startup_url_changed)
	search_input.text_changed.connect(_on_search_engine_changed)
	download_confirm_checkbox.toggled.connect(_on_download_confirmation_changed)
	dns_input.text_changed.connect(_on_dns_changed)
	dns_fallback_input.text_changed.connect(_on_dns_fallback_changed)
	
	clear_history_button.pressed.connect(_on_clear_history_pressed)
	clear_cookies_button.pressed.connect(_on_clear_cookies_pressed)
	clear_downloads_button.pressed.connect(_on_clear_downloads_pressed)
	
	apply_settings_to_ui()
	
	_on_tab_toggled(true, "general")

func _on_tab_toggled(pressed: bool, tab_name: String):
	if not pressed:
		return
	
	_update_tab_styles(tab_name)
	
	for i in range(content_panels.size()):
		var panel = content_panels[i]
		match tab_name:
			"general":
				panel.visible = (i == 0)
			"privacy":
				panel.visible = (i == 1)
			"downloads":
				panel.visible = (i == 2)
			"advanced":
				panel.visible = (i == 3)
			"about":
				panel.visible = (i == 4)

func _update_tab_styles(selected_tab: String):
	for i in range(tab_buttons.size()):
		var button = tab_buttons[i]
		var tab_names = ["general", "privacy", "downloads", "advanced", "about"]
		var is_selected = (tab_names[i] == selected_tab)
		
		if is_selected:
			button.modulate = Color.WHITE
		else:
			button.modulate = Color(0.8, 0.8, 0.8)

func _on_startup_new_tab_toggled(pressed: bool):
	if pressed:
		SettingsManager.set_startup_new_tab(true)
		startup_url_container.visible = false

func _on_startup_specific_page_toggled(pressed: bool):
	if pressed:
		SettingsManager.set_startup_specific_page(true)
		startup_url_container.visible = true

func _on_startup_url_changed(new_url: String):
	SettingsManager.set_startup_url(new_url)

func _on_search_engine_changed(new_url: String):
	SettingsManager.set_search_engine_url(new_url)

func _on_download_confirmation_changed(enabled: bool):
	SettingsManager.set_download_confirmation(enabled)

func _on_dns_changed(new_dns: String):
	SettingsManager.set_dns_url(new_dns)

func _on_dns_fallback_changed(new_dns: String):
	SettingsManager.set_dns_fallback_url(new_dns)

func _on_clear_history_pressed():
	BrowserHistory.clear_all()

func _on_clear_cookies_pressed():
	LuaCrumbsUtils.clear_all_crumbs()

func _on_clear_downloads_pressed():
	var main = Engine.get_main_loop().current_scene
	if main.download_manager.downloads_history_ui:
		main.download_manager.downloads_history_ui.clear_all_downloads()
	else:
		main.download_manager._ensure_downloads_history_ui()
		main.download_manager.downloads_history_ui.clear_all_downloads()

func apply_settings_to_ui():
	var startup_behavior = SettingsManager.get_startup_behavior()
	startup_new_tab.button_pressed = startup_behavior.new_tab
	startup_specific_page.button_pressed = startup_behavior.specific_page
	startup_url_container.visible = startup_behavior.specific_page
	startup_url_input.text = startup_behavior.url
	
	search_input.text = SettingsManager.get_search_engine_url()
	download_confirm_checkbox.button_pressed = SettingsManager.get_download_confirmation()
	dns_input.text = SettingsManager.get_dns_url()
	dns_fallback_input.text = SettingsManager.get_dns_fallback_url()
