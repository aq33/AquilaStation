
/datum/cult_tattoo/memorize
	name = TATTOO_MEMORIZE//Arcane Dimension
	desc = "Pozwala ukryć księgę w powietrzu i wyciągnąć ją, kiedy tylko zechcesz."
	icon_state = "memorize"
	tier = 2

/datum/cult_tattoo/memorize/getTattoo(mob/M)
	..()
	if (IS_CULTIST(M))
		var/datum/action/cooldown/spell/cult/arcane_dimension/new_spell = new
		new_spell.Grant(M)
