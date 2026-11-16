// AQUILA - zanurzenie w wodzie: port elementu immerse z Shiptesta (code/datums/elements/immerse.dm, AGPLv3, z tg).
// Mob albo przedmiot na polu z tym elementem dostaje maskę alfa z falującą wodą, więc wygląda, jakby stał w wodzie.
// Uproszczenia względem Shiptesta: tylko moby i przedmioty (bez struktur), tylko sprite'y 32 × 32 (większe zostają bez
// maski), lot i rzut sprawdzane przy wejściu na pole, bez przeliczania przy zmianie przesunięcia sprite'a. Maska ma
// RESET_TRANSFORM, więc leżący mob nie obraca wody razem z sobą. Wodę przy brzegu obsługuje osobno watery_tile.

/datum/element/immerse
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	/// Stan maski z aquila/icons/planets/water/immerse.dmi
	var/mask_icon = "immerse"
	/// Przezroczystość wody na masce
	var/alpha = 180
	/// Ruchomy -> obiekt z maską (render_target filtra)
	var/list/masks = list()
	/// Pola z tym elementem (pole -> TRUE): krok między nimi nie zdejmuje maski
	var/list/attached_turfs = list()

/datum/element/immerse/Attach(turf/target, mask_icon = "immerse", alpha = 180)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	src.mask_icon = mask_icon
	src.alpha = alpha
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	attached_turfs[target] = TRUE
	for(var/atom/movable/movable as anything in target)
		on_entered(target, movable)

/datum/element/immerse/Detach(turf/source)
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	attached_turfs -= source
	for(var/atom/movable/movable as anything in source)
		unimmerse(movable)
	return ..()

/datum/element/immerse/Destroy(force)
	for(var/atom/movable/movable as anything in masks)
		unimmerse(movable)
	masks = null
	attached_turfs = null
	return ..()

/// Czy ruchomy w ogóle może się zanurzyć
/datum/element/immerse/proc/can_immerse(atom/movable/movable)
	if(QDELETED(movable) || movable.invisibility >= INVISIBILITY_OBSERVER)
		return FALSE
	if(!isliving(movable) && !isitem(movable))
		return FALSE
	if(movable.movement_type & (FLYING | FLOATING) || movable.throwing)
		return FALSE
	if(isliving(movable))
		var/mob/living/living_mob = movable
		if(living_mob.buckled)
			return FALSE
	if(movable.bound_width > world.icon_size || movable.bound_height > world.icon_size)
		return FALSE
	// Pomost nad wodą: idzie się po nim suchą nogą (w tg TRAIT_IMMERSE_STOPPED)
	if(locate(/obj/structure/lattice/catwalk) in movable.loc)
		return FALSE
	return TRUE

/datum/element/immerse/proc/on_entered(turf/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(masks[arrived] || !can_immerse(arrived))
		return
	var/atom/movable/immerse_mask/mask = new
	mask.icon = 'aquila/icons/planets/water/immerse.dmi'
	mask.icon_state = mask_icon
	mask.alpha = alpha
	mask.render_target = "*immerse_[REF(arrived)]"
	arrived.vis_contents += mask
	arrived.add_filter("immerse_mask", 100, alpha_mask_filter(render_source = mask.render_target, flags = MASK_INVERSE))
	masks[arrived] = mask
	RegisterSignal(arrived, COMSIG_PARENT_QDELETING, PROC_REF(on_movable_qdel))
	ADD_TRAIT(arrived, TRAIT_IMMERSED, ELEMENT_TRAIT(src))

/datum/element/immerse/proc/on_exited(turf/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(!masks[gone])
		return
	// Krok na sąsiednie pole z tą samą wodą: zostaje zanurzony
	if(attached_turfs[gone.loc] && can_immerse(gone))
		return
	unimmerse(gone)

/datum/element/immerse/proc/on_movable_qdel(atom/movable/source)
	SIGNAL_HANDLER
	unimmerse(source)

/datum/element/immerse/proc/unimmerse(atom/movable/movable)
	var/atom/movable/immerse_mask/mask = masks[movable]
	if(!mask)
		return
	masks -= movable
	UnregisterSignal(movable, COMSIG_PARENT_QDELETING)
	movable.remove_filter("immerse_mask")
	movable.vis_contents -= mask
	qdel(mask)
	REMOVE_TRAIT(movable, TRAIT_IMMERSED, ELEMENT_TRAIT(src))

/// Obiekt z maską wody: tylko źródło renderowania filtra, sam niewidoczny
/atom/movable/immerse_mask
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA | KEEP_APART
	vis_flags = VIS_HIDE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
