/// AQUILA - test regresji zamarzniętych lotniskowców (aquila/code/modules/overmap/overmap_overlap.dm):
/// okręt 4x4 z gęstym obiektem w środku obrysu musi móc się ruszyć, a obiekt tuż przed obrysem dalej go blokuje.
/datum/unit_test/aquila_overmap_overlap

/datum/unit_test/aquila_overmap_overlap/Run()
	var/obj/structure/overmap/small_craft/combat/light/big = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/obj/structure/overmap/small_craft/combat/light/blocker = allocate(/obj/structure/overmap/small_craft/combat/light)
	big.bound_width = 128 // obrys lotniskowca Syndykatu
	big.bound_height = 128
	var/z = run_loc_floor_bottom_left.z
	big.forceMove(locate(100, 60, z))
	// Wrak w środku obrysu: przed poprawką Move() odmawiał w każdą stronę
	blocker.forceMove(locate(101, 61, z))
	if(!big.Move(locate(101, 60, z), EAST))
		return Fail("okręt 4x4 z obiektem w środku obrysu nie może ruszyć na wschód")
	if(!big.Move(locate(101, 59, z), SOUTH))
		return Fail("okręt 4x4 z obiektem w środku obrysu nie może ruszyć na południe")
	// Obiekt przed obrysem, nienachodzący na okręt: zwykłe zderzenie
	big.forceMove(locate(100, 60, z))
	blocker.forceMove(locate(105, 61, z))
	if(big.Move(locate(101, 60, z), EAST))
		return Fail("obiekt przed obrysem przestał blokować okręt")
