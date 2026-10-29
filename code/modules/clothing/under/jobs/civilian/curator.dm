/obj/item/clothing/under/rank/civilian/curator
	name = "rozsądny garnitur"
	desc = "Jest bardzo... rozsądny."
	icon_state = "red_suit"
	item_state = "red_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/curator/skirt
	name = "rozsądna garsonka"
	desc = "Jest bardzo... rozsądna."
	icon_state = "red_suit_skirt"
	item_state = "red_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/curator/treasure_hunter
	name = "strój poszukiwacza skarbów"
	desc = "Wytrzymały strój odpowiedni do poszukiwania skarbów."
	icon_state = "curator"
	item_state = "curator"

/obj/item/clothing/under/rank/civilian/curator/nasa
	name = "\improper kombinezon NASA"
	desc = "Ma logo NASA i jest wykonany z materiałów odpornych na kosmos."
	icon_state = "jumpsuit"
	item_state = "jumpsuit"
	worn_icon_state = "jumpsuit"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST | GROIN | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = NONE
