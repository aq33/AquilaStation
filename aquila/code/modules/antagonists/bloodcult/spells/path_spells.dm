
/datum/action/cooldown/spell/pointed/conjure/path_entrance
	name = "Wejście na Ścieżkę"
	desc = "Umieść wejście na skrót przez zasłonę między tym światem a tamtym."

	school = SCHOOL_CONJURATION
	cooldown_time = 60 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	cast_range = 1
	summon_type = list(/obj/effect/new_rune)


	var/chosen_path = ""

/datum/action/cooldown/spell/pointed/conjure/path_entrance/PreActivate(atom/target)
	var/turf/T = get_turf(target)
	var/obj/effect/new_rune/rune = locate() in T
	if (rune)
		to_chat(owner, span_warning("Nie możesz rysować na już istniejącej runie.") )
		return FALSE
	if(isspaceturf(T))
		to_chat(owner, span_warning("Najpierw stań na twardym podłożu!") )
		return FALSE
	// AQUILA - w drafcie zwracało TRUE bez ..(), więc zaklęcie nigdy się nie rzucało
	return ..()

/datum/action/cooldown/spell/pointed/conjure/path_entrance/post_summon(obj/effect/new_rune/R, atom/cast_on)
	var/turf/T = R.loc
	log_admin("BLOODCULT: [key_name(owner)] has created a new rune at [T.loc] (@[T.x], [T.y], [T.z]).")
	message_admins("BLOODCULT: [key_name(owner)] has created a new rune at [T.loc] [ADMIN_JMP(T)].")
	write_full_rune(R.loc, /datum/rune_spell/portalentrance)
	R.one_pulse()
	INVOKE_ASYNC(R, TYPE_PROC_REF(/obj/effect/new_rune, trigger), owner)

	var/datum/antagonist/cult/C = IS_CULTIST(owner)
	C?.gain_devotion(30, DEVOTION_TIER_1, "new_path_entrance", R)

/datum/action/cooldown/spell/pointed/conjure/path_exit
	name = "Wyjście ze Ścieżki"
	desc = "Umieść wyjście ze skrótu przez zasłonę między tym światem a tamtym."

	school = SCHOOL_CONJURATION
	cooldown_time = 60 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	cast_range = 3
	summon_type = list(/obj/effect/new_rune)

	var/chosen_path = ""

/datum/action/cooldown/spell/pointed/conjure/path_exit/PreActivate(atom/target)
	var/turf/T = get_turf(target)
	var/obj/effect/new_rune/rune = locate() in T
	if (rune)
		to_chat(owner, span_warning("Nie możesz rysować na już istniejącej runie.") )
		return FALSE
	if(isspaceturf(T))
		to_chat(owner, span_warning("Najpierw stań na twardym podłożu!") )
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/conjure/path_exit/post_summon(obj/effect/new_rune/R, atom/cast_on)
	. = ..()
	var/turf/T = R.loc
	log_admin("BLOODCULT: [key_name(owner)] has created a new rune at [T.loc] (@[T.x], [T.y], [T.z]).")
	message_admins("BLOODCULT: [key_name(owner)] has created a new rune at [T.loc] [ADMIN_JMP(T)].")
	write_full_rune(R.loc, /datum/rune_spell/portalexit)
	R.one_pulse()
	INVOKE_ASYNC(R, TYPE_PROC_REF(/obj/effect/new_rune, trigger), owner)

	var/datum/antagonist/cult/C = IS_CULTIST(owner)
	C?.gain_devotion(30, DEVOTION_TIER_1, "new_path_exit", R)
