//NSV NOTE TO SELF: Ensure _all_ ship airlocks have a glass type!

/obj/machinery/door/airlock/ship
	name = "hermetyczny właz"
	icon = 'nsv13/icons/obj/machinery/doors/standard.dmi'
	desc = "Gródź z durastali, która się otwiera i zamyka. Oby przeskakiwanie przez włazy szło ci sprawnie."
	icon_state = "closed"
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_standard.dmi'
	assemblytype = /obj/structure/door_assembly/ship
	anim_parts = "up=0,28;fg=0,0"
	panel_attachment = "up"
	note_attachment = "up"
	// These icon_states stack from bottom to top.
	// Coordinates are x,y movement. -x = left, +x = right, -y = down, +y = up

//Failsafe for the common door type..
/obj/machinery/door/airlock/ship/glass
	opacity = 0
	glass = TRUE

/obj/structure/door_assembly/ship
	name = "zespół: śluza"
	icon = 'nsv13/icons/obj/machinery/doors/standard.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_standard.dmi'
	glass_type = /obj/machinery/door/airlock/ship/glass
	airlock_type = /obj/machinery/door/airlock/ship

/obj/machinery/door/airlock/ship/Initialize(mapload)
	. = ..()
	set_smooth_dir()
	if((dir != NORTH) && (dir != SOUTH))
		LEGACY_OVERLAYS = TRUE
		anim_parts = ""
		rebuild_parts()
		update_icon()

/*

This proc looks like it makes no sense. Bear with me...


Assuming:

X = wall
[] = airlock:


X
[]
X
odir = SOUTH / NORTH. We need it to face sideways so you can get through

X[]X
odir = EAST / WEST. We need it to face forwards so you can get through


*/

/obj/machinery/door/airlock/proc/set_smooth_dir() //I fucking hate this code and so should you :)
//	for(var/atom/obstacle in view(1, src)) //Ghetto ass icon smooth
	var/odir = 0
	var/atom/found = null
	var/turf/north = get_turf(get_step(src,NORTH))
	if(north.density)
		found = north
		odir = NORTH
	var/turf/south = get_turf(get_step(src,SOUTH))
	if(south.density)
		found = south
		odir = SOUTH
	var/turf/east = get_turf(get_step(src,EAST))
	if(east.density)
		found = east
		odir = EAST
	var/turf/west = get_turf(get_step(src,WEST))
	if(west.density)
		found = west
		odir = WEST
	if(!found)
		for(var/atom/foo in get_step(src,NORTH))
			if(foo?.density)
				found = foo
				odir = NORTH
				break
		for(var/atom/foo in get_step(src,SOUTH))
			if(foo?.density)
				found = foo
				odir = SOUTH
				break
		for(var/atom/foo in get_step(src,EAST))
			if(foo?.density)
				found = foo
				odir = EAST
				break
		for(var/atom/foo in get_step(src,WEST))
			if(foo?.density)
				found = foo
				odir = WEST
				break
	if(odir == NORTH || odir == SOUTH)
		dir = EAST
	else
		dir = SOUTH
	return odir



/obj/machinery/door/airlock/ship/station
	name = "standardowa śluza"
	icon = 'nsv13/icons/obj/machinery/doors/station.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays.dmi'
	anim_parts = "left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"
	assemblytype = /obj/structure/door_assembly/ship/station

/obj/machinery/door/airlock/ship/station/glass
	name = "standardowa śluza"
	icon = 'nsv13/icons/obj/machinery/doors/station_glass.dmi'
	opacity = 0
	glass = TRUE

/obj/structure/door_assembly/ship/station
	name = "zespół: standardowa śluza"
	base_name = "standardowa śluza"
	icon = 'nsv13/icons/obj/machinery/doors/station.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays.dmi'
	glass_type = /obj/machinery/door/airlock/ship/station/glass
	airlock_type = /obj/machinery/door/airlock/ship/station



/obj/machinery/door/airlock/ship/station/mining
	name = "śluza górnicza"
	color = "#b88a3d"
	assemblytype = /obj/structure/door_assembly/ship/station/mining

/obj/machinery/door/airlock/ship/station/mining/glass
	icon = 'nsv13/icons/obj/machinery/doors/station_glass.dmi'
	opacity = 0
	glass = TRUE

/obj/structure/door_assembly/ship/station/mining
	name = "zespół: śluza górnicza"
	base_name = "śluza górnicza"
	glass_type = /obj/machinery/door/airlock/ship/station/mining/glass
	airlock_type = /obj/machinery/door/airlock/ship/station/mining


/obj/machinery/door/airlock/ship/station/research
	name = "śluza wydziału badawczego"
	assemblytype = /obj/structure/door_assembly/ship/station/research

/obj/machinery/door/airlock/ship/station/research/glass
	icon = 'nsv13/icons/obj/machinery/doors/station_glass.dmi'
	opacity = 0
	glass = TRUE

