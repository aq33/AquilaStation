/obj/item/disk/plant_disk
	name = "dysk danych roślin"
	desc = "Firmowy dysk kompaktowy opracowany przez Yamato."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "disk"
	/// Our saved plant data
	var/saved
	/// What is this disk labeled as
	var/label

/obj/item/disk/plant_disk/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/pen))
		label_disk(user)

/obj/item/disk/plant_disk/examine(mob/user)
	. = ..()
	. += span_notice("Długopisem możesz opisać ten przedmiot ([src]).")

/obj/item/disk/plant_disk/proc/set_saved(_saved)
	saved = _saved
	name = "dysk danych roślin"
	if(istype(saved, /datum/plant_trait))
		var/datum/plant_trait/trait = saved
		name = "[initial(name)] - [trait.get_name()]"
	else if(istype(saved, /datum/plant_feature))
		var/datum/plant_feature/feature = saved
		name = "[initial(name)] - [feature.name]([feature.species_name])"
	desc = "[initial(desc)]\n[name]"

/obj/item/disk/plant_disk/proc/label_disk(mob/user)
	if(QDELETED(src) || !user.canUseTopic(src, BE_CLOSE))
		return
	var/input = tgui_input_text(user, "Nowa etykieta", "Nowa etykieta", "etykieta", MAX_NAME_LEN)
	if(QDELETED(src) || !user.canUseTopic(src, BE_CLOSE))
		return
	// Blank input removes label
	if(!input)
		name = initial(name)
		return
	// Check for slurs
	if(CHAT_FILTER_CHECK(input))
		to_chat(user, span_warning("Twoja wiadomość zawiera zakazane słowa."))
		return
	name = "[input]"
