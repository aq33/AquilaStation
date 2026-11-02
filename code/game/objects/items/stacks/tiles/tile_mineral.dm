/obj/item/stack/tile/mineral/plasma
	name = "plazmowa płytka"
	singular_name = "plazmowa płytka podłogowa"
	desc = "Płytka z łatwopalnej plazmy. To się na pewno dobrze skończy."
	icon_state = "tile_plasma"
	item_state = "tile-plasma"
	turf_type = /turf/open/floor/mineral/plasma
	mineralType = "plasma"
	materials = list(/datum/material/plasma=500)

/obj/item/stack/tile/mineral/uranium
	name = "uranowa płytka"
	singular_name = "uranowa płytka podłogowa"
	desc = "Płytka z uranu. Trochę kręci ci się w głowie."
	icon_state = "tile_uranium"
	item_state = "tile-uranium"
	turf_type = /turf/open/floor/mineral/uranium
	mineralType = "uranium"
	materials = list(/datum/material/uranium=500)

/obj/item/stack/tile/mineral/gold
	name = "złota płytka"
	singular_name = "złota płytka podłogowa"
	desc = "Płytka ze złota. Czuć tu prawdziwy szpan."
	icon_state = "tile_gold"
	item_state = "tile-gold"
	turf_type = /turf/open/floor/mineral/gold
	mineralType = "gold"
	materials = list(/datum/material/gold=500)

/obj/item/stack/tile/mineral/silver
	name = "srebrna płytka"
	singular_name = "srebrna płytka podłogowa"
	desc = "Płytka ze srebra. Bijące od niej światło oślepia."
	icon_state = "tile_silver"
	item_state = "tile-silver"
	turf_type = /turf/open/floor/mineral/silver
	mineralType = "silver"
	materials = list(/datum/material/silver=500)

/obj/item/stack/tile/mineral/copper
	name = "miedziana płytka"
	singular_name = "miedziana płytka podłogowa"
	desc = "Płytka z miedzi, ale się błyszczy!"
	icon_state = "tile_copper"
	turf_type = /turf/open/floor/mineral/copper
	mineralType = "copper"
	materials = list(/datum/material/copper=500)

/obj/item/stack/tile/mineral/diamond
	name = "diamentowa płytka"
	singular_name = "diamentowa płytka podłogowa"
	desc = "Płytka z diamentu. Wow, po prostu wow."
	icon_state = "tile_diamond"
	item_state = "tile-diamond"
	turf_type = /turf/open/floor/mineral/diamond
	mineralType = "diamond"
	materials = list(/datum/material/diamond=500)

/obj/item/stack/tile/mineral/bananium
	name = "płytka z bananium"
	singular_name = "podłogowa płytka z bananium"
	desc = "Płytka z bananium, HOOOOOOOOONK!"
	icon_state = "tile_bananium"
	item_state = "tile-bananium"
	turf_type = /turf/open/floor/mineral/bananium
	mineralType = "bananium"
	materials = list(/datum/material/bananium=500)

/obj/item/stack/tile/mineral/abductor
	name = "płytka podłogowa obcych"
	singular_name = "płytka podłogowa obcych"
	desc = "Płytka ze stopu obcych."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "tile_abductor"
	item_state = "tile-abductor"
	turf_type = /turf/open/floor/mineral/abductor
	mineralType = "abductor"

/obj/item/stack/tile/mineral/titanium
	name = "tytanowa płytka"
	singular_name = "tytanowa płytka podłogowa"
	desc = "Płytka z tytanu, używana na promach. Użyj jej w dłoni, by wybrać rodzaj tytanowych płytek."
	icon_state = "tile_shuttle"
	item_state = "tile-shuttle"
	turf_type = /turf/open/floor/mineral/titanium
	mineralType = "titanium"
	materials = list(/datum/material/titanium=500)
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/titanium,
		/obj/item/stack/tile/mineral/titanium/yellow,
		/obj/item/stack/tile/mineral/titanium/blue,
		/obj/item/stack/tile/mineral/titanium/white,
		/obj/item/stack/tile/mineral/titanium/purple,
		/obj/item/stack/tile/mineral/titanium/alt,
		/obj/item/stack/tile/mineral/titanium/alt/yellow,
		/obj/item/stack/tile/mineral/titanium/alt/blue,
		/obj/item/stack/tile/mineral/titanium/alt/white,
		/obj/item/stack/tile/mineral/titanium/alt/purple,
		)

/obj/item/stack/tile/mineral/titanium/yellow
	name = "żółta tytanowa płytka"
	singular_name = "żółta tytanowa płytka podłogowa"
	desc = "Żółte tytanowe płytki. Użyj ich w dłoni, by wybrać rodzaj tytanowych płytek."
	turf_type = /turf/open/floor/mineral/titanium/yellow
	icon_state = "tile_titanium_yellow"

