
/atom/movable/screen/blob
	icon = 'icons/mob/blob.dmi'

/atom/movable/screen/blob/MouseEntered(location,control,params)
	..() // AQ EDIT - screentips potrzebują /atom/MouseEntered() (port BeeStation #11938)
	openToolTip(usr,src,params,title = name,content = desc, theme = "blob")

/atom/movable/screen/blob/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/blob/BlobHelp
	icon_state = "ui_help"
	name = "Pomoc grzyba"
	desc = "Jak grać grzybem!"

/atom/movable/screen/blob/BlobHelp/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.blob_help()

/atom/movable/screen/blob/JumpToNode
	icon_state = "ui_tonode"
	name = "Skocz do węzła"
	desc = "Przenosi twoją kamerę do wybranego węzła grzyba."

/atom/movable/screen/blob/JumpToNode/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.jump_to_node()

/atom/movable/screen/blob/JumpToCore
	icon_state = "ui_tocore"
	name = "Skocz do rdzenia"
	desc = "Przenosi twoją kamerę do rdzenia grzyba."

/atom/movable/screen/blob/JumpToCore/MouseEntered(location,control,params)
	if(hud?.mymob && isovermind(hud.mymob))
		var/mob/camera/blob/B = hud.mymob
		if(!B.placed)
			name = "Umieść rdzeń grzyba"
			desc = "Próbuje umieścić rdzeń grzyba w tym miejscu."
		else
			name = initial(name)
			desc = initial(desc)
	..()

/atom/movable/screen/blob/JumpToCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		if(!B.placed)
			B.place_blob_core(0)
		B.transport_core()

/atom/movable/screen/blob/Blobbernaut
	icon_state = "ui_blobbernaut"
	name = "Wyhoduj grzybonauta (40)"
	desc = "Za 40 zasobów tworzy z grzyba fabrycznego silnego, sprytnego grzybonauta.<br>Użyty grzyb fabryczny staje się kruchy i przestaje wytwarzać zarodniki."

/atom/movable/screen/blob/Blobbernaut/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_blobbernaut()

/atom/movable/screen/blob/ResourceBlob
	icon_state = "ui_resource"
	name = "Wyhoduj grzyb zasobów (40)"
	desc = "Za 40 zasobów tworzy grzyb zasobów.<br>Grzyby zasobów co kilka sekund dają ci zasoby."

/atom/movable/screen/blob/ResourceBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_resource()

/atom/movable/screen/blob/NodeBlob
	icon_state = "ui_node"
	name = "Wyhoduj węzeł (50)"
	desc = "Za 50 zasobów tworzy węzeł.<br>Węzły rozrastają się i aktywują pobliskie grzyby zasobów i grzyby fabryczne."

/atom/movable/screen/blob/NodeBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_node()

/atom/movable/screen/blob/FactoryBlob
	icon_state = "ui_factory"
	name = "Wyhoduj grzyb fabryczny (60)"
	desc = "Za 60 zasobów tworzy grzyb fabryczny.<br>Grzyby fabryczne co kilka sekund wytwarzają zarodniki."

/atom/movable/screen/blob/FactoryBlob/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.create_factory()

/atom/movable/screen/blob/ReadaptStrain
	icon_state = "ui_chemswap"
	name = "Zmień szczep"
	desc = "Za 40 zasobów pozwala wybrać nowy szczep spośród 4 losowych."

/atom/movable/screen/blob/ReadaptStrain/MouseEntered(location,control,params)
	if(hud && hud.mymob && isovermind(hud.mymob))
		var/mob/camera/blob/B = hud.mymob
		if(B.free_strain_rerolls)
			name = "[initial(name)] (ZA DARMO)"
			desc = "Za darmo losuje ci nowy szczep."
		else
			name = "[initial(name)] ([BLOB_REROLL_COST])"
			desc = initial(desc)
	..()

/atom/movable/screen/blob/ReadaptStrain/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.strain_reroll()

/atom/movable/screen/blob/RelocateCore
	icon_state = "ui_swap"
	name = "Przenieś rdzeń (80)"
	desc = "Za 80 zasobów zamienia miejscami węzeł i twój rdzeń."

/atom/movable/screen/blob/RelocateCore/Click()
	if(isovermind(usr))
		var/mob/camera/blob/B = usr
		B.relocate_core()

/datum/hud/blob_overmind/New(mob/owner)
	..()
	var/atom/movable/screen/using

	blobpwrdisplay = new /atom/movable/screen()
	blobpwrdisplay.name = "moc grzyba"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blobpwrdisplay.layer = ABOVE_HUD_LAYER
	blobpwrdisplay.plane = ABOVE_HUD_PLANE
	blobpwrdisplay.hud = src
	infodisplay += blobpwrdisplay

	healths = new /atom/movable/screen/healths/blob()
	healths.hud = src
	infodisplay += healths

	using = new /atom/movable/screen/blob/BlobHelp()
	using.screen_loc = "WEST:6,NORTH:-3"
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/JumpToNode()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/JumpToCore()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/Blobbernaut()
	using.screen_loc = ui_belt
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/ResourceBlob()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/NodeBlob()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/FactoryBlob()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/ReadaptStrain()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/blob/RelocateCore()
	using.screen_loc = ui_storage2
	using.hud = src
	static_inventory += using
