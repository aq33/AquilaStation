/obj/item/storage/cult
	name = "szkatuła"
	desc = "Ponuro wyglądająca skrzynka na rzeczy."
	icon = 'aquila/icons/bloodcult/storage.dmi'
	icon_state = "cult"

// AQUILA - tg/Monke: /obj/item/reagent_containers/cup. U nas kubki i zlewki to /obj/item/reagent_containers/glass.
/obj/item/reagent_containers/glass/cult
	name = "kusząca czara"
	desc = "Obsydianowy kielich w kształcie czaszki. Wyznawcy Nar-Sie zbierają w nim krew swoich ofiar."
	icon_state = "cult"
	icon = 'aquila/icons/bloodcult/reagent_containers.dmi'
	amount_per_transfer_from_this = 10
	volume = 60
	force = 5
	throwforce = 7
	/// AQUILA - nasze reagent_containers mają ikonę wypełnienia na sztywno, więc czara rysuje własne
	var/fill_icon = 'aquila/icons/bloodcult/reagentfillings.dmi'
	/// tg: ile czara wlewa do ust przy rzucie (u nas gulp_size mają tylko napoje)
	var/gulp_size = 5

/obj/item/reagent_containers/glass/cult/update_overlays()
	. = ..()
	if(!reagents?.total_volume)
		return
	var/mutable_appearance/filling = mutable_appearance(fill_icon, "cult")
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling

/obj/item/reagent_containers/glass/cult/on_reagent_change(changetype)
	. = ..()
	update_icon()

/obj/item/reagent_containers/glass/cult/examine(mob/user)
	. = ..()
	if (IS_CULTIST(user))
		. += "Picie krwi z tej czary zawsze bezpiecznie uzupełni twoje naczynia, bez względu na grupę krwi. Dla niekultystów działa to odwrotnie. Rzuć nią w nich, a jeśli nie mają zakrytej twarzy, część zawartości może wlać się im do ust."


/obj/item/reagent_containers/glass/cult/throw_impact(atom/hit_atom)
	if(reagents.total_volume)
		if (ishuman(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			if(!(H.is_mouth_covered()))
				H.visible_message("<span class='warning'>Część zawartości [src] wlewa się do ust [H].</span>","<span class='danger'>Część zawartości [src] wlewa ci się do ust.</span>")
				reagents.trans_to(H, gulp_size, method = INGEST)

/obj/item/reagent_containers/glass/cult/gamer
	name = "czara gracza"
	desc = "Plastikowy kubek w kształcie czaszki. Zwykle pełen paliwa Geometry."

/obj/item/reagent_containers/glass/cult/narsie_act()
	return

/obj/item/reagent_containers/glass/cult/bloodfilled

/obj/item/reagent_containers/glass/cult/bloodfilled/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/blood, 50)
