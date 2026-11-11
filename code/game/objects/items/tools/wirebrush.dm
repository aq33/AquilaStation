/**
 * The wirebrush is a tool whose sole purpose is to remove rust from anything that is rusty.
 * Because of the inherent nature of hard countering rust heretics it does it very slowly.
 */
/obj/item/wirebrush
	name = "szczotka druciana"
	desc = "Narzędzie do dokładnego szorowania rdzy ze ścian. Nie do włosów!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "wirebrush"
	tool_behaviour = TOOL_RUSTSCRAPER
	toolspeed = 1

/**
 * An advanced form of the wirebrush that trades the safety of the user for instant rust removal.
 * If the person using this is unlucky they are going to die painfully.
 */
/obj/item/wirebrush/advanced
	name = "zaawansowana szczotka druciana"
	desc = "Zaawansowana szczotka druciana, która za pomocą promieniowania niemal natychmiast upłynnia rdzę."
	icon_state = "wirebrush_adv"
	toolspeed = 0.1

	/// How likely is a critical fail?
	var/crit_fail_prob = 1

/obj/item/wirebrush/advanced/examine(mob/user)
	. = ..()
	. += "<span class='danger'>Jest naklejka ostrzegająca, że długotrwałe używanie [src] może spowodować utratę włosów, żółknięcie skóry i śmierć.</span>"

/obj/item/wirebrush/advanced/pre_attack(atom/A, mob/living/user)
	. = ..()

	if(!istype(user))
		return

	if(prob(crit_fail_prob))
		to_chat(user, "<span class='danger'>Czujesz ostry ból, a całe twoje ciało robi się dziwnie ciepłe.</span>")
		// AQ EDIT START - promieniowanie z Bee#13442
		SSradiation.irradiate(user, intensity = 100)
		user.emote("vomit")
		// AQ EDIT END
		return

	if(prob(25))
		user.emote("cough")
