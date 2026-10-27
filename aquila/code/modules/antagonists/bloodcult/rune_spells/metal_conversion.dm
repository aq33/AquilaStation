/datum/rune_spell/metal_conversion
	name = "Przemiana Metalu"
	desc = "Zamienia całe żelazo na obszarze rytuału w runiczny metal."
	invocation = "Khari'd! Eske'te Sum!"
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/join
	word3 = /datum/rune_word/technology
	talisman_absorb = RUNE_CANNOT
	page = "Ta runa zamienia całe żelazo leżące na niej w runiczny metal."
	cost_invoke = 10

/datum/rune_spell/metal_conversion/cast()
	var/obj/effect/new_rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	if (pay_blood())
		var/turf/host_turf = get_turf(spell_holder)
		for(var/obj/item/stack/sheet/iron/iron_stack in host_turf)
			new /obj/item/stack/sheet/runed_metal(host_turf, iron_stack.amount)
			qdel(iron_stack)
		qdel(spell_holder)
	qdel(src)
