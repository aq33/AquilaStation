// Tłumacz kieszonkowy obcokrajowca (foreigner.dm). Działa w ręce, w kieszeni i na pasku, w plecaku nic nie słyszy.
// Polak z tłumaczem rozumie Angielski. Obcokrajowcowi tłumacz przekłada mowę w obie strony przez API.
/obj/item/aquila_translator
	name = "tłumacz kieszonkowy"
	desc = "Mały tłumacz z mikrofonem i głośniczkiem. Przekłada mowę między angielskim i polskim, dopóki masz go w ręce, w kieszeni albo na pasku. Z plecaka nic nie słyszy."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-blue"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT

/obj/item/aquila_translator/equipped(mob/user, slot)
	. = ..()
	user.aq_translator_on(REF(src))

/obj/item/aquila_translator/dropped(mob/user)
	. = ..()
	user.aq_translator_off(REF(src))

/// Włącza tłumacza z danego źródła (tłumacz kieszonkowy, słuchawki z czipem): rozumienie Angielskiego i przechwytywanie mowy
/mob/proc/aq_translator_on(source)
	ADD_TRAIT(src, TRAIT_AQ_TRANSLATOR, source)
	grant_language(/datum/language/english, TRUE, FALSE, LANGUAGE_TRANSLATOR)
	if(isliving(src))
		var/mob/living/living_src = src
		living_src.aq_update_translator_hook()

/mob/proc/aq_translator_off(source)
	REMOVE_TRAIT(src, TRAIT_AQ_TRANSLATOR, source)
	if(!HAS_TRAIT(src, TRAIT_AQ_TRANSLATOR))
		remove_language(/datum/language/english, TRUE, FALSE, LANGUAGE_TRANSLATOR)
	if(isliving(src))
		var/mob/living/living_src = src
		living_src.aq_update_translator_hook()
