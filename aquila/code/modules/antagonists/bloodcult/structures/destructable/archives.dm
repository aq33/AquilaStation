/// Some defines for items the cult archives can create.
#define CULT_BLINDFOLD "Opaska zeloty"
#define CURSE_ORB "Klątwa promu"
#define VEIL_WALKER "Zestaw wędrowca zasłony"
#define PREVIEW_IMAGE "preview"
#define OUTPUT_ITEMS "output"

// Cult archives. Gives out utility items.
/obj/structure/destructible/cult/item_dispenser/archives
	name = "archiwa"
	desc = "Biurko zawalone tajemnymi rękopisami i księgami w nieznanych językach. Od patrzenia na ten tekst cierpnie skóra."
	cult_examine_tip = "Można tu stworzyć opaski zeloty, kule klątwy promu i ekwipunek wędrowca zasłony."
	icon_state = "tomealtar"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	break_message = "<span class='warning'>Księgi i tomy archiwów obracają się w popiół, gdy biurko się rozpada!</span>"

/obj/structure/destructible/cult/item_dispenser/archives/setup_options()
	var/static/list/archive_items = list(
		CULT_BLINDFOLD = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "blindfold"),
			OUTPUT_ITEMS = list(/obj/item/clothing/glasses/hud/health/night/cultblind),
			),
		CURSE_ORB = list(
			PREVIEW_IMAGE = image(icon = 'aquila/icons/bloodcult/monke/obj/cult/items_and_weapons.dmi', icon_state = "shuttlecurse"),
			OUTPUT_ITEMS = list(/obj/item/shuttle_curse),
			),
		VEIL_WALKER = list(
			PREVIEW_IMAGE = image(icon = 'aquila/icons/bloodcult/monke/obj/cult/items_and_weapons.dmi', icon_state = "shifter"),
			OUTPUT_ITEMS = list(/obj/item/cult_shift, /obj/item/flashlight/flare/culttorch),
			),
	)

	options = archive_items

/obj/structure/destructible/cult/item_dispenser/archives/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cultitalic("Przywołujesz [spawned_item] z [src]!"))

// Preset for the library that doesn't spawn runed metal on destruction.
/obj/structure/destructible/cult/item_dispenser/archives/library
	debris = list()

#undef CULT_BLINDFOLD
#undef CURSE_ORB
#undef VEIL_WALKER
#undef PREVIEW_IMAGE
#undef OUTPUT_ITEMS
