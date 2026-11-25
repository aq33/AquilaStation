/// AQUILA - menu lobby (telewizorek z odliczaniem do rundy). SSprocessing nie działa w fazie lobby (brak RUNLEVEL_LOBBY),
/// więc odliczanie stało w miejscu i zmieniało się tylko po kliknięciu w menu.
PROCESSING_SUBSYSTEM_DEF(lobby_hud)
	name = "Lobby HUD"
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	wait = 1 SECONDS
	stat_tag = "LH"
