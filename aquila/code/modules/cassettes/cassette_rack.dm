// AQUILA - stojak na kasety z Monkestation (machines/cassette_rack.dm). Wypełniony: czyste i losowe zatwierdzone kasety.

/obj/structure/cassette_rack
	name = "stojak na kasety"
	desc = "Bezpiecznie trzyma kasety."
	icon = 'aquila/icons/obj/cassettes/radio_station.dmi'
	icon_state = "cassette_pouch"
	anchored = TRUE
	density = FALSE

/obj/structure/cassette_rack/ComponentInitialize()
	. = ..()
	var/datum/component/storage/storage = AddComponent(/datum/component/storage/concrete)
	storage.max_items = 28
	storage.max_w_class = WEIGHT_CLASS_SMALL
	storage.max_combined_w_class = WEIGHT_CLASS_SMALL * 28
	storage.display_numerical_stacking = TRUE
	storage.can_hold = typecacheof(list(/obj/item/cassette_tape))
	RegisterSignal(src, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED), .proc/contents_changed)

/obj/structure/cassette_rack/proc/contents_changed()
	SIGNAL_HANDLER
	update_icon()

/obj/structure/cassette_rack/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "[icon_state]_[min(length(contents), 7)]")

/obj/structure/cassette_rack/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SHOW, user)
	return TRUE

/obj/structure/cassette_rack/prefilled
	/// Ile losowych zatwierdzonych kaset
	var/spawn_random = 5
	var/spawn_blanks = 10

/obj/structure/cassette_rack/prefilled/Initialize(mapload)
	. = ..()
	for(var/i in 1 to spawn_blanks)
		new /obj/item/cassette_tape/blank(src)
	for(var/datum/cassette/cassette as anything in SScassettes.unique_random_cassettes(spawn_random))
		new /obj/item/cassette_tape(src, cassette.id)
	update_icon()

/datum/supply_pack/service/walkmans
	name = "Walkman Crate"
	desc = "Dwa walkmany i pięć czystych kaset do nagrania w decku kasetowym."
	cost = 1500
	contains = list(/obj/item/walkman,
					/obj/item/walkman,
					/obj/item/cassette_tape/blank,
					/obj/item/cassette_tape/blank,
					/obj/item/cassette_tape/blank,
					/obj/item/cassette_tape/blank,
					/obj/item/cassette_tape/blank)
	crate_name = "walkman crate"
