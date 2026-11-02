/obj/item/book/granter/spell/sexonbutton
	name = "kiepsko napisany fanfik"
	desc = "Książka, która chyba opisuje spotkanie słynnego zmiennokształtnego z osławionym jaszczurem głęboko w tunelach technicznych przy robotyce stacji."
	icon_state = "book8"
	spell = /obj/effect/proc_holder/spell/targeted/touch/sex
	spellname = "Seks na przycisk"
	remarks = list("Po co on tam włożył tę ssawkę?", "Oh.", "Po co on trzyma butelkę kosmicznego lubrykantu?")
	oneuse = FALSE

/obj/item/book/granter/spell/sexonbutton/one_use
	oneuse = TRUE

/obj/item/book/granter/spell/sexonbutton/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>Zaczynasz czytać [src]...</span>")

/obj/item/book/granter/spell/sexonbutton/on_reading_finished(mob/user)
	to_chat(user, "<span class='notice'>Czujesz, że chcesz spróbować tego całego „seksu”.</span>")
	var/obj/effect/proc_holder/spell/S = new spell
	user.mind.AddSpell(S)
	user.log_message("learned the spell [spellname] ([S])", LOG_ATTACK, color="orange")
	onlearned(user)

/obj/item/book/granter/spell/sexonbutton/recoil(mob/user)
	user.visible_message("<span class='warning'>[src] wybucha w deszczu wnętrzności!</span>")
	new /obj/effect/gibspawner/human/bodypartless(get_turf(src))
	qdel(src)