/obj/structure/door_assembly/ship/station/research
	name = "zespół: śluza wydziału badawczego"
	base_name = "śluza wydziału badawczego"
	glass_type = /obj/machinery/door/airlock/ship/station/research/glass
	airlock_type = /obj/machinery/door/airlock/ship/station/research



/obj/machinery/door/airlock/ship/hatch
	name = "hermetyczny właz"
	icon = 'nsv13/icons/obj/machinery/doors/hatch.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_hatch.dmi'
	anim_parts = "down_left=-9,-9;down_right=9,-9;up_left=-9,9;up_right=9,9;fg=0,0"
	panel_attachment = "down_right"
	note_attachment = "up_left"
	assemblytype = /obj/structure/door_assembly/ship/hatch

/obj/machinery/door/airlock/ship/hatch/glass
	name = "hermetyczny właz"
	opacity = 0
	glass = TRUE

/obj/structure/door_assembly/ship/hatch
	name = "zespół: hermetyczny właz"
	base_name = "hermetyczny właz"
	glass_type = /obj/machinery/door/airlock/ship/hatch/glass
	airlock_type = /obj/machinery/door/airlock/ship/hatch



/obj/machinery/door/poddoor/ship
	name = "podwójnie wzmocnione drzwi przeciwwybuchowe z durastali"
	icon = 'nsv13/goonstation/icons/blastdoor.dmi'
	desc = "Tytaniczny blok durastali zaprojektowany, by pochłaniać pociski o dużej prędkości, siłę wybuchów i wszelkie uderzenia. Ma potrójną blokadę zamka, która nie przepuści nikogo."

/obj/machinery/door/poddoor/ship/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/poddoor/shutters/ship
	icon = 'nsv13/icons/obj/machinery/doors/shutters.dmi'

/obj/machinery/door/poddoor/shutters/ship/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0



/obj/machinery/door/airlock/ship/command
	name = "Dowództwo"
	icon = 'nsv13/goonstation/icons/command.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"
	assemblytype = /obj/structure/door_assembly/ship/command

/obj/machinery/door/airlock/ship/command/glass
	icon = 'nsv13/goonstation/icons/command_glass.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_goon_glass.dmi'
	opacity = 0
	glass = TRUE
	anim_parts = "bg=0,0;down=0,-30;fg=0,0"
	panel_attachment = "fg"
	note_attachment = "down"

/obj/structure/door_assembly/ship/command
	name = "zespół: śluza dowództwa"
	base_name = "śluza dowództwa"
	glass_type = /obj/machinery/door/airlock/ship/command/glass
	airlock_type = /obj/machinery/door/airlock/ship/command



/obj/machinery/door/airlock/highsecurity/ship
	icon = 'nsv13/icons/obj/machinery/doors/vault.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_vault.dmi'
	anim_parts = "left=-10,0;right=10,0"
	assemblytype = /obj/structure/door_assembly/ship/highsecurity

/obj/machinery/door/airlock/highsecurity/ship/Initialize(mapload)
	. = ..()
	set_smooth_dir()
	if((dir != NORTH) && (dir != SOUTH))
		LEGACY_OVERLAYS = TRUE
		anim_parts = ""
		rebuild_parts()
		update_icon()

/obj/structure/door_assembly/ship/highsecurity
	name = "zespół: zaawansowana śluza ochrony"
	base_name = "zaawansowana śluza ochrony"
	glass_type = /obj/machinery/door/airlock/ship/glass
	airlock_type = /obj/machinery/door/airlock/highsecurity/ship



/obj/machinery/door/airlock/wood
	icon = 'nsv13/goonstation/icons/airlock_wood.dmi'
	overlays_file = 'nsv13/goonstation/icons/airlock_wood.dmi'
	protected_door = TRUE
	LEGACY_OVERLAYS = TRUE
	anim_parts=""


/obj/machinery/door/airlock/vault/ship
	icon = 'nsv13/icons/obj/machinery/doors/vault.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_vault.dmi'
	desc = "Gródź z durastali, która się otwiera i zamyka. Oby przeskakiwanie przez włazy szło ci sprawnie."
	icon_state = "closed"
	anim_parts = "left=-10,0;right=10,0"
	assemblytype = /obj/structure/door_assembly/ship/vault

/obj/machinery/door/airlock/vault/ship/Initialize(mapload)
	. = ..()
	set_smooth_dir()
	if((dir != NORTH) && (dir != SOUTH))
		LEGACY_OVERLAYS = TRUE
		anim_parts = ""
		rebuild_parts()
		update_icon()

/obj/structure/door_assembly/ship/vault
	name = "zespół: drzwi skarbca"
	base_name = "drzwi skarbca"
	glass_type = /obj/machinery/door/airlock/ship/glass
	airlock_type = /obj/machinery/door/airlock/vault/ship



/obj/machinery/door/airlock/ship/engineering
	name = "Skrzydło inżynieryjne"
	icon = 'nsv13/goonstation/icons/engineering.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"
	assemblytype = /obj/structure/door_assembly/ship/engineering

