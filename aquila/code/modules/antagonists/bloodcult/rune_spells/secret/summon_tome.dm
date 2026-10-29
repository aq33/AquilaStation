
/datum/rune_spell/summontome
	secret = TRUE
	name = "Przywołanie Księgi"
	desc = "Przywołuje tajemną księgę pełną wiedzy Nar-Sie."
	desc_talisman = "Po użyciu zamienia się w tajemną księgę."
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	word1 = /datum/rune_word/see
	word2 = /datum/rune_word/blood
	word3 = /datum/rune_word/hell
	cost_invoke = 4
	page = ""

/datum/rune_spell/summontome/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	if (pay_blood())
		var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
		cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "conjure_paraphernalia", "Arcane Tome")
		spell_holder.visible_message(span_rose("Symbole runy zlewają się ze sobą, a w ich miejscu przybiera kształt Tajemna Księga."))
		var/turf/T = get_turf(spell_holder)
		var/obj/item/tome/AT = new (T)
		anim(target = AT, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "tome_spawn")
		qdel(spell_holder)
	else
		qdel(src)

/datum/rune_spell/summontome/cast_talisman()//The talisman simply turns into a tome.
	var/turf/T = get_turf(spell_holder)
	var/obj/item/tome/AT = new (T)
	if (spell_holder == activator.get_active_held_item())
		activator.dropItemToGround(spell_holder)
		activator.put_in_active_hand(AT)
		var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
		cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "conjure_paraphernalia", "Arcane Tome")
	else//are we using the talisman from a tome?
		activator.put_in_hands(AT)
	flick("tome_spawn", AT)
	qdel(src)
