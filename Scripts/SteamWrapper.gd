extends Node

const STEAM_APP_ID_VALUE : String = "480" # Default Steam Test App Id (https://partner.steamgames.com/doc/sdk/api)
const STEAM_APP_ID_KEY : String = "SteamAppId"
const STEAM_GAME_ID_KEY : String = "SteamGameId"

var authSessionTicket : Dictionary

#region Godots

func _ready() -> void:
	set_process(false)
	Steam.get_auth_session_ticket_response.connect(_on_get_auth_session_ticket_response)

func _exit_tree() -> void:
	if has_auth_session_ticket():
		cancel_auth_session_ticket()

func _process(delta: float) -> void:
	Steam.run_callbacks()

#endregion

#region Initialize
func initialize() -> bool:
	OS.set_environment(STEAM_APP_ID_KEY, STEAM_APP_ID_VALUE)
	OS.set_environment(STEAM_GAME_ID_KEY, STEAM_APP_ID_VALUE)
	var init_response: Dictionary = Steam.steamInitEx(true)
	if init_response.status > 0:
		printerr("Initialize Steam failed with response %s" % init_response)
		return false
	set_process(true)
	return true

#endregion

#region Auth Session Ticket

func create_auth_session_ticket() -> bool:
	authSessionTicket = Steam.getAuthSessionTicket()
	return has_auth_session_ticket()

func cancel_auth_session_ticket() -> void:
	Steam.cancelAuthTicket(authSessionTicket.id)

func has_auth_session_ticket() -> bool:
	return authSessionTicket.size() > 0

func get_auth_session_ticket_string() -> String:
	var ticket : String = ""
	
	for number in authSessionTicket.buffer:
		ticket += "%02X" % number
	
	return ticket

func _on_get_auth_session_ticket_response(this_auth_ticket: int, result: int) -> void:
	print("Auth Session Ticket (%s) return with result %s" % [this_auth_ticket, result])

#endregion
