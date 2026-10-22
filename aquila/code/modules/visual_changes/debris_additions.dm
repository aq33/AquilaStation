// Port Monkestation (debris_additions.dm): które ściany i struktury sypią którymi odłamkami.
// Zamiast elementu dopinanego w Initialize nadpisujemy bullet_act tylko tych typów (zero kosztu przy ładowaniu mapy).
// Mapowanie typów Monke -> nasze:
//   table/woodentable, fancywoodentable -> table/wood (fancy dziedziczy)
//   machinery/power/shuttle_engine -> structure/shuttle/engine
//   turf/closed/ice, ice_rock -> turf/closed/wall/ice, wall/mineral/snow
//   turf/closed/wall/resin -> structure/alien/resin/wall (u nas żywica to struktura)
//   turf/closed/wall/wood -> turf/closed/wall/mineral/wood

/obj/structure/barricade/wooden/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_WOOD, -10, 5)

/obj/structure/closet/cabinet/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_WOOD, -10, 5)

/obj/structure/closet/crate/large/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_WOOD, -10, 5)

/obj/structure/flora/tree/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_WOOD, -10, 5)

/obj/structure/flora/rock/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_ROCK, -10, 5, 1)

/obj/structure/girder/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_SPARKS, -15, 8, 1)

/obj/structure/mineral_door/wood/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_WOOD, -10, 5)

/obj/structure/table/wood/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_WOOD, -10, 5)

/obj/structure/window/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_GLASS, -10, 5)

/obj/structure/shuttle/engine/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_SPARKS, -15, 8, 1)

/obj/structure/alien/resin/wall/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, null, -15, 8, 0.7)

/turf/closed/mineral/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	spawn_impact_debris(src, P, DEBRIS_ROCK, -10, 5, 1)

/// Odłamki dla tej ściany: stan ikony, prędkość, ilość, skala (nadpisywane w podtypach)
/turf/closed/wall/proc/impact_debris_args()
	return list(DEBRIS_SPARKS, -15, 8, 1)

/turf/closed/wall/mineral/wood/impact_debris_args()
	return list(DEBRIS_WOOD, -10, 5, 0.7)

/turf/closed/wall/ice/impact_debris_args()
	return list(DEBRIS_SNOW, -10, 5, 1)

/turf/closed/wall/mineral/snow/impact_debris_args()
	return list(DEBRIS_SNOW, -10, 5, 1)

/turf/closed/wall/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	if(!can_spawn_impact_particles()) // lista argumentów tylko gdy faktycznie coś pokażemy
		return
	var/list/debris_args = impact_debris_args()
	spawn_impact_debris(src, P, debris_args[1], debris_args[2], debris_args[3], debris_args[4])
