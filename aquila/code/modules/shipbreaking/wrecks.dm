// Wraki do złomowania: mapy (oczyszczone kopie naszych shuttli i wnętrz NSV) i wraki na overmapie, które łapie magnes.

/// Frakcja dla wraków bez okrętu-źródła (losowe wraki w systemach)
#define SHIPBREAK_FACTION_ANY "any"

/datum/map_template/shipbreaker
	name = "wrak"
	/// Frakcje, których zestrzelone okręty mogą zostawić ten wrak
	var/list/factions = list(SHIPBREAK_FACTION_ANY)

/datum/map_template/shipbreaker/dropship_main
	name = "wrak desantowca NT"
	mappath = 'aquila/_maps/shipbreaking/dropship_main.dmm'
	factions = list("nanotrasen")

/datum/map_template/shipbreaker/sabre
	name = "wrak Sabre"
	mappath = 'aquila/_maps/shipbreaking/sabre.dmm'
	factions = list("nanotrasen")

/datum/map_template/shipbreaker/exploration
	name = "wrak promu eksploracyjnego"
	mappath = 'aquila/_maps/shipbreaking/exploration.dmm'
	factions = list("nanotrasen", SHIPBREAK_FACTION_ANY)

/datum/map_template/shipbreaker/mining_large
	name = "wrak promu górniczego"
	mappath = 'aquila/_maps/shipbreaking/mining_large.dmm'
	factions = list("nanotrasen", SHIPBREAK_FACTION_ANY)

/datum/map_template/shipbreaker/whiteship_pubby
	name = "wrak białego statku (Pubby)"
	mappath = 'aquila/_maps/shipbreaking/whiteship_pubby.dmm'
	factions = list("nanotrasen", SHIPBREAK_FACTION_ANY)

/datum/map_template/shipbreaker/dropship_syndicate
	name = "wrak desantowca Syndykatu"
	mappath = 'aquila/_maps/shipbreaking/dropship_syndicate.dmm'
	factions = list("syndicate")

/datum/map_template/shipbreaker/sabre_syndicate
	name = "wrak Sabre Syndykatu"
	mappath = 'aquila/_maps/shipbreaking/sabre_syndicate.dmm'
	factions = list("syndicate")

/datum/map_template/shipbreaker/syndicate_dropship
	name = "wrak kanonierki Syndykatu"
	mappath = 'aquila/_maps/shipbreaking/syndicate_dropship.dmm'
	factions = list("syndicate")

/datum/map_template/shipbreaker/syndicate_shiv
	name = "wrak myśliwca Shiv"
	mappath = 'aquila/_maps/shipbreaking/syndicate_shiv.dmm'
	factions = list("syndicate")

/datum/map_template/shipbreaker/infiltrator
	name = "wrak infiltratora"
	mappath = 'aquila/_maps/shipbreaking/infiltrator.dmm'
	factions = list("syndicate")

/datum/map_template/shipbreaker/pirate_ship
	name = "wrak okrętu pirackiego"
	mappath = 'aquila/_maps/shipbreaking/pirate_ship.dmm'
	factions = list("pirate")

/datum/map_template/shipbreaker/pirate_cutter
	name = "wrak pirackiego kutra"
	mappath = 'aquila/_maps/shipbreaking/pirate_cutter.dmm'
	factions = list("pirate")

/datum/map_template/shipbreaker/hunter_russian
	name = "wrak statku łowców (rosyjski)"
	mappath = 'aquila/_maps/shipbreaking/hunter_russian.dmm'
	factions = list("pirate")

/datum/map_template/shipbreaker/hunter_bounty
	name = "wrak statku łowców nagród"
	mappath = 'aquila/_maps/shipbreaking/hunter_bounty.dmm'
	factions = list("pirate", SHIPBREAK_FACTION_ANY)

/datum/map_template/shipbreaker/hunter_space_cop
	name = "wrak radiowozu"
	mappath = 'aquila/_maps/shipbreaking/hunter_space_cop.dmm'

/datum/map_template/shipbreaker/whiteship_cere
	name = "wrak białego statku (Cere)"
	mappath = 'aquila/_maps/shipbreaking/whiteship_cere.dmm'

