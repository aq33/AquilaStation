// Pre-packaged meals, canned, wrapped, and vended

// Cans
/obj/item/food/canned
	name = "powietrze w puszce"
	desc = "Jeśli kiedykolwiek zastanawiałeś się, skąd się bierze powietrze..."
	food_reagents = list(
		/datum/reagent/oxygen = 6,
		/datum/reagent/nitrogen = 24,
	)
	icon = 'icons/obj/food/canned.dmi'
	icon_state = "air"
	trash_type = /obj/item/trash/canned
	food_flags = FOOD_IN_CONTAINER
	w_class = WEIGHT_CLASS_NORMAL
	max_volume = 30
	preserved_food = TRUE
	var/maint = FALSE
	var/maint_overlay = ""
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/canned/Initialize(mapload)
	. = ..()
	if(maint)
		maint_overlay = "can_maint"
		add_overlay(maint_overlay)
		name = "[name] z tuneli technicznych"

/obj/item/food/canned/proc/open_can(mob/user)
	to_chat(user, "Odciągasz zawleczkę [src].")
	playsound(user.loc, 'sound/items/foodcanopen.ogg', 50)
	ENABLE_BITFIELD(reagents.flags, OPENCONTAINER)

/obj/item/food/canned/attack_self(mob/user)
	if(!is_drainable())
		open_can(user)
		icon_state = "[icon_state]_open"
	return ..()

/obj/item/food/canned/attack(mob/living/M, mob/user, def_zone)
	if (!is_drainable())
		to_chat(user, "<span class='warning'>Wieczko [src] nie zostało otwarte!</span>")
		return 0
	return ..()

///can types

/obj/item/food/canned/beans
	name = "puszka fasoli"
	desc = "Muzykalne warzywo w nieco mniej muzykalnym pojemniku."
	icon_state = "beans"
	trash_type = /obj/item/trash/canned/beans
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/ketchup = 4
	)
	tastes = list("fasola" = 3 , "sos pomidorowy" = 1, "cyna" = 1)
	foodtypes = VEGETABLES

/obj/item/food/canned/peaches
	name = "puszka brzoskwiń"
	desc = "Po prostu ładna puszka dojrzałych brzoskwiń pływających we własnym soku."
	icon_state = "peaches"
	trash_type = /obj/item/trash/canned/peaches
	food_reagents = list(
		/datum/reagent/consumable/peachjuice = 20,
		/datum/reagent/consumable/sugar = 8,
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("brzoskwinie" = 7, "cyna" = 1)
	foodtypes = FRUIT | SUGAR

/obj/item/food/canned/beefbroth
	name = "puszka gulaszu wołowego"
	desc = "Wołowina na szybko. Smak, do którego trzeba dorosnąć."
	icon_state = "beef"
	trash_type = /obj/item/trash/canned/beefbroth
	food_reagents = list(/datum/reagent/consumable/beefbroth = 50)
	tastes = list("mięso" = 7, "żelatyna wołowa" = 1, "cyna" = 1)
	foodtypes = MEAT | GROSS | JUNKFOOD

///maintenance variants

/obj/item/food/canned/maint

	maint = TRUE
	desc = "To tylko wspomnienie fasoli w puszce..."
	food_reagents = list(
		/datum/reagent/oxygen = 6,
		/datum/reagent/nitrogen = 22,
		/datum/reagent/sulfur = 2,
	)
	trash_type = /obj/item/trash/canned/maint

/obj/item/food/canned/beans/maint
	maint = TRUE
	desc = "Na tym etapie jej muzyka przetrwa stację."
	trash_type = /obj/item/trash/canned/beans/maint
	tastes = list("fasola" = 1 , "sos pomidorowy" = 1, "cyna" = 7)

/obj/item/food/canned/peaches/maint
	maint = TRUE
	desc = "Mam usta i muszę jeść."
	trash_type = /obj/item/trash/canned/peaches/maint
	tastes = list("brzoskwinie" = 1, "cyna" = 7)

/obj/item/food/canned/beefbroth/maint
	desc = "Naprawdę stara wołowina na szybko. Prawdziwa loteria."
	icon_state = "beef"
	trash_type = /obj/item/trash/canned/beefbroth/maint
	tastes = list("obrzydzenie" = 3, "żelatyna wołowa" = 1, "cyna" = 4)

