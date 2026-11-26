/// AQUILA - znacznik małej jednostki na radarze (sensor_console.dm, scope_craft_class): rozpoznany myśliwiec dostaje
/// znacznik myśliwca, nierozpoznany tylko znacznik małej jednostki (radar nie zdradza klasy), a okręt żadnego.
/datum/unit_test/aquila_scope_craft_marker

/datum/unit_test/aquila_scope_craft_marker/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/structure/overmap/small_craft/fighter = allocate(/obj/structure/overmap/small_craft/combat/light)
	if(fighter.scope_craft_class(TRUE) != "fighter")
		return Fail("Rozpoznany myśliwiec nie ma znacznika myśliwca ([fighter.scope_craft_class(TRUE)])")
	if(fighter.scope_craft_class(FALSE) != "small")
		return Fail("Nierozpoznany myśliwiec zdradza klasę albo nie ma znacznika małej jednostki ([fighter.scope_craft_class(FALSE)])")
	if(!isnull(ship.scope_craft_class(TRUE)))
		return Fail("Okręt dostał znacznik małej jednostki ([ship.scope_craft_class(TRUE)])")