/datum/map_template/shipbreaker/whiteship_fland
	name = "wrak białego statku (Fland)"
	mappath = 'aquila/_maps/shipbreaking/whiteship_fland.dmm'

/datum/map_template/shipbreaker/caravan
	name = "wrak karawany handlowej"
	mappath = 'aquila/_maps/shipbreaking/caravan.dmm'

/datum/map_template/shipbreaker/emergency_goon
	name = "wrak promu ewakuacyjnego"
	mappath = 'aquila/_maps/shipbreaking/emergency_goon.dmm'

/datum/map_template/shipbreaker/emergency_scrapheap
	name = "wrak złomiarki"
	mappath = 'aquila/_maps/shipbreaking/emergency_scrapheap.dmm'

GLOBAL_LIST_EMPTY(shipbreaker_templates)

/// Wszystkie szablony wraków (tworzone przy pierwszym użyciu)
/proc/get_shipbreaker_templates()
	if(!length(GLOB.shipbreaker_templates))
		for(var/template_type in subtypesof(/datum/map_template/shipbreaker))
			GLOB.shipbreaker_templates += new template_type()
	return GLOB.shipbreaker_templates

/// Losowy szablon wraku dla frakcji (bez pasującego: dowolny)
/proc/pick_shipbreaker_template(faction)
	var/list/matching = list()
	for(var/datum/map_template/shipbreaker/template as anything in get_shipbreaker_templates())
		if(faction in template.factions)
			matching += template
	if(!length(matching))
		matching = get_shipbreaker_templates()
	return pick(matching)

/// Wrak na overmapie. To podtyp asteroidy, bo AI go nie atakuje, radar pokazuje go jak asteroidę, a magnes umie go złapać.
/obj/structure/overmap/asteroid/shipbreak_wreck
	name = "Wrak"
	desc = "Dryfujący wrak okrętu. Magnes na asteroidy może go przyciągnąć do klatki, gdzie da się go rozebrać na złom."
	icon = 'nsv13/icons/overmap/syndicate/gunboat.dmi'
	icon_state = "gunboat-25"
	color = "#8a8a8a"
	bound_width = 96
	bound_height = 96
	core_composition = list()
	/// Frakcja okrętu, z którego został wrak (decyduje o mapie)
	var/wreck_faction = SHIPBREAK_FACTION_ANY

/obj/structure/overmap/asteroid/shipbreak_wreck/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state) // asteroida losuje sobie wygląd

/// Wygląd i frakcja po zestrzelonym okręcie
/obj/structure/overmap/asteroid/shipbreak_wreck/proc/copy_ship(obj/structure/overmap/source)
	name = "Wrak [source.name]"
	wreck_faction = source.faction
	icon = source.icon
	icon_state = source.icon_state
	bound_width = source.bound_width
	bound_height = source.bound_height
	angle = source.angle
	desired_angle = angle

// Myśliwce nie dokują do wraków (wnętrze wraku istnieje tylko w klatce magnesu)
/obj/structure/overmap/small_craft/docking_act(obj/structure/overmap/OM)
	if(istype(OM, /obj/structure/overmap/asteroid/shipbreak_wreck))
		return FALSE
	return ..()

/obj/structure/overmap/obj_destruction(damage_flag)
	leave_shipbreak_wreck()
	return ..()

/// Zestrzelony okręt zostawia wrak w miejscu, gdzie zginął
/obj/structure/overmap/proc/leave_shipbreak_wreck()
	if(role == MAIN_OVERMAP || isasteroid(src) || !current_system || !faction || faction == "hostile")
		return
	if(istype(src, /obj/structure/overmap/small_craft) && !prob(25))
		return
	var/turf/death_turf = get_turf(src)
	if(!death_turf || !SSmapping.level_trait(death_turf.z, ZTRAIT_OVERMAP))
		return
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = new(death_turf)
	wreck.copy_ship(src)
	current_system.add_ship(wreck, death_turf)
	wreck.forceMove(death_turf) // add_ship rozrzuca w promieniu 15 pól, a wrak ma zostać tam, gdzie okręt zginął

// Czasem w systemie dryfuje wrak bez walki
/datum/star_system/spawn_asteroids()
	. = ..()
	if(prob(50))
		SSstar_system.spawn_ship(/obj/structure/overmap/asteroid/shipbreak_wreck, src)
