/// AQUILA - nowe sprite'y okrętów (aquila/icons/overmap/ships/). Rysują się na overmapie w skali 1:1 ze swoich pikseli
/// (overmap_native_sprite): wszystkie są narysowane w jednej skali, więc nie mają ręcznych proporcji, a hitbox i siatka
/// modułów liczą się z ich klatki i obrysu. Statki bez nowego sprite'a (SolGov, Alicorn, Hellfire, Aspala, stacje) zostają
/// przy dawnej skali z overmap_visual_scale.dm.
/// Małe jednostki (myśliwce, promy) dostają nowy sprite tylko na overmapie (overmap_sprite_icon); na pokładzie, w hangarze
/// i w dokach rysują się dawnym sprite'em w skali pokładowej, żeby w kabinie mieścił się człowiek.

/obj/structure/overmap
	/// AQUILA - okręt rysuje się nowym sprite'em w skali 1:1
	var/overmap_native_sprite = FALSE
	/// AQUILA - sprite tylko na overmapie (małe jednostki); na pokładzie zostaje icon/icon_state z definicji typu
	var/overmap_sprite_icon
	var/overmap_sprite_state

/obj/structure/overmap/Initialize(mapload)
	. = ..()
	if(overmap_sprite_icon)
		update_overmap_sprite()

/obj/structure/overmap/onTransitZ(old_z, new_z)
	. = ..()
	if(overmap_sprite_icon)
		update_overmap_sprite()

/// Czy okręt rysuje się teraz nowym sprite'em (1:1)
/obj/structure/overmap/proc/uses_native_sprite()
	if(overmap_sprite_icon)
		return icon == overmap_sprite_icon
	return overmap_native_sprite

/// Mała jednostka: na overmapie nowy sprite, poza nią sprite z definicji typu. Hitbox idzie za klatką sprite'a.
/obj/structure/overmap/proc/update_overmap_sprite()
	var/on_overmap = z && SSmapping.level_trait(z, ZTRAIT_OVERMAP)
	var/new_icon = on_overmap ? overmap_sprite_icon : initial(icon)
	var/new_state = on_overmap ? overmap_sprite_state : initial(icon_state)
	if(icon == new_icon && icon_state == new_state)
		return
	icon = new_icon
	icon_state = new_state
	var/icon/I = icon(icon, icon_state, SOUTH)
	pixel_collision_size_x = I.Width()
	pixel_collision_size_y = I.Height()
	var/obj/structure/overmap/small_craft/craft = src
	if(istype(craft))
		craft.update_visuals() // owiewka z ikony pokładowej; nowy sprite jej nie ma, więc na overmapie znika
	apply_overmap_hitbox()

// Typy, które rysują się nowym sprite'em. Wersje elitarne mają ten sam sprite co zwykłe.

// --- Nanotrasen ---

/obj/structure/overmap/nanotrasen/ai/fighter
	icon = 'aquila/icons/overmap/ships/nanotrasen-small-ships.dmi'
	icon_state = "wrobel"
	overmap_native_sprite = TRUE

/obj/structure/overmap/small_craft/combat/light
	overmap_sprite_icon = 'aquila/icons/overmap/ships/nanotrasen-small-ships.dmi'
	overmap_sprite_state = "wrobel"

/obj/structure/overmap/small_craft/combat/heavy
	overmap_sprite_icon = 'aquila/icons/overmap/ships/nanotrasen-small-ships.dmi'
	overmap_sprite_state = "czapla"

/obj/structure/overmap/small_craft/transport
	overmap_sprite_icon = 'aquila/icons/overmap/ships/nanotrasen-dropship.dmi'
	overmap_sprite_state = "mewa"

/obj/structure/overmap/small_craft/transport/sabre
	overmap_sprite_icon = 'aquila/icons/overmap/ships/nanotrasen-small-ships.dmi'
	overmap_sprite_state = "bocian"

// Promy Syndykatu i prom składany przez graczy zostają przy swoich sprite'ach
/obj/structure/overmap/small_craft/transport/sabre/syndicate
	overmap_sprite_icon = null

/obj/structure/overmap/small_craft/transport/syndicate
	overmap_sprite_icon = null

/obj/structure/overmap/small_craft/transport/custom_shuttle
	overmap_sprite_icon = null

/obj/structure/overmap/nanotrasen/light_cruiser
	icon = 'aquila/icons/overmap/ships/nanotrasen-light-frigate.dmi'
	icon_state = "szprot"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/serendipity/starter
	icon = 'aquila/icons/overmap/ships/nanotrasen-light-frigate.dmi'
	icon_state = "szprot"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/patrol_cruiser/starter
	icon = 'aquila/icons/overmap/ships/nanotrasen-light-frigate.dmi'
	icon_state = "szprot"
	overmap_native_sprite = TRUE
	damage_states = FALSE

// Karaś: kadłub bez broni i obracane działa (ship_turrets.dm)
/obj/structure/overmap/nanotrasen/frigate
	icon = 'aquila/icons/overmap/aquilas.dmi'
	icon_state = "aquilas-no-weapons"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/frigate/starter/shrike
	icon_state = "aquilas-no-weapons"

/obj/structure/overmap/nanotrasen/frigate/Initialize(mapload)
	turret_mounts = GLOB.aquilas_turret_mounts
	return ..()

/obj/structure/overmap/nanotrasen/heavy_cruiser/starter
	icon = 'aquila/icons/overmap/aquilas.dmi'
	icon_state = "aquilas-no-weapons"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/heavy_cruiser/starter/Initialize(mapload)
	turret_mounts = GLOB.aquilas_turret_mounts
	return ..()

