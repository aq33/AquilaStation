// AQUILA - domyślny strój kapłana: sutanna z koloratką i biret (arkusz ojciecmateusz.dmi).
// Ikony przedmiotów zrobione z widoku z przodu, bo arkusz ma tylko wersje noszone.

/obj/item/clothing/under/rank/civilian/chaplain/sutanna
	name = "sutanna"
	desc = "Długa czarna sutanna z białą koloratką. Budzi zaufanie parafian i podejrzliwość przestępców."
	icon = 'aquila/icons/obj/clothing/kaplan.dmi'
	worn_icon = 'aquila/icons/mob/clothing/kaplan.dmi'
	icon_state = "sutanna"
	// Sutanna zakrywa nogi do kostek i nie ma wersji digitigrade, więc postać digitigrade dostaje w niej zwykłe nogi
	supports_variations = NONE

/obj/item/clothing/head/biret
	name = "biret"
	desc = "Czarne nakrycie głowy duchownego z czerwonym pomponem."
	icon = 'aquila/icons/obj/clothing/kaplan.dmi'
	worn_icon = 'aquila/icons/mob/clothing/kaplan.dmi'
	icon_state = "biret"

/datum/outfit/job/chaplain
	uniform = /obj/item/clothing/under/rank/civilian/chaplain/sutanna
	head = /obj/item/clothing/head/biret

/obj/machinery/vending/wardrobe/chap_wardrobe/Initialize(mapload)
	products[/obj/item/clothing/under/rank/civilian/chaplain/sutanna] = 2
	products[/obj/item/clothing/head/biret] = 2
	return ..()
