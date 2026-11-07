// AQUILA - dział zaopatrzenia w barwach InPostu (żółć i grafit).
// Mundury, czapki, kurtki, sprzęt górnika, szafki, CargoDrobe, tablety i karty z arkusza inpost.dmi wpisane w miejsce stanów zaopatrzenia,
// a to, czego arkusz nie ma (wnętrza szafek, wersje zwinięte, słuchawki, kombinezon plazmamański), przemalowane z brązu na żółć.
// Nowe przedmioty (beret kwatermistrza, opaska, plecaki) w aquila/icons/inpost/. Profesje i kanał radia bez zmian.

/****************************\
|********* paczkomat *********|
\****************************/
// Wyloty poczty rurowej w działach wyglądają jak paczkomat. Stany "outlet" i "outlet-open" mają te same nazwy co w disposal.dmi,
// więc flick() przy wyrzucie odgrywa animację paczki bez zmian w kodzie wylotu. Strzałka w marginesie pokazuje kierunek wyrzutu.
// Wyloty śmieci i amunicji zostają zwykłe; na mapach podmienione są tylko wyloty poza utylizacją, tunelami i stanowiskami broni.
/obj/structure/disposaloutlet/paczkomat
	name = "paczkomat"
	desc = "Paczkomat InPost podłączony do rury. Wyrzuca wszystko, co do niego przyjdzie."
	icon = 'aquila/icons/inpost/paczkomat.dmi'

/****************************\
|********** dekale ***********|
\****************************/
// Brązowe dekale w obszarach zaopatrzenia na mapach są podmienione na te podtypy (te same kształty).
#define INPOST_DECAL_COLOR "#FFCD00"

/obj/effect/turf_decal/tile/brown/inpost
	name = "narożnik InPostu"
	color = INPOST_DECAL_COLOR

/obj/effect/turf_decal/tile/ship/brown/inpost
	name = "narożnik InPostu"
	color = INPOST_DECAL_COLOR

/obj/effect/turf_decal/tile/ship/half/brown/inpost
	name = "połówka InPostu"
	color = INPOST_DECAL_COLOR

/obj/effect/turf_decal/guideline/guideline_in/brown/inpost
	name = "linia InPostu"
	color = INPOST_DECAL_COLOR

#undef INPOST_DECAL_COLOR

/****************************\
|*********** śluzy ***********|
\****************************/
// Grafika śluz górniczych i ładowni (aquila/icons/paradise/.../station/mining.dmi) jest w żółci InPostu.
// NSV barwił śluzę górniczą dodatkowo na brąz (color), przez co drzwi kwatermistrza i górników wyglądały na brudne.
/obj/machinery/door/airlock/ship/station/mining
	color = null

/****************************\
|***** hełm plazmoludzi ******|
\****************************/
// Żółty pas InPostu na szarym hełmie, jak na kombinezonie środowiskowym
/obj/item/clothing/head/helmet/space/plasmaman/cargo
	greyscale_colors = "#ADADAD#FFCD00#ADADAD"

/****************************\
|******* nowe przedmioty *****|
\****************************/
/obj/item/clothing/head/beret/supply/qm
	name = "beret kwatermistrza InPost"
	desc = "Żółty beret z insygniami kierownika oddziału InPostu."
	icon = 'aquila/icons/inpost/inpost.dmi'
	worn_icon = 'aquila/icons/inpost/inpost_noszone.dmi'
	icon_state = "beret_qm"

/obj/item/clothing/head/aquila/headband/inpost
	name = "opaska InPostu"
	desc = "Żółta opaska na głowę z logo InPostu."
	icon = 'aquila/icons/inpost/inpost.dmi'
	worn_icon = 'aquila/icons/inpost/inpost_noszone.dmi'
	icon_state = "headband_inpost"
	color = null

/obj/item/storage/backpack/inpost
	name = "plecak InPostu"
	desc = "Żółty plecak kuriera. Mieści więcej paczek, niż się wydaje."
	icon = 'aquila/icons/inpost/inpost.dmi'
	worn_icon = 'aquila/icons/inpost/inpost_noszone.dmi'
	icon_state = "inpostpack"