/obj/structure/overmap/nanotrasen/patrol_cruiser/ai
	icon = 'aquila/icons/overmap/ships/nanotrasen-light-destroyer.dmi'
	icon_state = "grzmot"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/ai
	icon = 'aquila/icons/overmap/ships/nanotrasen-heavy-destroyer.dmi'
	icon_state = "blyskawica"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/battlecruiser/ai
	icon = 'aquila/icons/overmap/ships/nanotrasen-cruiser.dmi'
	icon_state = "goliat"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/heavy_cruiser/ai
	icon = 'aquila/icons/overmap/ships/nanotrasen-cruiser.dmi'
	icon_state = "goliat"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/gunstar
	icon = 'aquila/icons/overmap/ships/nanotrasen-cruiser.dmi'
	icon_state = "goliat"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/carrier/ai
	icon = 'aquila/icons/overmap/ships/nanotrasen-carrier.dmi'
	icon_state = "husaria"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/battleship/ai
	icon = 'aquila/icons/overmap/ships/nanotrasen-battleship.dmi'
	icon_state = "kosciuszko"
	overmap_native_sprite = TRUE
	damage_states = FALSE

// Frachtowce: Karawana albo Żywiciel, losowo
/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian
	icon = 'aquila/icons/overmap/ships/cargoship.dmi'
	icon_state = "karawana_nt"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian/Initialize(mapload)
	if(prob(50))
		icon = 'aquila/icons/overmap/ships/tankership.dmi'
		icon_state = "zywiciel_nt"
	return ..()

// --- Syndykat ---

/obj/structure/overmap/syndicate/ai/fighter
	icon = 'aquila/icons/overmap/ships/syndie-small-ships.dmi'
	icon_state = "szerszen"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/small_craft/combat/light/syndicate
	overmap_sprite_icon = 'aquila/icons/overmap/ships/syndie-small-ships.dmi'
	overmap_sprite_state = "szerszen"

/obj/structure/overmap/syndicate/ai/bomber
	icon = 'aquila/icons/overmap/ships/syndie-small-ships.dmi'
	icon_state = "bombardier"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate
	icon = 'aquila/icons/overmap/ships/syndie-dropship.dmi'
	icon_state = "tkaczka"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai
	icon = 'aquila/icons/overmap/ships/syndie-frigate.dmi'
	icon_state = "modliszka"
	overmap_native_sprite = TRUE
	damage_states = FALSE

// Hellfire i Aspala nie mają nowego sprite'a: zostają w dawnej skali
/obj/structure/overmap/syndicate/ai/conflagration
	overmap_native_sprite = FALSE

/obj/structure/overmap/syndicate/ai/submarine
	overmap_native_sprite = FALSE

/obj/structure/overmap/syndicate/ai/gunboat
	icon = 'aquila/icons/overmap/ships/syndie-frigate.dmi'
	icon_state = "modliszka"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/mako_flak
	icon = 'aquila/icons/overmap/ships/syndie-light-destroyer.dmi'
	icon_state = "biegacz"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/mako_carrier
	icon = 'aquila/icons/overmap/ships/syndie-light-destroyer.dmi'
	icon_state = "biegacz"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/destroyer
	icon = 'aquila/icons/overmap/ships/syndie-heavy-destroyer.dmi'
	icon_state = "szablak"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/destroyer/elite
	icon_state = "szablak"

/obj/structure/overmap/syndicate/ai/destroyer/flak
	icon_state = "szablak"

/obj/structure/overmap/syndicate/ai/cruiser
	icon = 'aquila/icons/overmap/ships/syndie-cruiser.dmi'
	icon_state = "rogacz"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/cruiser/elite
	icon_state = "rogacz"

/obj/structure/overmap/syndicate/ai/assault_cruiser
	icon = 'aquila/icons/overmap/ships/syndie-cruiser.dmi'
	icon_state = "rogacz"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/carrier
	icon = 'aquila/icons/overmap/ships/syndie-carrier.dmi'
	icon_state = "trzmiel"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/carrier/elite
	icon_state = "trzmiel"

/obj/structure/overmap/syndicate/ai/kadesh
	icon = 'aquila/icons/overmap/ships/syndie-battleship.dmi'
	icon_state = "atlas"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/battleship
	icon = 'aquila/icons/overmap/ships/syndie-battleship.dmi'
	icon_state = "atlas"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/syndicate/ai/fistofsol
	icon = 'aquila/icons/overmap/ships/syndie-flagship.dmi'
	icon_state = "matecznik"
	overmap_native_sprite = TRUE
	damage_states = FALSE

// --- Piraci ---

/obj/structure/overmap/spacepirate/ai
	icon = 'aquila/icons/overmap/ships/pirate-frigate.dmi'
	icon_state = "chimera"
	overmap_native_sprite = TRUE
	damage_states = FALSE

/obj/structure/overmap/spacepirate/ai/boarding
	icon = 'aquila/icons/overmap/ships/pirate-dropship.dmi'
	icon_state = "kleszcz"

/obj/structure/overmap/spacepirate/ai/nt_missile
	icon = 'aquila/icons/overmap/ships/pirate-destroyer.dmi'
	icon_state = "szabrownik"

/obj/structure/overmap/spacepirate/ai/syndie_gunboat
	icon = 'aquila/icons/overmap/ships/pirate-destroyer.dmi'
	icon_state = "szabrownik"

/obj/structure/overmap/spacepirate/ai/dreadnought
	icon = 'aquila/icons/overmap/ships/pirate-battleship.dmi'
	icon_state = "rzeznik"
