// AQUILA - hardsuity inżynierii w barwach Orlenu (arkusz orlenhardsuity.dmi wpisany w stany *-legacy w plikach NSV13)
// oraz zespół urazowy: czerwony hardsuit Ordynatora i zwykły hardsuit zespołu urazowego dla lekarzy (arkusz traumateam.dmi).
// Nowe sprite'y nie mają wersji digitigrade, więc postaci z nogami digitigrade dostają w nich zwykłe nogi (species.dm, „Digi handling”).

/****************************\
|********** Orlen ************|
\****************************/
/obj/item/clothing/suit/space/hardsuit/engine
	supports_variations = NONE
	hardsuit_tail_colors = list("AAB", "821", "CCD")

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	supports_variations = NONE
	hardsuit_tail_colors = list("611", "912", "B23")

/obj/item/clothing/suit/space/hardsuit/engine/elite
	supports_variations = NONE
	hardsuit_tail_colors = list("445", "AAB", "CCD")

/****************************\
|******* Ordynator ***********|
\****************************/
/obj/item/clothing/head/helmet/space/hardsuit/medical/cmo
	icon = 'aquila/icons/obj/clothing/hardsuit_trauma.dmi'
	worn_icon = 'aquila/icons/mob/clothing/hardsuit_trauma.dmi'
	icon_state = "hardsuit0-cmo"
	hardsuit_type = "cmo"

/obj/item/clothing/suit/space/hardsuit/medical/cmo
	icon = 'aquila/icons/obj/clothing/hardsuit_trauma.dmi'
	worn_icon = 'aquila/icons/mob/clothing/hardsuit_trauma.dmi'
	icon_state = "hardsuit-cmo"
	supports_variations = NONE
	hardsuit_tail_colors = list("BBA", "624", "0A9")

/****************************\
|****** zespół urazowy *******|
\****************************/
/obj/item/clothing/head/helmet/space/hardsuit/medical/trauma
	name = "hełm hardsuitu zespołu urazowego"
	desc = "Hełm zespołu urazowego do akcji ratunkowych w próżni. Wykonany z lekkich materiałów dla większej wygody, ale nie chroni oczu przed intensywnym światłem."
	icon = 'aquila/icons/obj/clothing/hardsuit_trauma.dmi'
	worn_icon = 'aquila/icons/mob/clothing/hardsuit_trauma.dmi'
	icon_state = "hardsuit0-trauma"
	hardsuit_type = "trauma"

/obj/item/clothing/suit/space/hardsuit/medical/trauma
	name = "hardsuit zespołu urazowego"
	desc = "Lekki skafander zespołu urazowego do wyciągania rannych z próżni i miejsc katastrof. Łatwo się w nim ruszać."
	icon = 'aquila/icons/obj/clothing/hardsuit_trauma.dmi'
	worn_icon = 'aquila/icons/mob/clothing/hardsuit_trauma.dmi'
	icon_state = "hardsuit-trauma"
	supports_variations = NONE
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical/trauma
	hardsuit_tail_colors = list("165", "0A9", "BBA")

/// Zespół urazowy z modułami jak zwykły hardsuit lekarza
/obj/item/clothing/suit/space/hardsuit/medical/trauma/loaded
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/quick_carry,
	)

/// Szafa na skafander zespołu urazowego, stawiana w części medycznej dostępnej tylko dla personelu
/obj/machinery/suit_storage_unit/medical/trauma
	suit_type = /obj/item/clothing/suit/space/hardsuit/medical/trauma/loaded