/obj/item/storage/backpack/satchel/inpost
	name = "torba na ramię InPostu"
	desc = "Żółta torba kuriera na ramię."
	icon = 'aquila/icons/inpost/inpost.dmi'
	worn_icon = 'aquila/icons/inpost/inpost_noszone.dmi'
	icon_state = "satchel-inpost"

/obj/item/storage/backpack/duffelbag/inpost
	name = "torba podróżna InPostu"
	desc = "Duża żółta torba kuriera na paczki gabarytowe."
	icon = 'aquila/icons/inpost/inpost.dmi'
	worn_icon = 'aquila/icons/inpost/inpost_noszone.dmi'
	icon_state = "duffel-inpost"

// Magazynier i Kwatermistrz zaczynają z torbami InPostu
/datum/outfit/job/cargo_technician
	backpack = /obj/item/storage/backpack/inpost
	satchel = /obj/item/storage/backpack/satchel/inpost
	duffelbag = /obj/item/storage/backpack/duffelbag/inpost

/datum/outfit/job/quartermaster
	backpack = /obj/item/storage/backpack/inpost
	satchel = /obj/item/storage/backpack/satchel/inpost
	duffelbag = /obj/item/storage/backpack/duffelbag/inpost

/obj/structure/closet/secure_closet/quartermaster/PopulateContents()
	..()
	new /obj/item/clothing/head/beret/supply/qm(src)
	new /obj/item/clothing/under/plasmaman/cargo/quartermaster(src)

// Kwatermistrz-plazmoludź miał kombinezon magazyniera, arkusz inpostenviro.dmi rysuje dla niego własny (w ręku jak magazyniera)
/obj/item/clothing/under/plasmaman/cargo/quartermaster
	name = "kombinezon środowiskowy kwatermistrza InPostu"
	desc = "Kombinezon środowiskowy plazmoluda w barwach kwatermistrza InPostu."
	icon = 'aquila/icons/inpost/inpost.dmi'
	worn_icon = 'aquila/icons/inpost/inpost_noszone.dmi'
	icon_state = "qm_envirosuit"

/datum/outfit/plasmaman/cargo_technician/quartermaster
	name = "Quartermaster Plasmaman"
	uniform = /obj/item/clothing/under/plasmaman/cargo/quartermaster

/datum/job/quartermaster
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/cargo_technician/quartermaster
	)

/****************************\
|*********** nazwy ***********|
\****************************/
/obj/item/clothing/under/rank/cargo/tech
	name = "kombinezon magazyniera InPostu"
	desc = "Żółty kombinezon roboczy InPostu z szortami. Wygodny i łatwo się go nosi!"

/obj/item/clothing/under/rank/cargo/quartermaster
	name = "kombinezon kwatermistrza InPostu"

/obj/item/clothing/under/rank/cargo/quartermaster/turtleneck
	name = "golf kwatermistrza InPostu"
	can_adjust = TRUE // arkusz InPostu ma wersję zwiniętą golfu (qmturtle_d)

/obj/item/clothing/under/rank/cargo/miner
	name = "kombinezon górnika InPostu"

/obj/item/clothing/under/rank/cargo/miner/lavaland
	name = "kombinezon górnika InPostu"
	desc = "Żółty mundur InPostu do pracy w niebezpiecznym środowisku."

/obj/item/clothing/under/plasmaman/cargo
	name = "kombinezon środowiskowy InPostu"

/obj/item/clothing/under/plasmaman/mining
	name = "górniczy kombinezon środowiskowy InPostu"
	desc = "Hermetyczny żółty kombinezon InPostu dla plazmoludzi pracujących w kopalni."

/obj/item/clothing/head/soft/cargo
	name = "czapka InPostu"
	desc = "Żółta czapka z daszkiem z logo InPostu."

/obj/item/clothing/head/beret/supply
	name = "beret InPostu"
	desc = "Żółty beret z insygniami InPostu. Nie możesz przestać się zastanawiać, za ile dałoby się go sprzedać."

/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "kurtka zimowa InPostu"

/obj/item/storage/backpack/explorer
	name = "plecak górniczy InPostu"

/obj/structure/closet/wardrobe/cargotech
	name = "szafa na ubrania InPostu"
