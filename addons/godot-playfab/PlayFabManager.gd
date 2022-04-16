extends Node
# This is script must be auto-loaded as `PlayFabManager`.
# Use it as a global state/config manager for PlayFab data, like login persistence.

# Handles saving/loading of the `PlayFabClientConfig`
var _client_config_loader = PlayFabClientConfigLoader.new()

# **READONLY**
# The Tile ID to use for this project. Will be pulled from ProjectSettings.
# **DO NOT** manually override!
var title_id: String

# Holds information for the PlayFab client, e.g. login data.
# **Call `save_client_config()` after changing/updating it to persist.
var client_config: PlayFabClientConfig


# Retrieves the `title_id` from `ProjectSettings`
func _init():
	if ProjectSettings.has_setting(PlayFabConstants.SETTING_PLAYFAB_TITLE_ID) && ProjectSettings.get_setting(PlayFabConstants.SETTING_PLAYFAB_TITLE_ID) != "":
		title_id = ProjectSettings.get_setting(PlayFabConstants.SETTING_PLAYFAB_TITLE_ID)
	else:
		push_error("Title Id was not set in ProjectSettings: %s" % PlayFabConstants.SETTING_PLAYFAB_TITLE_ID)


# Called when the node enters the scene tree for the first time.
func _ready():
	client_config = _client_config_loader.load(title_id)


# Saves the client config to a file
func save_client_config():
	_client_config_loader.save(title_id, client_config)
