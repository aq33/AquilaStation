// Miłośnik klaunów i fan mima (tg): przypinka, która poprawia nastrój, gdy jest przypięta do munduru

/datum/quirk/clown_enjoyer
	name = "Miłośnik Klaunów"
	desc = "Uwielbiasz wygłupy klauna i poprawia ci się humor, gdy nosisz przypinkę klauna."
	icon = "map-pin"
	value = 1
	mob_trait = TRAIT_CLOWN_ENJOYER
	mood_quirk = TRUE
	gain_text = "<span class='notice'>Jesteś wielkim miłośnikiem klaunów.</span>"
	lose_text = "<span class='danger'>Klaun nie wydaje się już taki świetny.</span>"
	medical_record_text = "Pacjent twierdzi, że jest wielkim miłośnikiem klaunów."

/datum/quirk/clown_enjoyer/on_spawn()
	aq_nastroj_give_item(new /obj/item/clothing/accessory/clown_enjoyer_pin(get_turf(quirk_holder)))

/datum/quirk/clown_enjoyer/remove()
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "clown_enjoyer_pin")

/datum/quirk/mime_fan
	name = "Fan Mima"
	desc = "Jesteś fanem pantomimy i poprawia ci się humor, gdy nosisz przypinkę mima."
	icon = "thumbtack"
	value = 1
	mob_trait = TRAIT_MIME_FAN
	mood_quirk = TRUE
	gain_text = "<span class='notice'>Jesteś wielkim fanem mima.</span>"
	lose_text = "<span class='danger'>Mim nie wydaje się już taki świetny.</span>"
	medical_record_text = "Pacjent twierdzi, że jest wielkim fanem mimów."

/datum/quirk/mime_fan/on_spawn()
	aq_nastroj_give_item(new /obj/item/clothing/accessory/mime_fan_pin(get_turf(quirk_holder)))

/datum/quirk/mime_fan/remove()
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "mime_fan_pin")

/obj/item/clothing/accessory/clown_enjoyer_pin
	name = "przypinka klauna"
	desc = "Przypinka, którą pokazujesz, jak bardzo cenisz klaunów i ich wygłupy!"
	icon = 'aquila/icons/obj/clothing/quirk_pins.dmi'
	icon_state = "clown_enjoyer_pin"

/obj/item/clothing/accessory/clown_enjoyer_pin/on_uniform_equip(obj/item/clothing/under/U, user)
	var/mob/living/wearer = user
	if(istype(wearer) && HAS_TRAIT(wearer, TRAIT_CLOWN_ENJOYER))
		SEND_SIGNAL(wearer, COMSIG_ADD_MOOD_EVENT, "clown_enjoyer_pin", /datum/mood_event/clown_enjoyer_pin)

/obj/item/clothing/accessory/clown_enjoyer_pin/on_uniform_dropped(obj/item/clothing/under/U, user)
	var/mob/living/wearer = user
	if(istype(wearer))
		SEND_SIGNAL(wearer, COMSIG_CLEAR_MOOD_EVENT, "clown_enjoyer_pin")

/obj/item/clothing/accessory/mime_fan_pin
	name = "przypinka mima"
	desc = "Przypinka, którą pokazujesz, jak bardzo cenisz mimów i pantomimę!"
	icon = 'aquila/icons/obj/clothing/quirk_pins.dmi'
	icon_state = "mime_fan_pin"

/obj/item/clothing/accessory/mime_fan_pin/on_uniform_equip(obj/item/clothing/under/U, user)
	var/mob/living/wearer = user
	if(istype(wearer) && HAS_TRAIT(wearer, TRAIT_MIME_FAN))
		SEND_SIGNAL(wearer, COMSIG_ADD_MOOD_EVENT, "mime_fan_pin", /datum/mood_event/mime_fan_pin)

/obj/item/clothing/accessory/mime_fan_pin/on_uniform_dropped(obj/item/clothing/under/U, user)
	var/mob/living/wearer = user
	if(istype(wearer))
		SEND_SIGNAL(wearer, COMSIG_CLEAR_MOOD_EVENT, "mime_fan_pin")

/datum/mood_event/clown_enjoyer_pin
	description = "<span class='nicegreen'>Uwielbiam pokazywać moją przypinkę klauna!</span>\n"
	mood_change = 1

/datum/mood_event/mime_fan_pin
	description = "<span class='nicegreen'>Uwielbiam pokazywać moją przypinkę mima!</span>\n"
	mood_change = 1
