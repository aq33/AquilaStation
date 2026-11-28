// AQUILA - pager schowany w kieszeni, plecaku albo PDA pokazuje nowe wiadomości napisem nad postacią noszącego.
// Napis widzi tylko noszący (balloon alert), w kolorze drużyny. Pager trzymany w ręce zostaje przy samym czacie.

/// Najdłuższy kawałek wiadomości w napisie nad postacią
#define SQUAD_PAGER_OVERHEAD_LENGTH 48

/datum/component/simple_teamchat/radio_dependent/squad/receive_message(atom/movable/sender, text, list/receipt_sound_override)
	. = ..()
	if(!.)
		return
	var/mob/living/wearer = get_user()
	if(!istype(wearer) || !wearer.client || wearer.client.prefs?.see_balloon_alerts == BALLOON_ALERT_NEVER)
		return
	var/obj/item/pager = parent
	if(!istype(pager) || wearer.is_holding(pager) || wearer.is_holding(pager.loc))
		return
	wearer.balloon_alert(wearer, squad_pager_overhead_text(sender, text), squad?.colour, FALSE)

/proc/squad_pager_overhead_text(atom/movable/sender, text)
	var/clean = trim(strip_html_simple(html_decode("[text]")))
	if(length_char(clean) > SQUAD_PAGER_OVERHEAD_LENGTH)
		clean = "[copytext_char(clean, 1, SQUAD_PAGER_OVERHEAD_LENGTH)]…"
	return sender ? "[sender]: [clean]" : clean

#undef SQUAD_PAGER_OVERHEAD_LENGTH
