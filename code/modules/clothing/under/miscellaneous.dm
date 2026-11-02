/obj/item/clothing/under/misc/pj
	name = "\improper piżama"
	desc = "Wygodny strój do spania, na drzemki albo leniuchowanie zamiast pracy."

/obj/item/clothing/under/misc/pj/red
	icon_state = "red_pyjamas"
	item_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/pj/blue
	icon_state = "blue_pyjamas"
	item_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/patriotsuit
	name = "patriotyczny strój"
	desc = "Motocykl nie wchodzi w zestaw."
	icon_state = "ek"
	item_state = "ek"
	can_adjust = FALSE

/obj/item/clothing/under/misc/vice_officer
	name = "kombinezon oficera obyczajówki"
	desc = "Standardowy strój przystojniaka, taki jak w Holo-Wizji."
	icon_state = "vice"
	item_state = "gy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/adminsuit
	name = "cybernetyczny kombinezon administracyjny"
	icon_state = "syndicate"
	item_state = "bl_suit"
	desc = "Cybernetycznie ulepszony kombinezon do zadań administracyjnych."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100,"energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100, "bleed" = 100)
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	blocks_shove_knockdown = TRUE

/obj/item/clothing/under/misc/burial
	name = "szaty pogrzebowe"
	desc = "Tradycyjne szaty pogrzebowe z początku XXII wieku."
	icon_state = "burial"
	item_state = "burial"
	can_adjust = FALSE
	has_sensor = NO_SENSORS

/obj/item/clothing/under/misc/overalls
	name = "ogrodniczki robotnika"
	desc = "Wytrzymałe ogrodniczki do roboty."
	icon_state = "overalls"
	item_state = "lb_suit"
	can_adjust = FALSE
	custom_price = 20

/obj/item/clothing/under/misc/assistantformal
	name = "galowy mundur majtka"
	desc = "Strój wyjściowy majtka. Po co majtkowi strój wyjściowy, wciąż nie wiadomo."
	icon_state = "assistant_formal"
	item_state = "gy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/plasmaman
	name = "kombinezon środowiskowy"
	desc = "Specjalny kombinezon ochronny, dzięki któremu formy życia oparte na plazmie mogą bezpiecznie przebywać w atmosferze z tlenem, a w razie kryzysu automatycznie je gasi. Choć jest hermetyczny, nie nadaje się do kosmosu."
	icon_state = "plasmaman"
	item_state = "plasmaman"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95, "stamina" = 0)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	can_adjust = FALSE
	strip_delay = 80
	resistance_flags = FIRE_PROOF
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 5
	envirosealed = TRUE


/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += "<span class='notice'>W tym kombinezonie pozostało ładunków gaśnicy: [extinguishes_left].</span>"

/obj/item/clothing/under/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>Kombinezon [H] automatycznie go gasi!</span>","<span class='warning'>Twój kombinezon automatycznie cię gasi.</span>")
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))
	return 0

/obj/item/clothing/under/plasmaman/attackby(obj/item/E, mob/user, params)
	..()
	if (istype(E, /obj/item/extinguisher_refill))
		if (extinguishes_left == 5)
			to_chat(user, "<span class='notice'>Wbudowana gaśnica jest pełna.</span>")
			return
		else
			extinguishes_left = 5
			to_chat(user, "<span class='notice'>Uzupełniasz wbudowaną gaśnicę kombinezonu, zużywając wkład.</span>")
			qdel(E)
			return

/obj/item/extinguisher_refill
	name = "wkład gaśniczy do kombinezonu środowiskowego"
	desc = "Wkład wypełniony sprężoną mieszanką gaśniczą, służący do uzupełniania automatycznej gaśnicy w kombinezonach środowiskowych."
	icon_state = "plasmarefill"
	icon = 'icons/obj/device.dmi'

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/clothing/under/gangster
	name = "garnitur gangstera"
	desc = "Ci, którzy niosą wolę tych, którzy odeszli, muszą iść naprzód."
	icon_state = "gangster"
	can_adjust = FALSE

/obj/item/clothing/under/gangster/purple
	desc = "Mam marzenie."
	icon_state = "gangster_p"
	armor = list("melee" = 10, "laser" = 10, "fire" = 40, "acid" = 10, "bomb" = 5, "stamina" = 30)
