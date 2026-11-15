// AQUILA - typy planet: skalista, białych piasków, pustynna i mglista (Shiptest: code/modules/overmap/planets/
// planet_types.dm i obszary z code/modules/overmap/objects/dynamic_datum.dm, AGPLv3). Biomy w biomes/piaski.dm,
// teren w shiptest_flora/piaski.dm, żyły w drill/veins_piaski.dm, ruiny w ruins/planet_piaski_ruins.dm.
// Planeta mglista zagłusza radio, kamery i czujniki skafandrów na powierzchni i w swoich ruinach (Shiptest:
// interference_power = 100): nadpisanie /atom/is_jammed sprawdza planet_radio_jamming obszaru.

/datum/planet_type/rock
	name = "planeta skalista"
	desc = "Rdzawy, czerwony świat w trakcie terraformowania. Część roślin się przyjęła, ale planeta wciąż jest wroga życiu."
	overmap_icon_state = "planet_rocky"
	overmap_color = "#e07a6a"
	generator_type = /datum/planet_generator/rock
	surface_area_type = /area/planet/surface/rock
	cave_area_type = /area/planet/surface/cave/rock
	atmosphere_desc = "dwutlenek węgla z azotem, nie do oddychania"
	temperature_desc = "chłodna, ok. -10 °C"
	hazard_desc = "burze piaskowe, wrogia fauna (gruboidy, migo, stwory)"
	weather_types = list(/datum/weather/planet/sandstorm/rockplanet/harmless = 80, /datum/weather/planet/sandstorm/rockplanet = 20, /datum/weather/planet/snowfall = 5)
	ground_turf_type = /turf/open/floor/plating/asteroid/rockplanet
	vein_root = /obj/structure/vein/rockplanet
	mission_veins = list(
		"1" = /obj/structure/vein/rockplanet,
		"2" = /obj/structure/vein/rockplanet/classtwo,
		"3" = list(/obj/structure/vein/rockplanet/classthree = 2, /obj/structure/vein/rockplanet/classthree/rare = 1),
		"4" = /obj/structure/vein/rockplanet/classfour,
	)
	system_tags = list("safe" = 2, "debris" = 1, "pirate" = 1)
	fixed_systems = list("Ross 154", "Lalande 21185", "Romulus")

/datum/planet_type/rock/get_ruin_templates()
	return list()

/datum/planet_type/rock/get_main_ruin_templates()
	return get_planet_ruin_templates(/datum/map_template/ruin/planet_rock)

/datum/planet_type/sand
	name = "planeta białych piasków"
	desc = "Niegdyś tętniący życiem świat, który wojna zamieniła w solony piasek. Ocaleni dawno postradali zmysły."
	overmap_icon_state = "planet_cloud"
	overmap_color = "#e4e0ea"
	generator_type = /datum/planet_generator/sand
	surface_area_type = /area/planet/surface/sand
	cave_area_type = /area/planet/surface/cave/sand
	atmosphere_desc = "rzadka, ledwo do oddychania"
	temperature_desc = "mroźna, ok. -25 °C"
	hazard_desc = "burze piaskowe, kwaśne jeziorka, wrogia fauna (goliaty, bazyliszki, legiony), pustelnicy"
	weather_types = list(/datum/weather/planet/sandstorm = 100)
	ground_turf_type = /turf/open/floor/plating/asteroid/whitesands
	vein_root = /obj/structure/vein/sand
	mission_veins = list(
		"1" = /obj/structure/vein/sand,
		"2" = list(/obj/structure/vein/sand/classtwo = 2, /obj/structure/vein/sand/classtwo/rare = 1),
		"3" = list(/obj/structure/vein/sand/classthree = 2, /obj/structure/vein/sand/classthree/rare = 1),
	)
	system_tags = list("safe" = 1, "demonstar" = 1)
	fixed_systems = list("Feliciana", "Chalawan")

/datum/planet_type/sand/get_ruin_templates()
	return list()

/datum/planet_type/sand/get_main_ruin_templates()
	return get_planet_ruin_templates(/datum/map_template/ruin/planet_sand)

