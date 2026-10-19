/// Losowe gizmo (tg: /obj/effect/spawner/random/gizmo)
/obj/effect/spawner/lootdrop/gizmo
	name = "gizmo spawner"
	icon = 'icons/effects/random_spawners_gizmo.dmi'
	icon_state = "gizmo"
	loot = list(
		/obj/machinery/gizmo = 6,
		/obj/machinery/gizmo/toggle = 4,
		/obj/machinery/gizmo/voice = 2,
		/obj/machinery/gizmo/beyblade = 1,
	)

/obj/effect/spawner/lootdrop/gizmo/Initialize(mapload)
	// AQUILA: zwykły lootdrop zawsze stawia łup na turfie. W skrzyni z cargo gizmo ma trafić do środka skrzyni.
	if(loc && !isturf(loc) && length(loot))
		var/path = pickweight(loot)
		if(path)
			new path(loc)
		loot = null
	return ..()

// AQUILA: tg dorzuca gizmo do losowych struktur w maintenance (/obj/effect/spawner/random/structure/crate, waga 20 na ~1030, czyli około 2%).
// U nas najbliższy odpowiednik to losowa skrzynia z łupem w maintenance.
/obj/effect/spawner/lootdrop/crate_spawner/Initialize(mapload)
	if(islist(loot) && !(/obj/effect/spawner/lootdrop/gizmo in loot))
		loot[/obj/effect/spawner/lootdrop/gizmo] = 2
	return ..()
