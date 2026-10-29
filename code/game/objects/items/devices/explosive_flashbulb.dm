/obj/item/flashbulb/bomb
	name = "podejrzana żarówka błyskowa"
	desc = "Mocna żarówka błyskowa, która wygląda trochę dziwnie – z tyłu wychodzą z niej podejrzane przewody."
	charges_left = 15

/obj/item/flashbulb/bomb/use_flashbulb()
	explosion(src, -1, 1, 3, 4)
	charges_left = 0
	icon_state = "flashbulbburnt"
	return 1
