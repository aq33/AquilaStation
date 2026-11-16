// Rozkazy drużyny (aquila/code/modules/squads/squad_orders.dm) tłumaczone przez DeepL (translation_api.dm).
// Członkowie, którzy czytają w innym języku niż nadawca (obcokrajowiec i polska załoga), dostają treść
// przetłumaczoną: w czacie, na ekranie i w TTS. Reszta drużyny dostaje rozkaz od razu, bez czekania na API.
// Bez klucza API albo przy błędzie wszyscy dostają oryginał.

/datum/squad/aq_deliver_order(mob/living/sender, message, title, list/targets, translated = FALSE)
	if(translated)
		return ..()
	var/from_english = aq_order_in_english(sender)
	var/list/other_language = list()
	for(var/mob/living/carbon/human/member as anything in targets)
		if(!aq_reads_english(member) != !from_english)
			other_language += member
	if(!length(other_language))
		return ..()
	var/list/same_language = targets - other_language
	if(length(same_language))
		..(sender, message, title, same_language)
	var/list/texts = list(message)
	SStranslation.translate(texts, from_english ? DEEPL_LANG_EN : DEEPL_LANG_PL, from_english ? DEEPL_LANG_PL : DEEPL_LANG_EN, CALLBACK(src, PROC_REF(aq_deliver_translated_order), sender, message, title, other_language))

/// Rozkaz obcokrajowca jest po angielsku (mowę przetłumaczoną już przy mówieniu liczymy jako polską, jak w aq_to_chat_speech)
/datum/squad/proc/aq_order_in_english(mob/living/sender)
	return sender?.mind?.aq_foreigner && !HAS_TRAIT(sender, TRAIT_AQ_TRANSLATED_SPEECH)

/// Wynik DeepL: przetłumaczona treść albo oryginał, gdy tłumaczenie się nie udało
/datum/squad/proc/aq_deliver_translated_order(mob/living/sender, message, title, list/targets, list/translations)
	if(QDELETED(src) || QDELETED(sender))
		return
	for(var/mob/member as anything in targets)
		if(QDELETED(member))
			targets -= member
	if(!length(targets))
		return
	var/text = length(translations) ? trim(translations[1]) : null
	aq_deliver_order(sender, length(text) ? text : message, title, targets, translated = TRUE)
