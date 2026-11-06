// AQUILA - krwawe ślady bosych stóp. Rodzaj śladu (stopy, łapy, pazury) bierze się z nóg (aq33/AquilaStation#334).
// Bez tego ślady zostawiały tylko buty, a każde buty mają ślad stóp, więc ślady łap małpy nigdy się nie pojawiały.
// Działa jak bloody_shoes w butach (code/game/objects/effects/decals/cleanable.dm, human_movement.dm), tylko na bosych stopach.

/mob/living/carbon/human
	/// Ile krwi danego rodzaju jest na bosych stopach: blood_state = ilość
	var/list/aquila_feet_blood
	/// Rodzaj krwi, w którą bose stopy weszły ostatnio
	var/aquila_feet_blood_state
	/// DNA krwi na bosych stopach, przechodzi na ślady
	var/list/aquila_feet_blood_dna

/// Bose stopy zbierają krew z kałuży
/obj/effect/decal/cleanable/on_entered(datum/source, atom/movable/O)
	. = ..()
	if(!ishuman(O) || !blood_state || !bloodiness)
		return
	var/mob/living/carbon/human/H = O
	if(H.shoes || HAS_TRAIT(H, TRAIT_LIGHT_STEP) || !H.get_footprint_sprite())
		return
	var/change = add_bloodiness(-BLOOD_GAIN_PER_STEP) // zawsze niedodatnia
	LAZYINITLIST(H.aquila_feet_blood)
	H.aquila_feet_blood[blood_state] = min(MAX_SHOE_BLOODINESS, H.aquila_feet_blood[blood_state] - change)
	H.aquila_feet_blood_state = blood_state
	var/list/blood_dna = return_blood_DNA()
	for(var/dna in blood_dna)
		LAZYSET(H.aquila_feet_blood_dna, dna, blood_dna[dna])
	update_icon()

/// Bose zakrwawione stopy zostawiają ślad na każdym kroku, tak jak zakrwawione buty
/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(shoes || loc != NewLoc || !(mobility_flags & MOBILITY_STAND) || !has_gravity(loc))
		return
	aquila_leave_bare_footprint()

/mob/living/carbon/human/proc/aquila_leave_bare_footprint()
	var/state = aquila_feet_blood_state
	if(!state || !LAZYACCESS(aquila_feet_blood, state))
		return
	var/footprint_sprite = get_footprint_sprite()
	if(!footprint_sprite)
		return
	var/turf/T = get_turf(src)
	for(var/obj/effect/decal/cleanable/blood/footprints/old_print in T)
		if(old_print.blood_state == state && old_print.footprint_sprite == footprint_sprite)
			return
	aquila_feet_blood[state] = max(0, aquila_feet_blood[state] - BLOOD_LOSS_PER_STEP)
	if(aquila_feet_blood[state] <= BLOOD_LOSS_IN_SPREAD)
		return
	var/obj/effect/decal/cleanable/blood/footprints/print = new(T, footprint_sprite)
	print.blood_state = state
	print.entered_dirs |= dir
	print.bloodiness = aquila_feet_blood[state] - BLOOD_LOSS_IN_SPREAD
	if(aquila_feet_blood_dna)
		print.add_blood_DNA(aquila_feet_blood_dna)
	print.update_icon()

/// Wejście bosą stopą w ślad tego samego rodzaju dopisuje kierunek, jak w butach
/obj/effect/decal/cleanable/blood/footprints/on_entered(datum/source, atom/movable/O)
	. = ..()
	aquila_bare_step(O, TRUE)

/obj/effect/decal/cleanable/blood/footprints/on_uncrossed(datum/source, atom/movable/O)
	. = ..()
	aquila_bare_step(O, FALSE)

/obj/effect/decal/cleanable/blood/footprints/proc/aquila_bare_step(atom/movable/O, entering)
	if(!ishuman(O))
		return
	var/mob/living/carbon/human/H = O
	if(H.shoes || !LAZYACCESS(H.aquila_feet_blood, blood_state) || H.get_footprint_sprite() != footprint_sprite)
		return
	H.aquila_feet_blood[blood_state] = max(H.aquila_feet_blood[blood_state] - BLOOD_LOSS_PER_STEP, 0)
	if(entering)
		if(entered_dirs & H.dir)
			return
		entered_dirs |= H.dir
	else
		if(exited_dirs & H.dir)
			return
		exited_dirs |= H.dir
	update_icon()

/// Mycie (prysznic, mydło) zmywa też krew z bosych stóp
/mob/living/carbon/human/clean_blood(datum/source, strength)
	. = ..()
	if(strength < CLEAN_STRENGTH_BLOOD)
		return
	aquila_feet_blood = null
	aquila_feet_blood_state = null
	aquila_feet_blood_dna = null
