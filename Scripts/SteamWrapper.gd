extends Node

const STEAM_APP_ID_VALUE : String = "480" # Default Steam Test App Id (https://partner.steamgames.com/doc/sdk/api)
const STEAM_APP_ID_KEY : String = "SteamAppId"
const STEAM_GAME_ID_KEY : String = "SteamGameId"

var authSessionTicket : Dictionary
var authTicketForWebAPI : Dictionary

signal getAuthSessionTicketCompleted(error: bool)
signal getAuthTicketForWebAPICompleted(error: bool)

#region Godots

func _ready() -> void:
	set_process(false)
	Steam.get_ticket_for_web_api.connect(_on_get_auth_ticket_for_web_api_response)
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

func create_auth_ticker_for_web_api() -> void:
	Steam.getAuthTicketForWebApi("AzurePlayFab")

func cancel_auth_session_ticket() -> void:
	Steam.cancelAuthTicket(authSessionTicket.id)

func has_auth_session_ticket() -> bool:
	return authSessionTicket.size() > 0

func get_auth_session_ticket_string() -> String:
	var ticket: String = ""
	for number in authSessionTicket.buffer:
		ticket += "%02X" % number
	return ticket

func get_auth_ticket_for_web_api_string() -> String:
	var ticket: String = ""
	for number in authTicketForWebAPI.buffer:
		ticket += "%02X" % number
	return ticket

func _on_get_auth_session_ticket_response(auth_ticket: int, result: int) -> void:
	print("Auth Session Ticket (%s) return with the result %s" % [auth_ticket, result])
	getAuthSessionTicketCompleted.emit(result == 0)

func _on_get_auth_ticket_for_web_api_response(auth_ticket: int, result: int, ticket_size: int, ticket_buffer: Array) -> void:
	print("Auth Ticker For Web API (%s) return with the result %s" % [auth_ticket, result])
	authTicketForWebAPI.id = auth_ticket
	authTicketForWebAPI.buffer = ticket_buffer
	authTicketForWebAPI.size = ticket_size
	getAuthTicketForWebAPICompleted.emit(result == 0)

#endregion
