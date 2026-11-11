// AQUILA - sprite'y z tg dla wiadra, spryskiwaczy, biblii i roślin doniczkowych: tylko zmienne i listy wyglądów

// Wiadro pokazuje zawartość nakładką jak w tg (stany bucket50 i bucket90 w icons/obj/reagentfillings.dmi)
/obj/item/reagent_containers/glass/bucket
	fill_icon_thresholds = list(50, 90)

// Spryskiwacz na pasku: jeden wspólny wygląd jak w tg (stan spraybottle w icons/mob/clothing/belt.dmi)
/obj/item/reagent_containers/spray
	worn_icon_state = "spraybottle"

// Słonecznik-spryskiwacz trzymany w ręku ma grafikę w pliku roślin, nie w plikach sprzątacza
/obj/item/reagent_containers/spray/waterflower
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'

// Dwa nowe wyglądy księgi kapelana z tg (Guru Granth Sahib, Kojiki) są dopisane wprost do list w core
// (code/game/objects/items/storage/book.dm, AQ EDIT): nadpisanie InitGlobal* tutaj nie działało w teście
// (kontroler woła je przez call() ze ścieżką procki). Guru Granth Sahib w ręku używa stanu Biblii.

// Stare wyglądy plant-26..29 zastąpione w tg sztucznymi roślinami; zostają w puli losowania jako plant-35..38
/obj/item/kirbyplants/random/generate_states()
	. = ..()
	for(var/i in 35 to 38)
		states += "plant-[i]"
