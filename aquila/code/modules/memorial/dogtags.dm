// AQUILA - nieśmiertelniki i tablica pamięci (pomysł z CM13: zdjęcie blaszki ze zwłok i wpis poległego na pomniku).
// Nieśmiertelnik wisi przy identyfikatorze: w oknie przeszukiwania zwłok przy polu identyfikatora jest akcja „Zdejmij nieśmiertelnik”.
// Blaszka zaniesiona do tablicy pamięci wpisuje poległego na listę widoczną na każdej tablicy do końca rundy.

/// Poległa załoga zapisana na tablicach pamięci w tej rundzie: "imię" -> "stanowisko, godzina"
GLOBAL_LIST_EMPTY(memorial_fallen)

/obj/item/card/id
	/// Czy ktoś zdjął już nieśmiertelnik przypięty do tego identyfikatora
	var/dogtag_taken = FALSE

/obj/item/dogtag
	name = "nieśmiertelnik"
	desc = "Dwie metalowe blaszki na łańcuszku. Zanieś je do tablicy pamięci."
	icon = 'aquila/icons/obj/dogtag.dmi'
	icon_state = "dogtag"
	w_class = WEIGHT_CLASS_TINY
	/// Imię wybite na blaszce
	var/fallen_name
	/// Stanowisko wybite na blaszce
	var/fallen_assignment

/obj/item/dogtag/Initialize(mapload, fallen_name, fallen_assignment)
	. = ..()
	src.fallen_name = fallen_name
	src.fallen_assignment = fallen_assignment
	if(fallen_name)
		name = "nieśmiertelnik ([fallen_name])"

/obj/item/dogtag/examine(mob/user)
	. = ..()
	if(fallen_name)
		. += "<span class='notice'>Wybito na nim: <b>[fallen_name]</b>[fallen_assignment ? ", [fallen_assignment]" : ""].</span>"

/datum/strippable_item/mob_item_slot/needs_jumpsuit/id
	/// Ile trwa zdejmowanie nieśmiertelnika
	var/dogtag_time = 2 SECONDS

/datum/strippable_item/mob_item_slot/needs_jumpsuit/id/get_alternate_action(atom/source, mob/user)
	var/mob/living/carbon/human/corpse = source
	var/obj/item/card/id/id_card = get_item(source)
	if(!istype(corpse) || corpse.stat != DEAD || !istype(id_card) || id_card.dogtag_taken)
		return null
	return "take_dogtag"

/datum/strippable_item/mob_item_slot/needs_jumpsuit/id/alternate_action(atom/source, mob/user)
	var/mob/living/carbon/human/corpse = source
	var/obj/item/card/id/id_card = get_item(source)
	if(!istype(corpse) || !istype(id_card) || id_card.dogtag_taken)
		return
	user.visible_message("<span class='notice'>[user] zdejmuje nieśmiertelnik z ciała [corpse].</span>", "<span class='notice'>Zdejmujesz nieśmiertelnik z ciała [corpse]...</span>")
	if(!do_after(user, dogtag_time, target = corpse))
		return
	if(id_card.dogtag_taken || get_item(source) != id_card)
		return
	id_card.dogtag_taken = TRUE
	var/obj/item/dogtag/tag = new(get_turf(corpse), id_card.registered_name || corpse.real_name, id_card.assignment)
	user.put_in_hands(tag)
	to_chat(user, "<span class='notice'>Masz nieśmiertelnik. Zanieś go do tablicy pamięci.</span>")

/obj/structure/memorial_board
	name = "tablica pamięci"
	desc = "Kamienna tablica z nazwiskami tych, którzy nie wrócili. Przyłóż do niej nieśmiertelnik poległego, żeby wyryć jego imię."
	icon = 'icons/obj/tomb.dmi'
	icon_state = "memorial"
	density = TRUE
	anchored = TRUE
	max_integrity = 300

/obj/structure/memorial_board/examine(mob/user)
	. = ..()
	. += memorial_lines()

/obj/structure/memorial_board/proc/memorial_lines()
	if(!length(GLOB.memorial_fallen))
		return list("<span class='notice'>Tablica jest jeszcze pusta.</span>")
	. = list("<span class='notice'><b>Polegli w tej misji:</b></span>")
	for(var/fallen in GLOB.memorial_fallen)
		. += "<span class='notice'>[fallen] ([GLOB.memorial_fallen[fallen]])</span>"

/obj/structure/memorial_board/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/dogtag))
		return ..()
	var/obj/item/dogtag/tag = I
	if(!tag.fallen_name)
		to_chat(user, "<span class='warning'>Na tym nieśmiertelniku nic nie wybito.</span>")
		return TRUE
	if(GLOB.memorial_fallen[tag.fallen_name])
		to_chat(user, "<span class='warning'>[tag.fallen_name] jest już na tablicy.</span>")
		return TRUE
	if(!user.temporarilyRemoveItemFromInventory(tag))
		return TRUE
	GLOB.memorial_fallen[tag.fallen_name] = "[tag.fallen_assignment || "załoga"], [station_time_timestamp("hh:mm")]"
	user.visible_message("<span class='notice'>[user] wiesza nieśmiertelnik na [src]. Na tablicy pojawia się imię: <b>[tag.fallen_name]</b>.</span>", "<span class='notice'>Wieszasz nieśmiertelnik na [src]. [tag.fallen_name] nie zostanie zapomniany.</span>")
	playsound(src, 'sound/items/handling/component_drop.ogg', 40, TRUE)
	log_game("[key_name(user)] added [tag.fallen_name] to the memorial board at [AREACOORD(src)]")
	qdel(tag)
	return TRUE

/datum/crafting_recipe/memorial_board
	name = "Tablica pamięci"
	result = /obj/structure/memorial_board
	reqs = list(/obj/item/stack/sheet/iron = 10)
	tools = list(TOOL_WELDER)
	time = 10 SECONDS
	category = CAT_MISC
