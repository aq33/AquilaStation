/obj/item/candle/incense
	name = "kadzidło"
	desc = "Choć kadzidło jest powszechne w całej Federacji, to Dominium słynie szczególnie z jego używania. To pachnie drzewem sandałowym."
	icon = 'nsv13/icons/obj/incense.dmi'
	icon_state = "candle_teal_off"
	item_state = "candle_teal_off"
	light_color = LIGHT_COLOR_FIRE
	heat = 2000
	wax = 500

/obj/item/candle/incense/update_icon()
	icon_state = "[lit ? "candle_teal_lit" : ""]"

/obj/item/candle/incense/pink
	name = "różowe kadzidło"
	desc = "Dominium słynie z używania kadzidła w obrzędach religijnych. To pachnie jak świt zimy, chłodny powiew i dreszcz przebiegający po plecach."
	icon_state = "candle_pink_off"
	item_state = "candle_pink_off"

/obj/item/candle/incense/pink/update_icon()
	icon_state = "[lit ? "candle_pink_lit" : ""]"
