
/datum/rune_spell/astraljourney
	name = "Podróż Astralna"
	desc = "Przenieś cząstkę duszy w projekcję astralną, by szpiegować załogę i dzielić się odkryciami z resztą kultu."
	desc_talisman = "Opuść ciało, by szpiegować wrogów."
	invocation = "Fwe'sh mah erl nyag r'ya!"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/travel
	word3 = /datum/rune_word/self
	page = "Po użyciu twoja dusza unosi się nad ciałem i możesz niewidzialnie poruszać się po całym poziomie. Słowa wypowiedziane w tym stanie usłyszy cały kult. Możesz też stać się namacalny, by rozmawiać z ludźmi, ale wtedy każde obrażenie kończy rytuał. Odsunięcie twojego ciała od runy również go kończy.\
		<br><br>Jeśli twoje ciało umrze, gdy wciąż korzystasz z runy, w miejscu projekcji astralnej powstanie cień.\
		<br><br>Ta runa zostaje po użyciu, można jej używać wielokrotnie."
	rune_flags = RUNE_STAND
	var/mob/living/simple_animal/astral_projection/astral = null
	var/cultist_key = ""
	var/list/restricted_verbs = list()

/datum/rune_spell/astraljourney/Destroy()
	. = ..()
	QDEL_NULL(astral)

/datum/rune_spell/astraljourney/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	cultist_key = activator.key

	to_chat(activator, span_notice("Gdy recytujesz inkantację, czujesz, jak twoja świadomość unosi się nad ciałem.") )
	astral = new(activator.loc)
	astral.ascend(activator)
	activator.ajourn = src

	step(astral, NORTH)
	astral.dir = SOUTH

	INVOKE_ASYNC(src, PROC_REF(handle_astral))

/datum/rune_spell/astraljourney/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/new_rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	new type(activator, R) // przypisuje R.active_spell w New()
	qdel(src)


/datum/rune_spell/astraljourney/abort(cause)
	QDEL_NULL(astral)
	..()

/datum/rune_spell/astraljourney/proc/handle_astral()
	while(!destroying_self && activator && activator.stat != DEAD && astral && astral.loc && activator.loc == spell_holder?.loc)
		sleep(10)
	abort()

/datum/rune_spell/astraljourney/Removed(mob/M)
	if (M == activator)
		abort(RITUALABORT_GONE)