/obj/machinery/door/airlock/ship/engineering/glass
	icon = 'nsv13/goonstation/icons/engineering_glass.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_goon_glass.dmi'
	opacity = 0
	glass = TRUE
	anim_parts = "bg=0,0;down=0,-30;fg=0,0"
	panel_attachment = "fg"
	note_attachment = "down"

/obj/structure/door_assembly/ship/engineering
	name = "zespół: śluza inżynierii"
	base_name = "śluza inżynierii"
	glass_type = /obj/machinery/door/airlock/ship/engineering/glass
	airlock_type = /obj/machinery/door/airlock/ship/engineering



/obj/machinery/door/airlock/ship/external
	name = "śluza zewnętrzna"
	icon = 'nsv13/goonstation/icons/external.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_external.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=15,0"
	panel_attachment = "right"
	note_attachment = "left"
	assemblytype = /obj/structure/door_assembly/ship/external

/obj/machinery/door/airlock/ship/external/glass
	name = "śluza zewnętrzna"
	icon = 'nsv13/goonstation/icons/external_glass.dmi'
	opacity = 0
	glass = TRUE
	anim_parts = "bg=0,0;left=-12,0;right=15,0"

/obj/structure/door_assembly/ship/external
	name = "zespół: śluza zewnętrzna"
	base_name = "śluza zewnętrzna"
	glass_type = /obj/machinery/door/airlock/ship/external/glass
	airlock_type = /obj/machinery/door/airlock/ship/external



/obj/machinery/door/airlock/ship/maintenance
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_goon.dmi'
	name = "tunele techniczne"
	icon = 'nsv13/goonstation/icons/maintenance.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"
	assemblytype = /obj/structure/door_assembly/ship/maintenance

/obj/machinery/door/airlock/ship/maintenance/glass
	opacity = 0
	glass = TRUE

/obj/machinery/door/airlock/ship/maintenance/defaultaccess //Default maint door if you don't want to set up departmental maint access.
	req_one_access_txt = "12"

/obj/structure/door_assembly/ship/maintenance
	name = "zespół: śluza techniczna"
	base_name = "śluza techniczna"
	glass_type = /obj/machinery/door/airlock/ship/maintenance/glass
	airlock_type = /obj/machinery/door/airlock/ship/maintenance



/obj/machinery/door/airlock/ship/public
	name = "śluza publiczna"
	icon = 'nsv13/goonstation/icons/public.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"
	assemblytype = /obj/structure/door_assembly/ship/public

/obj/machinery/door/airlock/ship/public/glass
	icon = 'nsv13/goonstation/icons/airlock_glass.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_goon_glass.dmi'
	opacity = 0
	glass = TRUE
	anim_parts = "bg=0,0;down=0,-30;fg=0,0"
	panel_attachment = "fg"
	note_attachment = "down"

/obj/structure/door_assembly/ship/public
	name = "zespół: śluza publiczna"
	base_name = "śluza publiczna"
	glass_type = /obj/machinery/door/airlock/ship/public/glass
	airlock_type = /obj/machinery/door/airlock/ship/public



/obj/machinery/door/airlock/glass_large/ship
	icon = 'nsv13/icons/obj/machinery/doors/double.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_large.dmi'
	anim_parts=""
	LEGACY_OVERLAYS = TRUE



/obj/machinery/door/airlock/ship/medical
	name = "Ambulatorium"
	icon = 'nsv13/goonstation/icons/medical.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"
	assemblytype = /obj/structure/door_assembly/ship/medical

/obj/machinery/door/airlock/ship/medical/glass
	opacity = 0
	glass = TRUE

/obj/structure/door_assembly/ship/medical
	name = "zespół: śluza medyczna"
	base_name = "śluza medyczna"
	glass_type = /obj/machinery/door/airlock/ship/medical/glass
	airlock_type = /obj/machinery/door/airlock/ship/medical



/obj/machinery/door/airlock/ship/security
	name = "Areszt"
	icon = 'nsv13/goonstation/icons/security.dmi'
	overlays_file = 'nsv13/icons/obj/machinery/doors/overlays/overlays_goon.dmi'
	anim_parts = "bg=0,0;left=-12,0;right=12,0"
	panel_attachment = "right"
	note_attachment = "left"
	assemblytype = /obj/structure/door_assembly/ship/security

/obj/machinery/door/airlock/ship/security/glass
	opacity = 0
	glass = TRUE

/obj/structure/door_assembly/ship/security
	name = "zespół: śluza ochrony"
	base_name = "śluza ochrony"
	glass_type = /obj/machinery/door/airlock/ship/security/glass
	airlock_type = /obj/machinery/door/airlock/ship/security



/obj/machinery/door/airlock/ship/cargo
	name = "Ładownia"
	assemblytype = /obj/structure/door_assembly/ship/cargo

/obj/machinery/door/airlock/ship/cargo/glass
	opacity = 0
	glass = TRUE

/obj/structure/door_assembly/ship/cargo
	name = "zespół: śluza ładowni"
	base_name = "śluza ładowni"
	glass_type = /obj/machinery/door/airlock/ship/cargo/glass
	airlock_type = /obj/machinery/door/airlock/ship/cargo