/datum/planet_type/desert
	name = "planeta pustynna"
	desc = "Bardzo gorąca i surowa planeta, z której dochodzi słaby sygnał energetyczny."
	overmap_icon_state = "planet_rockocean"
	overmap_color = "#f3c282"
	generator_type = /datum/planet_generator/desert
	surface_area_type = /area/planet/surface/desert
	cave_area_type = /area/planet/surface/cave/desert
	atmosphere_desc = "oddychalna"
	temperature_desc = "gorąca, ok. 40 °C"
	hazard_desc = "burze piaskowe, mrówkolwy"
	weather_types = list(/datum/weather/planet/sandstorm/desert = 100)
	ground_turf_type = /turf/open/floor/plating/asteroid/desert
	vein_root = /obj/structure/vein/desert
	mission_veins = list(
		"1" = /obj/structure/vein/desert,
		"2" = /obj/structure/vein/desert/classtwo,
		"3" = /obj/structure/vein/desert/classthree,
	)
	system_tags = list("safe" = 2, "demonstar" = 1, "quasar" = 1)
	fixed_systems = list("Economus", "Oasis Fidei")

/datum/planet_type/desert/get_ruin_templates()
	return list()

/datum/planet_type/desert/get_main_ruin_templates()
	return get_planet_ruin_templates(/datum/map_template/ruin/planet_desert)

/datum/planet_type/shrouded
	name = "planeta mglista"
	desc = "Planeta spowita wieczną burzą dziwnych cząstek, które pochłaniają prawie całe widmo elektromagnetyczne. Sygnał z niej ledwo się przebija."
	overmap_icon_state = "planet_swirly"
	overmap_color = "#8a4cb8"
	generator_type = /datum/planet_generator/shrouded
	surface_area_type = /area/planet/surface/shrouded
	cave_area_type = /area/planet/surface/cave/shrouded
	atmosphere_desc = "oddychalna"
	temperature_desc = "chłodna, ok. 0 °C"
	hazard_desc = "ciemność, burze elektryczne, zagłuszanie łączności, gniazda obcych pod powierzchnią"
	weather_types = list(/datum/weather/planet/shroud_storm = 100)
	ground_turf_type = /turf/open/floor/plating/asteroid/shrouded
	vein_root = /obj/structure/vein/shrouded
	mission_veins = list(
		"1" = /obj/structure/vein/shrouded,
		"2" = /obj/structure/vein/shrouded/classtwo,
		"3" = /obj/structure/vein/shrouded/classthree,
	)
	system_tags = list("hazardous" = 3, "nebula" = 1, "blackhole" = 1)
	fixed_systems = list("Abassi", "Remus")
	// Na powierzchni nie ma roślin ani zwierząt (fauna tylko z żył): bez próbek do Badania planety
	mission_target = FALSE

/datum/planet_type/shrouded/get_ruin_templates()
	return list()

/datum/planet_type/shrouded/get_main_ruin_templates()
	return get_planet_ruin_templates(/datum/map_template/ruin/planet_shrouded)

/// Pyłowa planeta karłowata: białe piaski na małej mapie, bez ruin, z bogatszymi żyłami
/datum/planet_type/dwarf/dust
	name = "pyłowa planeta karłowata"
	desc = "Świat w całości pokryty pyłem. Na pewno nie ma tu nic ciekawego poza rudą pod spodem, a awaryjne lądowanie byłoby tu koszmarem."
	overmap_icon_state = "planet_small"
	overmap_color = "#bf9b9b"
	generator_type = /datum/planet_generator/dwarf_dust
	surface_area_type = /area/planet/surface/dwarf_dust
	cave_area_type = /area/planet/surface/cave/sand
	atmosphere_desc = "rzadka, ledwo do oddychania"
	temperature_desc = "mroźna, ok. -25 °C"
	hazard_desc = "ostre burze piaskowe"
	weather_types = list(/datum/weather/planet/sandstorm/rockplanet = 80, /datum/weather/planet/sandstorm/rockplanet/harmless = 20)
	ground_turf_type = /turf/open/floor/plating/asteroid/whitesands
	vein_root = /obj/structure/vein/sand
	mission_veins = list(
		"1" = /obj/structure/vein/sand,
		"2" = list(/obj/structure/vein/sand/classtwo = 2, /obj/structure/vein/sand/classtwo/rare = 1),
		"3" = list(/obj/structure/vein/sand/classthree = 2, /obj/structure/vein/sand/classthree/rare = 1),
	)
	system_tags = list("safe" = 1, "debris" = 1)
	fixed_systems = list("Atik")
	mission_target = TRUE

