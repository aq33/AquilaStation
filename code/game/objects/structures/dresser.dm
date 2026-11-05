/obj/structure/dresser
	name = "komoda"
	desc = "Starannie wykonana drewniana komoda. Jest pełna bielizny."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = TRUE
	anchored = TRUE

/obj/structure/dresser/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>Zaczynasz [anchored ? "odkręcać" : "przykręcać"] [src].</span>")
		if(I.use_tool(src, user, 20, volume=50))
			to_chat(user, "<span class='notice'>[anchored ? "Odkręcasz" : "Przykręcasz"] [src].</span>")
			setAnchored(!anchored)
	else
		return ..()

/obj/structure/dresser/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)
	qdel(src)

/obj/structure/dresser/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		if(H.dna && H.dna.species && (NO_UNDERWEAR in H.dna.species.species_traits))
			to_chat(user, "<span class='warning'>Nie możesz nosić bielizny.</span>")
			return

		var/choice = i18n_input_choice(user, input(user, i18n_dialog_text(user, "Bielizna, podkoszulek czy skarpetki?"), i18n_dialog_text(user, "Przebieranie")) as null|anything in i18n_input_shown(user, list("Bielizna","Kolor bielizny","Podkoszulek","Skarpetki"))) // AQ EDIT - i18n okienka

		if(!Adjacent(user))
			return
		switch(choice)
			if("Bielizna")
				var/new_undies = i18n_input_choice(user, input(user, i18n_dialog_text(user, "Wybierz bieliznę"), i18n_dialog_text(user, "Przebieranie"))  as null|anything in i18n_input_shown(user, unlocked_accessories(GLOB.underwear_list, user.client))) // AQ EDIT // AQ EDIT - i18n okienka
				if(new_undies)
					H.underwear = new_undies
			if("Kolor bielizny")
				var/new_underwear_color = tgui_color_picker(H, "Wybierz kolor bielizny", "Kolor bielizny","#"+H.underwear_color)
				if(new_underwear_color)
					H.underwear_color = sanitize_hexcolor(new_underwear_color)
			if("Podkoszulek")
				var/new_undershirt = i18n_input_choice(user, input(user, i18n_dialog_text(user, "Wybierz podkoszulek"), i18n_dialog_text(user, "Przebieranie")) as null|anything in i18n_input_shown(user, unlocked_accessories(GLOB.undershirt_list, user.client))) // AQ EDIT // AQ EDIT - i18n okienka
				if(new_undershirt)
					H.undershirt = new_undershirt
			if("Skarpetki")
				var/new_socks = i18n_input_choice(user, input(user, i18n_dialog_text(user, "Wybierz skarpetki"), i18n_dialog_text(user, "Przebieranie")) as null|anything in i18n_input_shown(user, unlocked_accessories(GLOB.socks_list, user.client))) // AQ EDIT // AQ EDIT - i18n okienka
				if(new_socks)
					H.socks= new_socks

		add_fingerprint(H)
		H.update_body()
