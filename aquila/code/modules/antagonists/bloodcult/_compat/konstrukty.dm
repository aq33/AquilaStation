// AQUILA - kult „Cult 4”: zgodność obszaru konstruktów (kamień dusz z draftu Monke #3867 na naszym soulstone.dm).

// Zmienna /obj/item/soulstone/var/perfect (klejnot dusz) jest w _compat/przedmioty.dm.

/// Draft: kamieniem dusz można złapać ducha, jeśli się zgodzi zostać cieniem
/obj/item/soulstone/pre_attack(atom/A, mob/living/user, params)
	if(!isobserver(A))
		return ..()
	if(!iscultist(user) && !iswizard(user) && !usability)
		return ..()
	if(spent || length(contents))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(offer_shade_to_ghost), A, user)
	return FALSE

/obj/item/soulstone/proc/offer_shade_to_ghost(mob/dead/observer/observer, mob/living/user)
	var/prompt = tgui_alert(observer, "Czy chcesz zostać cieniem?", "[name]", list("Tak", "Nie"))
	if(prompt != "Tak")
		to_chat(user, span_notice("Duch nie chce zostać cieniem."))
		return
	if(QDELETED(src) || QDELETED(observer) || !observer.client || length(contents))
		return
	var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade(src)
	S.status_flags |= GODMODE //So they won't die inside the stone somehow
	S.mobility_flags = NONE //Can't move out of the soul stone
	S.name = "Cień [observer.name]"
	S.real_name = "Cień [observer.name]"
	S.key = observer.key
	if(user)
		S.faction |= "[REF(user)]"
		S.copy_languages(user, LANGUAGE_MASTER)
		S.update_atom_languages()
		if(iscultist(user))
			S.mind?.add_antag_datum(/datum/antagonist/cult)
	S.cancel_camera()
	name = "kamień dusz: Cień [observer.name]"
	icon_state = purified ? "purified_soulstone2" : "soulstone2"
	update_icon()
	if(user && iscultist(user))
		to_chat(S, "Twoja dusza została schwytana! Wiąże cię teraz wola kultu. Pomóż mu osiągnąć cele za wszelką cenę.")
	else if(user)
		to_chat(S, "Twoja dusza została schwytana! Wiąże cię teraz wola [user.real_name]. Pomóż mu osiągnąć cele za wszelką cenę.")
	to_chat(user, "<span class='info'><b>Schwytano!</b>:</span> Duch wszedł do [src] jako cień.")

/// Cień ma teraz sprite z vg, a oczyszczony cień („ghost1”) jest tylko w starym pliku ikon
/obj/item/soulstone/Exited(atom/movable/gone, direction)
	. = ..()
	var/mob/living/simple_animal/shade/S = gone
	if(istype(S) && purified)
		S.icon = 'icons/mob/mob.dmi'

// ---------------------------------------------------------------------------
// Devotion za przywołaną podłogę/ścianę kultu (draft: spells/spell_types/conjure/cult_turfs.dm, post_summon).
// Nasz conjure nie woła post_summon dla turfów, więc nadpisujemy cast() z ..() zamiast hooka w core.
/obj/effect/proc_holder/spell/aoe_turf/conjure/floor/cast(list/targets, mob/user = usr)
	var/can_summon = bloodcult_conjure_has_space(targets)
	. = ..()
	if(can_summon)
		var/datum/antagonist/cult/cultist = user?.mind?.has_antag_datum(/datum/antagonist/cult)
		cultist?.gain_devotion(0, DEVOTION_TIER_0, "convert_floor")

/obj/effect/proc_holder/spell/aoe_turf/conjure/wall/cast(list/targets, mob/user = usr)
	var/can_summon = bloodcult_conjure_has_space(targets) && (type == /obj/effect/proc_holder/spell/aoe_turf/conjure/wall)
	. = ..()
	if(can_summon)
		var/datum/antagonist/cult/cultist = user?.mind?.has_antag_datum(/datum/antagonist/cult)
		cultist?.gain_devotion(0, DEVOTION_TIER_0, "convert_wall")

/// Czy conjure ma choć jeden niezajęty turf (tak jak filtruje go /conjure/cast).
/obj/effect/proc_holder/spell/aoe_turf/conjure/proc/bloodcult_conjure_has_space(list/targets)
	for(var/turf/T in targets)
		if(!T.density || summon_ignore_density)
			return TRUE
	return FALSE