/// Wydmowa planeta karłowata: pustynia na małej mapie, bez ruin, z bogatszymi żyłami
/datum/planet_type/dwarf/dune
	name = "wydmowa planeta karłowata"
	desc = "Świat w całości pokryty gorącym, suchym piaskiem. Na pewno nie ma tu nic ciekawego poza rudą pod spodem."
	overmap_icon_state = "planet_small"
	overmap_color = "#f3c282"
	generator_type = /datum/planet_generator/dwarf_dune
	surface_area_type = /area/planet/surface/dwarf_dune
	cave_area_type = /area/planet/surface/cave/desert
	atmosphere_desc = "oddychalna"
	temperature_desc = "gorąca, ok. 40 °C"
	hazard_desc = "ostre burze piaskowe, mrówkolwy"
	weather_types = list(/datum/weather/planet/sandstorm/rockplanet = 80, /datum/weather/planet/sandstorm/rockplanet/harmless = 20)
	ground_turf_type = /turf/open/floor/plating/asteroid/desert
	vein_root = /obj/structure/vein/desert
	mission_veins = list(
		"1" = /obj/structure/vein/desert,
		"2" = /obj/structure/vein/desert/classtwo,
		"3" = /obj/structure/vein/desert/classthree,
	)
	system_tags = list("safe" = 1, "quasar" = 1)
	fixed_systems = list("Priar")
	// Same wydmy bez roślin: bez próbek flory do Badania planety
	mission_target = FALSE

// Obszary: kolor i moc światła jak w Shiptest (COLOR_ROCKPLANET_LIGHT, COLOR_SANDPLANET_LIGHT itd.; moc 0,6 -> 55)

/area/planet/surface/rock
	name = "Rdzawe Pustkowia"
	lighting_overlay_colour = "#db9e9f"
	lighting_overlay_opacity = 55
	sound_environment = SOUND_ENVIRONMENT_QUARRY

/area/planet/surface/cave/rock
	name = "Rdzawe Jaskinie"

/area/planet/surface/sand
	name = "Białe Piaski"
	lighting_overlay_colour = "#eeeeee"
	lighting_overlay_opacity = 55
	sound_environment = SOUND_ENVIRONMENT_PLAIN

/area/planet/surface/cave/sand
	name = "Jaskinie Białych Piasków"

/area/planet/surface/desert
	name = "Pustynia"
	lighting_overlay_colour = "#ffd2bd"
	lighting_overlay_opacity = 55
	sound_environment = SOUND_ENVIRONMENT_MOUNTAINS

/area/planet/surface/cave/desert
	name = "Jaskinie Pustyni"

/// Bez światła: mgła pochłania prawie wszystko
/area/planet/surface/shrouded
	name = "Spowite Pustkowia"
	lighting_overlay_opacity = 0
	sound_environment = SOUND_ENVIRONMENT_MOUNTAINS
	planet_radio_jamming = TRUE

/area/planet/surface/cave/shrouded
	name = "Spowite Jaskinie"
	planet_radio_jamming = TRUE

/area/ruin/unpowered/planet_shrouded
	planet_radio_jamming = TRUE

/area/planet/surface/dwarf_dust
	name = "Pyłowe Pustkowia"
	lighting_overlay_colour = "#bf9b9b"
	lighting_overlay_opacity = 90
	sound_environment = SOUND_ENVIRONMENT_PLAIN

/area/planet/surface/dwarf_dune
	name = "Wydmy"
	lighting_overlay_colour = "#ffd2bd"
	lighting_overlay_opacity = 55
	sound_environment = SOUND_ENVIRONMENT_PLAIN

/area
	/// Obszar planety mglistej: radio, kamery i czujniki skafandrów w nim nie działają (jak zagłuszacz)
	var/planet_radio_jamming = FALSE

/atom/is_jammed()
	. = ..()
	if(.)
		return
	var/area/our_area = get_area(src)
	return our_area?.planet_radio_jamming

// Greeble białych piasków (Shiptest: code/datums/mapgen/greebles/sandplanet.dm): rzadka oaza i kałuże siarki

/obj/effect/greeble_spawner/whitesands_oasis
	name = "spawner oazy"
	greeble_maps = list('aquila/_maps/greebles/whitesands/oasis_1.dmm' = 1)

/obj/effect/greeble_spawner/whitesands_sulfurpool
	name = "spawner kałuży siarki"
	greeble_maps = list(
		'aquila/_maps/greebles/whitesands/sulfur_pool_1.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_2.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_3.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_4.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_5.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_6.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_7.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_8.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_9.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_10.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_11.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_12.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_13.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_14.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_15.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_16.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_17.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_18.dmm' = 5,
		'aquila/_maps/greebles/whitesands/sulfur_pool_19.dmm' = 5,
	)
