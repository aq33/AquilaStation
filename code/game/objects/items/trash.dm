//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/janitor.dmi'
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	desc = "To śmieci."
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/trash/attack(mob/M, mob/living/user)
	return

/obj/item/trash/raisins
	name = "\improper opakowanie po 4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/candy
	name = "papierek po cukierku"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "opakowanie po Cheesie Honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "torebka po chipsach"
	icon_state = "chips"

/obj/item/trash/boritos
	name = "torebka po Boritos"
	icon_state = "boritos"
	grind_results = list(/datum/reagent/aluminium = 1) //from the mylar bag

/obj/item/trash/popcorn
	name = "pudełko po popcornie"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "\improper opakowanie po suszonej wołowinie Scaredy's Private Reserve"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "opakowanie po syndi-ciastkach"
	icon_state = "syndi_cakes"

/obj/item/trash/energybar
	name = "papierek po batonie energetycznym"
	icon_state = "energybar"

/obj/item/trash/waffles
	name = "tacka po gofrach"
	icon_state = "waffles"

/obj/item/trash/pistachios
	name = "torebka po pistacjach"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "torebka po semkach"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "taca"
	icon_state = "tray"
	resistance_flags = NONE

/obj/item/trash/candle
	name = "ogarek"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/can
	name = "zgnieciona puszka"
	icon_state = "cola"
	resistance_flags = NONE
	grind_results = list(/datum/reagent/aluminium = 10)

/obj/item/trash/can/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)

/obj/item/trash/attack(mob/M, mob/living/user)
	return

/obj/item/trash/coal
	name = "bryłka węgla"
	icon = 'icons/obj/mining.dmi'
	icon_state = "slag"
	desc = "Ktoś trafił na listę niegrzecznych."
	grind_results = list(/datum/reagent/carbon = 20)

/obj/item/trash/coal/burn()
	visible_message("[src] stapia się w diament! Jednak ktoś nie był aż taki niegrzeczny...")
	new /obj/item/stack/ore/diamond(loc)
	qdel(src)

///canned foods

/obj/item/trash/canned
	name = "nieznana puszka"
	icon = 'icons/obj/food/canned.dmi'
	icon_state = "air_empty"
	resistance_flags = NONE
	var/maint = FALSE
	var/maint_overlay = ""
	grind_results = list(/datum/reagent/aluminium = 10)

/obj/item/trash/canned/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)
	if(maint)
		maint_overlay = "can_maint"
		add_overlay(maint_overlay)
		name = "[name] z tuneli technicznych"

/obj/item/trash/canned/maint
	maint = TRUE

/obj/item/trash/canned/beans
	name = "puszka po fasoli"
	icon_state = "beans_empty"

/obj/item/trash/canned/beans/maint
	maint = TRUE

/obj/item/trash/canned/peaches
	name = "puszka po brzoskwiniach"
	icon_state = "peaches_empty"

/obj/item/trash/canned/peaches/maint
	maint = TRUE

/obj/item/trash/canned/beefbroth
	name = "puszka po gulaszu wołowym"
	icon_state = "beef_empty"

/obj/item/trash/canned/beefbroth/maint
	maint = TRUE
