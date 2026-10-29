/obj/item/clothing/under/color
	desc = "Standardowy kolorowy kombinezon. Różnorodność to przyprawa życia!"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	icon_state = "jumpsuit"
	item_state = "jumpsuit"
	worn_icon_state = "jumpsuit"
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	supports_variations = DIGITIGRADE_VARIATION
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/color/jumpskirt
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON //Doesn't require a new icon.
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	icon_state = "jumpskirt"

/obj/item/clothing/under/color/random
	icon_state = "random_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/color/random/Initialize(mapload)
	..()
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - subtypesof(/obj/item/clothing/under/color/jumpskirt) - /obj/item/clothing/under/color/random - /obj/item/clothing/under/color/grey/glorf - /obj/item/clothing/under/color/black/ghost  - /obj/item/clothing/under/rank/prisoner)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING) //or else you end up with naked assistants running around everywhere...
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/jumpskirt/random
	icon_state = "random_jumpsuit"		//Skirt variant needed

/obj/item/clothing/under/color/jumpskirt/random/Initialize(mapload)
	..()
	var/obj/item/clothing/under/color/jumpskirt/C = pick(subtypesof(/obj/item/clothing/under/color/jumpskirt) - /obj/item/clothing/under/color/jumpskirt/random)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING)
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/black
	name = "czarny kombinezon"
	resistance_flags = NONE

/obj/item/clothing/under/color/jumpskirt/black
	name = "czarna spódnica"

/obj/item/clothing/under/color/black/ghost
	item_flags = DROPDEL

/obj/item/clothing/under/color/black/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/under/color/grey
	name = "szary kombinezon"
	desc = "Gustowny szary kombinezon, który przypomina ci stare dobre czasy."
	greyscale_colors = "#b3b3b3"

/obj/item/clothing/under/color/jumpskirt/grey
	name = "szara spódnica"
	desc = "Gustowna szara spódnica, która przypomina ci stare dobre czasy."
	greyscale_colors = "#b3b3b3"

/obj/item/clothing/under/color/grey/glorf
	name = "prastary kombinezon"
	desc = "Okropnie podarty i wystrzępiony szary kombinezon. Wygląda, jakby nie był prany od ponad dekady."
	icon_state = "grey_ancient"
	item_state = "gy_suit"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	can_adjust = FALSE

/obj/item/clothing/under/color/grey/glorf/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.force_say(hitby)
	return 0

/obj/item/clothing/under/color/blue
	name = "niebieski kombinezon"
	greyscale_colors = "#52aecc"

/obj/item/clothing/under/color/jumpskirt/blue
	name = "niebieska spódnica"
	greyscale_colors = "#52aecc"

/obj/item/clothing/under/color/green
	name = "zielony kombinezon"
	greyscale_colors = "#9ed63a"

/obj/item/clothing/under/color/jumpskirt/green
	name = "zielona spódnica"
	greyscale_colors = "#9ed63a"

/obj/item/clothing/under/color/orange
	name = "pomarańczowy kombinezon"
	desc = "Nie noś tego przy paranoicznych policjantach."
	greyscale_colors = "#ff8c19"

/obj/item/clothing/under/color/jumpskirt/orange
	name = "pomarańczowa spódnica"
	greyscale_colors = "#ff8c19"

/obj/item/clothing/under/color/pink
	name = "różowy kombinezon"
	desc = "Już samo patrzenie na to sprawia, że czujesz się <i>bajecznie</i>."
	greyscale_colors = "#ffa69b"

/obj/item/clothing/under/color/jumpskirt/pink
	name = "różowa spódnica"
	greyscale_colors = "#ffa69b"

/obj/item/clothing/under/color/red
	name = "czerwony kombinezon"
	greyscale_colors = "#eb0c07"

/obj/item/clothing/under/color/jumpskirt/red
	name = "czerwona spódnica"
	greyscale_colors = "#eb0c07"

/obj/item/clothing/under/color/white
	name = "biały kombinezon"
	greyscale_colors = "#ffffff"

/obj/item/clothing/under/color/jumpskirt/white
	name = "biała spódnica"
	greyscale_colors = "#ffffff"

/obj/item/clothing/under/color/yellow
	name = "żółty kombinezon"
	greyscale_colors = "#ffe14d"

/obj/item/clothing/under/color/jumpskirt/yellow
	name = "żółta spódnica"
	greyscale_colors = "#ffe14d"

/obj/item/clothing/under/color/darkblue
	name = "ciemnoniebieski kombinezon"
	greyscale_colors = "#3285ba"

/obj/item/clothing/under/color/jumpskirt/darkblue
	name = "ciemnoniebieska spódnica"
	greyscale_colors = "#3285ba"

/obj/item/clothing/under/color/teal
	name = "morski kombinezon"
	greyscale_colors = "#77f3b7"

/obj/item/clothing/under/color/jumpskirt/teal
	name = "morska spódnica"
	greyscale_colors = "#77f3b7"

/obj/item/clothing/under/color/lightpurple
	name = "jasnofioletowy kombinezon"
	greyscale_colors = "#9f70cc"

/obj/item/clothing/under/color/jumpskirt/lightpurple
	name = "jasnofioletowa spódnica"
	greyscale_colors = "#9f70cc"

/obj/item/clothing/under/color/darkgreen
	name = "ciemnozielony kombinezon"
	greyscale_colors = "#6fbc22"

/obj/item/clothing/under/color/jumpskirt/darkgreen
	name = "ciemnozielona spódnica"
	greyscale_colors = "#6fbc22"

/obj/item/clothing/under/color/lightbrown
	name = "jasnobrązowy kombinezon"
	greyscale_colors = "#c59431"

/obj/item/clothing/under/color/jumpskirt/lightbrown
	name = "jasnobrązowa spódnica"
	greyscale_colors = "#c59431"

/obj/item/clothing/under/color/khaki
	name = "kombinezon khaki"
	greyscale_colors = "#af9a43"

/obj/item/clothing/under/color/khaki/buster
	name = "kombinezon pogromcy"
	desc = "W lewej kieszeni widać wielką plamę. Ktoś musiał zgnieść naprawdę dużego twinkie."

/obj/item/clothing/under/color/brown
	name = "brązowy kombinezon"
	greyscale_colors = "#a17229"

/obj/item/clothing/under/color/jumpskirt/brown
	name = "brązowa spódnica"
	greyscale_colors = "#a17229"

/obj/item/clothing/under/color/maroon
	name = "bordowy kombinezon"
	greyscale_colors = "#cc295f"

/obj/item/clothing/under/color/jumpskirt/maroon
	name = "bordowa spódnica"
	greyscale_colors = "#cc295f"

/obj/item/clothing/under/color/durathread
	name = "kombinezon z duranici"
	desc = "Kombinezon uszyty z duranici. Wytrzymałe włókna dają noszącemu nieco ochrony."
	greyscale_colors = "#8291a1"
	armor = list("melee" = 10, "laser" = 10, "fire" = 40, "acid" = 10, "bomb" = 5, "stamina" = 30, "bleed" = 30)

/obj/item/clothing/under/color/rainbow
	name = "tęczowy kombinezon"
	desc = "Wielobarwny kombinezon!"
	icon_state = "rainbow"
	item_state = "rainbow"
	can_adjust = FALSE
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/under/color/jumpskirt/rainbow
	name = "tęczowa spódnica"
	desc = "Wielobarwna spódnica!"
	icon_state = "rainbow_skirt"
	item_state = "rainbow"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
