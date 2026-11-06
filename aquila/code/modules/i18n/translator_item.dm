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
	ADD_TRAIT(user, TRAIT_AQ_TRANSLATOR, REF(src))
	user.grant_language(/datum/language/english, TRUE, FALSE, LANGUAGE_TRANSLATOR)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.aq_update_translator_hook()

/obj/item/aquila_translator/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_AQ_TRANSLATOR, REF(src))
	if(!HAS_TRAIT(user, TRAIT_AQ_TRANSLATOR))
		user.remove_language(/datum/language/english, TRUE, FALSE, LANGUAGE_TRANSLATOR)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.aq_update_translator_hook()
