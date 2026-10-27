/datum/rune_spell/summon_plushie
	secret = TRUE
	name = "Przejaw Pluszowej Nar'Sie"
	desc = "Przywołuje Nar'Sie w pluszowej postaci, pomaga przygotować się do rytuału."
	desc_talisman = "Przywołuje Nar'Sie w pluszowej postaci, pomaga przygotować się do rytuału."
	invocation = "Sa Tatha Plu'Shi"
	word1 = /datum/rune_word/see
	word2 = /datum/rune_word/self
	word3 = /datum/rune_word/hide
	talisman_uses = 1
	page = "Ta runa przywołuje pluszaka twojego boga."
	var/casting = FALSE

/datum/rune_spell/summon_plushie/cast()
	if(casting)
		return
	var/obj/effect/new_rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	var/turf/T = get_turf(spell_holder)
	spell_holder.overlays += image('aquila/icons/bloodcult/cult.dmi', "build")
	casting = TRUE
	sleep(3 SECONDS)
	if (QDELETED(src) || !spell_holder)
		return
	var/obj/item/toy/plush/narplush/plush = new /obj/item/toy/plush/narplush(T)
	plush.alpha = 0
	plush.anchored = TRUE
	animate(plush, alpha = 255, time = 1.4 SECONDS)
	sleep(1.5 SECONDS)
	plush.anchored = FALSE
	if (QDELETED(src) || !spell_holder)
		return
	spell_holder.overlays -= image('aquila/icons/bloodcult/cult.dmi', "build")
	if (istype(R))
		qdel(R)
	else
		qdel(src)