/obj/item/stack/tile/mineral/titanium/blue
	name = "niebieska tytanowa płytka"
	singular_name = "niebieska tytanowa płytka podłogowa"
	desc = "Niebieskie tytanowe płytki. Użyj ich w dłoni, by wybrać rodzaj tytanowych płytek."
	turf_type = /turf/open/floor/mineral/titanium/blue
	icon_state = "tile_titanium_blue"

/obj/item/stack/tile/mineral/titanium/white
	name = "biała tytanowa płytka"
	singular_name = "biała tytanowa płytka podłogowa"
	desc = "Białe tytanowe płytki. Użyj ich w dłoni, by wybrać rodzaj tytanowych płytek."
	turf_type = /turf/open/floor/mineral/titanium/white
	icon_state = "tile_titanium_white"

/obj/item/stack/tile/mineral/titanium/purple
	name = "fioletowa tytanowa płytka"
	singular_name = "fioletowa tytanowa płytka podłogowa"
	desc = "Fioletowe tytanowe płytki. Użyj ich w dłoni, by wybrać rodzaj tytanowych płytek."
	turf_type = /turf/open/floor/mineral/titanium/purple
	icon_state = "tile_titanium_purple"

/obj/item/stack/tile/mineral/titanium/alt
	name = "gładka tytanowa płytka"
	singular_name = "gładka tytanowa płytka podłogowa"
	desc = "Gładkie tytanowe płytki podłogowe. Użyj ich w dłoni, by wybrać rodzaj tytanowych płytek."
	turf_type = /turf/open/floor/mineral/titanium/alt
	icon_state = "tile_titanium_alt"

/obj/item/stack/tile/mineral/titanium/alt/yellow
	name = "gładka żółta tytanowa płytka"
	singular_name = "gładka żółta tytanowa płytka podłogowa"
	desc = "Gładkie żółte tytanowe płytki podłogowe. Użyj ich w dłoni, by wybrać rodzaj tytanowych płytek."
	turf_type = /turf/open/floor/mineral/titanium/alt/yellow
	icon_state = "tile_titanium_yellow_alt"

/obj/item/stack/tile/mineral/titanium/alt/blue
	name = "gładka niebieska tytanowa płytka"
	singular_name = "gładka niebieska tytanowa płytka podłogowa"
	desc = "Gładkie niebieskie tytanowe płytki podłogowe. Użyj ich w dłoni, by wybrać rodzaj tytanowych płytek."
	turf_type = /turf/open/floor/mineral/titanium/alt/blue
	icon_state = "tile_titanium_blue_alt"

/obj/item/stack/tile/mineral/titanium/alt/white
	name = "gładka biała tytanowa płytka"
	singular_name = "gładka biała tytanowa płytka podłogowa"
	desc = "Gładkie białe tytanowe płytki podłogowe. Użyj ich w dłoni, by wybrać rodzaj tytanowych płytek."
	turf_type = /turf/open/floor/mineral/titanium/alt/white
	icon_state = "tile_titanium_white_alt"

/obj/item/stack/tile/mineral/titanium/alt/purple
	name = "gładka fioletowa tytanowa płytka"
	singular_name = "gładka fioletowa tytanowa płytka podłogowa"
	desc = "Gładkie fioletowe tytanowe płytki podłogowe. Użyj ich w dłoni, by wybrać rodzaj tytanowych płytek."
	turf_type = /turf/open/floor/mineral/titanium/alt/purple
	icon_state = "tile_titanium_purple_alt"

/obj/item/stack/tile/mineral/plastitanium
	name = "plastytanowa płytka"
	singular_name = "plastytanowa płytka podłogowa"
	desc = "Płytka z plastytanu, używana na wyjątkowo złych promach."
	icon_state = "tile_darkshuttle"
	item_state = "tile-darkshuttle"
	turf_type = /turf/open/floor/mineral/plastitanium
	mineralType = "plastitanium"
	materials = list(/datum/material/titanium=250, /datum/material/plasma=250)

/obj/item/stack/tile/mineral/snow
	name = "śnieżna płytka"
	singular_name = "śnieżna płytka"
	desc = "Warstwa śniegu."
	icon_state = "tile_snow"
	item_state = "tile-silver"
	turf_type = /turf/open/floor/grass/snow/safe
	mineralType = "snow"

/obj/item/stack/tile/mineral/wax
	name = "woskowa płytka"
	singular_name = "woskowa płytka"
	desc = "Duży, płaski arkusz wosku."
	icon_state = "tile_wax"
	item_state = "tile-wax"
	turf_type = /turf/open/floor/wax
	mineralType = "wax"
