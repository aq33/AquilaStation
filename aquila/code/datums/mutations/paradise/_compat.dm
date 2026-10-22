// AQUILA - port z ParadiseSS13: brakujące traity i zaczepy dla mutacji Paradise

/// Psy-Resist: umysł zamknięty na telepatię, czytanie myśli i zdalne podglądanie
#ifndef TRAIT_PSY_RESIST
#define TRAIT_PSY_RESIST "psy_resist"
#endif

/// Czy umysł moba jest zamknięty na moce psychiczne (Psy-Resist)
/proc/paradise_psy_resistant(mob/living/target)
	return isliving(target) && HAS_TRAIT(target, TRAIT_PSY_RESIST)

/// Usuwa z listy celów moby z Psy-Resist. Zwraca FALSE, gdy nie został żaden cel.
/proc/paradise_filter_psy_resist(list/targets, mob/user)
	for(var/mob/living/target in targets.Copy())
		if(!paradise_psy_resistant(target))
			continue
		targets -= target
		to_chat(user, "<span class='warning'>Nie możesz w ogóle dosięgnąć umysłu [target]!</span>")
	return length(targets) > 0

// Psy-Resist blokuje naszą telepatię (mutacja Telepathy i pochodne) oraz Mind Reader.
// Wpinamy się w perform(), bo ani te typy, ani ich podtypy go nie nadpisują.
/obj/effect/proc_holder/spell/targeted/telepathy/perform(list/targets, recharge = TRUE, mob/user = usr)
	if(!paradise_filter_psy_resist(targets, user))
		return
	return ..()

/obj/effect/proc_holder/spell/targeted/mindread/perform(list/targets, recharge = TRUE, mob/user = usr)
	if(!paradise_filter_psy_resist(targets, user))
		return
	return ..()
