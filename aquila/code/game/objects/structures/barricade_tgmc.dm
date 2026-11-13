// Barykady kierunkowe (port z CM w nsv13/code/game/objects/structures/barricade.dm) uzupełnione o zachowanie z TGMC
// (tgstation/TerraGov-Marine-Corps, code/game/objects/structures/barricades/): część pocisków przelatuje nad barykadą,
// drut kolczasty uniemożliwia przeskok, mocno uszkodzoną barykadę wzmacnia się arkuszami, dochodzą worki z piaskiem
// i składana barykada metalowa. Wytrzymałość i pancerz jak w TGMC. Bez systemu pocisków TGMC (coverage, celność),
// umiejętności, ulepszeń płytami i łączenia barykad łomem.
// Sprite składanej metalowej barykady z TGMC (icons/obj/structures/barricades/metal.dmi), licencja CC BY-NC-SA 3.0.

/// Ile arkuszy trzeba, by wzmocnić podstawę barykady poniżej 30% wytrzymałości (BARRICADE_REPAIR_STACK_AMOUNT w TGMC)
#define AQ_BARRICADE_REPAIR_STACK 2
/// Poniżej tej części wytrzymałości spawarka nie wystarcza
#define AQ_BARRICADE_REPAIR_THRESHOLD 0.3

/obj/structure/peacekeeper_barricade
	armor = list("melee" = 0, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 40, "stamina" = 0, "bleed" = 0)
	/// Szansa (%), że pocisk lecący od frontu przeleci nad barykadą
	var/proj_pass_rate = 20

/obj/structure/peacekeeper_barricade/metal
	max_integrity = 250
	barricade_hitsound = 'sound/effects/clang.ogg'

/obj/structure/peacekeeper_barricade/metal/plasteel
	max_integrity = 550
	proj_pass_rate = 10
	armor = list("melee" = 0, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 50, "stamina" = 0, "bleed" = 0)
	barricade_hitsound = 'sound/effects/clang.ogg' // core ustawia tu osobno nieistniejący "sound/effects/metalhit.ogg"

/obj/item/projectile
	/// REF barykady kierunkowej -> czy ten pocisk nad nią przelatuje (jedno losowanie na barykadę, choć CanPass woła się kilka razy)
	var/list/aq_barricade_rolls

// Pocisk od frontu przelatuje z szansą proj_pass_rate, a strzelec stojący tuż przy barykadzie strzela nad nią
// (jak /obj/structure/barricade w code/game/machinery/deployable.dm). Strzały zza barykady przepuszcza już on_exit.
/obj/structure/peacekeeper_barricade/CanAllowThrough(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item/projectile) && !closed && (get_dir(loc, target) & dir))
		var/obj/item/projectile/proj = mover
		if(proj.firer && get_dist(proj.firer, src) <= 1)
			return TRUE
		var/key = REF(src)
		LAZYINITLIST(proj.aq_barricade_rolls)
		if(isnull(proj.aq_barricade_rolls[key]))
			proj.aq_barricade_rolls[key] = prob(proj_pass_rate)
		return proj.aq_barricade_rolls[key]
	return ..()

// Drut kolczasty zatrzymuje też abordażystów AI: zwykle planują trasę przez barykady, bo się po nich wspinają
/obj/structure/peacekeeper_barricade/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	. = ..()
	// to_dir to kierunek (liczba), więc maska bitowa, nie `in` jak w core
	if(. && is_wired && density && !closed && isknpc(caller) && (dir & to_dir))
		return FALSE

/obj/structure/peacekeeper_barricade/metal/attackby(obj/item/I, mob/user, params)
	if(stack_type && istype(I, stack_type) && obj_integrity < max_integrity * AQ_BARRICADE_REPAIR_THRESHOLD)
		repair_base(I, user)
		return
	if(I.tool_behaviour == TOOL_WELDER && stack_type && obj_integrity <= max_integrity * AQ_BARRICADE_REPAIR_THRESHOLD)
		var/obj/item/stack/needed = stack_type
		balloon_alert(user, "zbyt uszkodzona, wzmocnij ją: [initial(needed.name)] ×[AQ_BARRICADE_REPAIR_STACK]")
		return
	. = ..()
	// drut kolczasty na szczycie: przez barykadę nie da się przeskoczyć
	if(!QDELETED(src))
		climbable = !is_wired

