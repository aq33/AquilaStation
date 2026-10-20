/*
 * Wskaźnik combat mode dla mobów, których HUD nie ma przełącznika walki (simple animale, antagi-zwierzęta itp.).
 * Domyślnie ma go każdy żywy mob gracza: combat mode decyduje co najmniej o przepychaniu i zamianie miejsc,
 * a u wielu mobów o tym, czy atakują, czy pomagają. Po wejściu gracza w HUD pojawi się przełącznik walki albo,
 * przy preferencji starych intencji, wybór czterech intencji (podmianą zajmuje się refresh_intent_selector()
 * z legacy_intents.dm). Wyłącz go (FALSE) tylko u mobów, które w ogóle nie dotykają świata (np. revenant).
 */

/mob/living
	/// Czy dołożyć do HUD przełącznik combat mode, jeśli HUD tego moba go nie ma
	var/combat_mode_indicator = TRUE

// Silikony mają własny przełącznik w HUD
/mob/living/silicon
	combat_mode_indicator = FALSE

// Nie dotykają świata zwykłym kliknięciem, więc combat mode nic u nich nie zmienia
/mob/living/simple_animal/revenant
	combat_mode_indicator = FALSE

/mob/living/simple_animal/eminence
	combat_mode_indicator = FALSE

/mob/living/simple_animal/pulse_demon
	combat_mode_indicator = FALSE

/mob/living/create_mob_hud()
	. = ..()
	if(combat_mode_indicator && hud_used && !hud_used.action_intent)
		hud_used.add_combat_mode_indicator()

/datum/hud/proc/add_combat_mode_indicator()
	action_intent = create_combat_mode_selector()
	static_inventory += action_intent
	if(hud_shown)
		mymob.client?.screen += action_intent
	refresh_intent_selector()
