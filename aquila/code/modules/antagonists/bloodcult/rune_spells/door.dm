
/datum/rune_spell/door
	name = "Drzwi"
	desc = "Wznosi drzwi, które zatrzymają wrogów. Same otwierają się i zamykają za tobą, ale inni mogą je w końcu wyważyć."
	desc_talisman = "Użyj, by zdalnie uruchomić runę i wznieść drzwi blokujące wrogów."
	invocation = "Khari'd! Eske'te tannin!"
	word1 = /datum/rune_word/destroy
	word2 = /datum/rune_word/travel
	word3 = /datum/rune_word/self
	talisman_absorb = RUNE_CAN_ATTUNE
	page = "Ta runa od razu tworzy drzwi kultu, kosztem 10u krwi.\
		<br><br>Nie da się jej uruchomić, jeśli tuż obok stoją już inne drzwi kultu.\
		<br><br>Drzwi kultu da się dość szybko rozbić bronią, ale kultyści przechodzą przez nie prawie bez spowolnienia, więc świetnie nadają się do odwrotu. Postawione w technicznych korytarzach doprowadzą załogę do szału.\
		<br><br>Runę można też dostroić do talizmanu i uruchamiać zdalnie, co pozwala na ciekawe pułapki, jeśli runa była ukryta."
	cost_invoke = 10

/datum/rune_spell/door/cast()
	var/obj/effect/new_rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	if (pay_blood())
		if (locate(/obj/machinery/door/airlock/cult) in range(spell_holder, 1))
			abort(RITUALABORT_NEAR)
			return
		else
			var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
			var/obj/machinery/door/airlock/cult/new_door = new /obj/machinery/door/airlock/cult(get_turf(spell_holder))
			cult_datum?.gain_devotion(10, DEVOTION_TIER_1, "summon_door", new_door)
			qdel(spell_holder)
	qdel(src)