/// Wzmacnia mocno uszkodzoną barykadę arkuszami do 30% wytrzymałości, dalej naprawia spawarka (repair_base z TGMC)
/obj/structure/peacekeeper_barricade/proc/repair_base(obj/item/stack/sheets, mob/user)
	if(sheets.get_amount() < AQ_BARRICADE_REPAIR_STACK)
		balloon_alert(user, "potrzeba [AQ_BARRICADE_REPAIR_STACK] szt.!")
		return FALSE
	balloon_alert(user, "wzmacniasz podstawę...")
	if(!do_after(user, 2 SECONDS, TRUE, src) || obj_integrity >= max_integrity * AQ_BARRICADE_REPAIR_THRESHOLD)
		return FALSE
	if(!sheets.use(AQ_BARRICADE_REPAIR_STACK))
		return FALSE
	obj_integrity += max_integrity * AQ_BARRICADE_REPAIR_THRESHOLD
	update_health()
	balloon_alert(user, "podstawa wzmocniona")
	return TRUE

/// Worki z piaskiem ułożone w murek na krawędzi pola. Bez paneli i śrub: rozbiera się je łopatą, naprawia kolejnymi workami.
/obj/structure/peacekeeper_barricade/metal/sandbags
	name = "barykada z worków z piaskiem"
	desc = "Worki z piaskiem ułożone w niski murek. Zaskakująco wytrzymałe, choć ich ułożenie to ciężka praca. Uszkodzenia uzupełnisz kolejnymi workami, a rozbierzesz je łopatą."
	icon_state = "sandbag_0"
	max_integrity = 325
	stack_type = /obj/item/stack/sheet/mineral/sandbags
	stack_amount = 2
	destroyed_stack_amount = null
	barricade_hitsound = 'sound/weapons/genhit.ogg'
	barricade_type = "sandbag"
	build_state = 3 // poza krokami rozbiórki śrubokrętem, kluczem i łomem

/obj/structure/peacekeeper_barricade/metal/sandbags/attackby(obj/item/I, mob/user, params)
	if(istype(I, stack_type))
		repair_with_sandbag(I, user)
		return
	if(I.tool_behaviour == TOOL_WELDER)
		balloon_alert(user, "worków nie zespawasz!")
		return
	if(I.tool_behaviour == TOOL_SHOVEL)
		balloon_alert(user, "rozkopujesz worki...")
		if(!I.use_tool(src, user, 3 SECONDS, volume = 25))
			return
		destroy_structure(TRUE)
		return
	return ..()

/// Jeden worek uzupełnia ćwierć wytrzymałości (stack_repair z TGMC)
/obj/structure/peacekeeper_barricade/metal/sandbags/proc/repair_with_sandbag(obj/item/stack/bags, mob/user)
	if(obj_integrity >= max_integrity)
		balloon_alert(user, "nie wymaga naprawy!")
		return FALSE
	balloon_alert(user, "uzupełniasz worki...")
	if(!do_after(user, 1.5 SECONDS, TRUE, src) || obj_integrity >= max_integrity)
		return FALSE
	if(!bags.use(1))
		return FALSE
	obj_integrity += max_integrity * 0.25
	update_health()
	balloon_alert(user, "worki uzupełnione")
	return TRUE

/// Składana barykada z metalu: zachowanie jak barykada z plastali (składanie ręką), słabsza i z metalu.
/// Stoi po zbudowaniu (jak w TGMC), a nie leży złożona jak barykada z plastali.
/obj/structure/peacekeeper_barricade/metal/plasteel/folding_metal
	name = "składana metalowa barykada"
	desc = "Składana barykada z metalu, nieco mocniejsza od zwykłej metalowej. Napraw ją spawarką. Można ją złożyć, by zrobić przejście."
	icon = 'aquila/icons/obj/barricades_tgmc.dmi'
	icon_state = "folding_metal_0"
	max_integrity = 350
	proj_pass_rate = 20
	armor = list("melee" = 0, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 40, "stamina" = 0, "bleed" = 0)
	stack_type = /obj/item/stack/sheet/iron
	stack_amount = 6
	destroyed_stack_amount = 3
	barricade_type = "folding_metal"
	closed = FALSE
	density = TRUE

#undef AQ_BARRICADE_REPAIR_STACK
#undef AQ_BARRICADE_REPAIR_THRESHOLD
