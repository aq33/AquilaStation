// Tłumacz kieszonkowy obcokrajowca (foreigner.dm). Działa w ręce, w kieszeni i na pasku, w plecaku nic nie słyszy.
// Polak z tłumaczem rozumie Angielski. Obcokrajowcowi tłumacz przekłada mowę w obie strony przez API.
// EMP wyłącza go na minutę, a silny EMP może go spalić na stałe (dotyczy też czipu w słuchawkach, translator_chip.dm).

#define AQ_TRANSLATOR_REBOOT_TIME (60 SECONDS)
#define AQ_TRANSLATOR_BURN_CHANCE 25

/obj/item/aquila_translator
	name = "tłumacz kieszonkowy"
	desc = "Mały tłumacz z mikrofonem i głośniczkiem. Przekłada mowę między angielskim i polskim, dopóki masz go w ręce, w kieszeni albo na pasku. Z plecaka nic nie słyszy."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-blue"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	/// Spalony przez EMP: już nigdy nie tłumaczy
	var/burnt = FALSE
	/// Wyłączony na chwilę po EMP
	var/rebooting = FALSE
	/// Ikona po spaleniu (null = przyciemniona zwykła)
	var/burnt_icon_state

/obj/item/aquila_translator/equipped(mob/user, slot)
	. = ..()
	aq_refresh()

/obj/item/aquila_translator/dropped(mob/user)
	. = ..()
	aq_dropped(user)

/// Tłumacz kieszonkowy przestaje działać po wypuszczeniu z ręki, kieszeni albo paska
/obj/item/aquila_translator/proc/aq_dropped(mob/user)
	user.aq_translator_off(REF(src))

/obj/item/aquila_translator/proc/aq_works()
	return !burnt && !rebooting

/// Włącza albo wyłącza tłumaczenie u tego, kto ma tłumacza przy sobie
/obj/item/aquila_translator/proc/aq_refresh()
	if(!ismob(loc))
		return
	var/mob/holder = loc
	if(aq_works())
		holder.aq_translator_on(REF(src))
	else
		holder.aq_translator_off(REF(src))

/obj/item/aquila_translator/proc/aq_tell_holder(message)
	var/mob/holder = get(src, /mob)
	if(holder)
		to_chat(holder, message)

/obj/item/aquila_translator/emp_act(severity)
	. = ..()
	if(burnt || (. & EMP_PROTECT_SELF))
		return
	if(severity == EMP_HEAVY && prob(AQ_TRANSLATOR_BURN_CHANCE))
		aq_burn()
		return
	rebooting = TRUE
	aq_tell_holder(span_warning("[capitalize(name)] trzeszczy i milknie. Restartuje się."))
	addtimer(CALLBACK(src, PROC_REF(aq_reboot)), AQ_TRANSLATOR_REBOOT_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	aq_refresh()

/obj/item/aquila_translator/proc/aq_reboot()
	if(burnt)
		return
	rebooting = FALSE
	aq_tell_holder(span_notice("[capitalize(name)] piszczy i znowu tłumaczy."))
	playsound(src, 'sound/machines/twobeep.ogg', 30, TRUE)
	aq_refresh()

/// Spalony na stałe: zostaje jako złom
/obj/item/aquila_translator/proc/aq_burn()
	burnt = TRUE
	rebooting = FALSE
	aq_tell_holder(span_danger("[capitalize(name)] sypie iskrami i gaśnie na dobre!"))
	name = "spalony [name]"
	desc = "[desc] Ten jest spalony i już nic nie przetłumaczy."
	if(burnt_icon_state)
		icon_state = burnt_icon_state
	else
		add_atom_colour("#6b6b6b", FIXED_COLOUR_PRIORITY)
	do_sparks(2, FALSE, src)
	aq_refresh()

/// Włącza tłumacza z danego źródła (tłumacz kieszonkowy, słuchawki z czipem): rozumienie Angielskiego i przechwytywanie mowy
/// Na usuwanym mobie nic nie robi: get_language_holder() założyłby nowy holder na kasowanym atomie (runtime)
/mob/proc/aq_translator_on(source)
	if(QDELETED(src))
		return
	ADD_TRAIT(src, TRAIT_AQ_TRANSLATOR, source)
	grant_language(/datum/language/english, TRUE, FALSE, LANGUAGE_TRANSLATOR)
	if(isliving(src))
		var/mob/living/living_src = src
		living_src.aq_update_translator_hook()

/mob/proc/aq_translator_off(source)
	if(QDELETED(src))
		return
	REMOVE_TRAIT(src, TRAIT_AQ_TRANSLATOR, source)
	if(!HAS_TRAIT(src, TRAIT_AQ_TRANSLATOR))
		remove_language(/datum/language/english, TRUE, FALSE, LANGUAGE_TRANSLATOR)
	if(isliving(src))
		var/mob/living/living_src = src
		living_src.aq_update_translator_hook()

#undef AQ_TRANSLATOR_REBOOT_TIME
#undef AQ_TRANSLATOR_BURN_CHANCE
