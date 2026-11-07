// AQUILA - dział inżynierii w barwach Orlenu (czerwień i biel).
// Mundury, kaski, szafki, EngiDrobe/AtmosDrobe, tablety i karty z arkusza orlentekstury.dmi wpisane w miejsce stanów inżynierii,
// a to, czego arkusz nie ma (drzwi specjalnych szafek, kombinezon ostrzegawczy, opaska, tabliczki), przemalowane z żółci na czerwień.
// Śluzy inżynierii (z ramami w budowie) są biało-czerwone, atmosferyki czerwone (aquila/icons/paradise/obj/doors). Profesje i kanał radia nazywają się jak dotąd, Orlen jest tylko w nazwach rzeczy.

/****************************\
|********** dekale ***********|
\****************************/
// Żółte dekale w obszarach inżynierii na mapach są podmienione na te podtypy (te same kształty).
// Narożniki tg i linie są czerwone, a połówki, boki, pełne pola i narożniki NSV białe, żeby podłoga była czerwono-biała.
// Narożnik NSV to ćwiartka kafelka, więc czerwony wyglądał na kratownicy jak losowo rozrzucone czerwone kwadraty.
#define ORLEN_DECAL_COLOR "#D8232A"
#define ORLEN_DECAL_WHITE "#E6E6E6"

/obj/effect/turf_decal/tile/yellow/orlen
	name = "narożnik Orlenu"
	color = ORLEN_DECAL_COLOR

/obj/effect/turf_decal/tile/yellow/tile_side/orlen
	name = "biały bok Orlenu"
	color = ORLEN_DECAL_WHITE

/obj/effect/turf_decal/tile/ship/yellow/orlen
	name = "biały narożnik Orlenu"
	color = ORLEN_DECAL_WHITE

/obj/effect/turf_decal/tile/ship/half/yellow/orlen
	name = "biała połówka Orlenu"
	color = ORLEN_DECAL_WHITE

/obj/effect/turf_decal/tile/ship/full/yellow/orlen
	name = "białe pole Orlenu"
	color = ORLEN_DECAL_WHITE

/obj/effect/turf_decal/trimline/yellow/line/orlen
	color = ORLEN_DECAL_COLOR

// Niebieskie pasy w atmosferyce: biel do czerwieni, żeby strefa była czerwono-biała
/obj/effect/turf_decal/tile/ship/blue/orlen
	name = "biały narożnik Orlenu"
	color = ORLEN_DECAL_WHITE

#undef ORLEN_DECAL_COLOR
#undef ORLEN_DECAL_WHITE

/****************************\
|***** hełmy plazmoludzi *****|
\****************************/
// Kolory greyscale (podstawa, pas, środkowy pasek) dobrane do kombinezonów środowiskowych z arkusza
/obj/item/clothing/head/helmet/space/plasmaman/engineering
	greyscale_colors = "#CBCDD1#B3252A#CBCDD1"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/atmospherics
	greyscale_colors = "#B3252A#CBCDD1#B3252A"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	greyscale_colors = "#EEEEEE#B3252A#17171F"

/****************************\
|******* czapki z daszkiem ***|
\****************************/
// Nowe z arkusza. Stany "[soft_color]soft" i "[soft_color]soft_flipped" w aquila/icons/obj/clothing/hats.dmi i aquila/icons/mob/head.dmi.
/obj/item/clothing/head/soft/orlen
	name = "czapka Orlenu"
	desc = "Biała czapka z daszkiem z czerwonym logo Orlenu."
	icon = 'aquila/icons/obj/clothing/hats.dmi'
	worn_icon = 'aquila/icons/mob/head.dmi'
	icon_state = "orlensoft"
	soft_color = "orlen"

/obj/item/clothing/head/soft/orlen/atmos
	name = "czerwona czapka Orlenu"
	desc = "Czerwona czapka z daszkiem z białym logo Orlenu, noszona przez techników atmosferyki."
	icon_state = "orlenatmossoft"
	soft_color = "orlenatmos"

/obj/item/clothing/head/soft/orlen/highvis
	name = "odblaskowa czapka Orlenu"
	desc = "Jaskrawa czapka z daszkiem Orlenu. Widać ją z drugiego końca maszynowni."
	icon_state = "orlenhighvissoft"
	soft_color = "orlenhighvis"

/****************************\
|*********** nazwy ***********|
\****************************/
/obj/item/clothing/under/ship/engineer
	name = "kombinezon inżyniera Orlenu"
	desc = "Biały kombinezon roboczy z czerwonymi wstawkami i logo Orlenu. Rzadko widuje się taki, który nie jest pokryty warstwami smaru silnikowego."

/obj/item/clothing/under/rank/engineering/engineer
	name = "kombinezon inżyniera Orlenu"
	desc = "Biały kombinezon roboczy Orlenu z czerwonymi wstawkami. Ma słabą osłonę przed promieniowaniem."

/obj/item/clothing/under/rank/engineering/atmospheric_technician
	name = "kombinezon technika atmosferyki Orlenu"
	desc = "Czerwony kombinezon roboczy Orlenu noszony przez techników atmosferyki."

/obj/item/clothing/under/rank/engineering/chief_engineer
	name = "kombinezon głównego inżyniera Orlenu"
	desc = "Biało-czarny kombinezon kierownika z logo Orlenu. Ma słabą osłonę przed promieniowaniem."

/obj/item/clothing/under/rank/engineering/engineer/hazard
	name = "ostrzegawczy kombinezon Orlenu"

/obj/item/clothing/under/plasmaman/engineering
	name = "kombinezon środowiskowy Orlenu"

/obj/item/clothing/under/plasmaman/engineering/atmospherics
	name = "kombinezon środowiskowy atmosferyki Orlenu"

/obj/item/clothing/head/hardhat
	name = "kask Orlenu"

// Pomarańczowy i granatowy kask nie są w barwach Orlenu, więc zostają przy starej nazwie
/obj/item/clothing/head/hardhat/orange
	name = "kask"

/obj/item/clothing/head/hardhat/dblue
	name = "kask"

// Hełm strażacki atmosferyki ma tę samą grafikę z maską gazową co hełm strażaka z arkusza (pasuje do kombinezonu przeciwpożarowego)
/obj/item/clothing/head/hardhat/atmos
	name = "hełm strażacki atmosferyki Orlenu"
	desc = "Hełm strażacki technika atmosferyki z maską gazową. Pozwala zachować chłodną głowę nawet przy pożarze."

/obj/item/clothing/head/hardhat/white
	name = "biały kask Orlenu"
	desc = "Biały kask z czerwonym pasem Orlenu. Pewnie należy do Głównego Inżyniera. Wygląda na trochę solidniejszy."

/obj/item/clothing/head/beret/eng
	name = "beret Orlenu"

/obj/item/clothing/head/beret/ship/engineer
	name = "beret inżyniera Orlenu"

/obj/item/clothing/head/beret/atmos
	name = "beret atmosferyki Orlenu"

/obj/item/clothing/head/beret/ce
	name = "beret głównego inżyniera Orlenu"
	desc = "Biały beret z insygniami Orlenu. Jego właściciel wie, co robi. Chyba."

/obj/item/clothing/suit/hazardvest
	name = "kamizelka odblaskowa Orlenu"

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "kurtka zimowa Orlenu"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "kurtka zimowa atmosferyki Orlenu"

/obj/item/clothing/neck/cloak/ce
	name = "peleryna Głównego Inżyniera Orlenu"

/obj/item/storage/backpack/industrial
	name = "plecak Orlenu"

/obj/item/storage/backpack/satchel/eng
	name = "torba na ramię Orlenu"

/obj/item/storage/backpack/duffelbag/engineering
	name = "torba podróżna Orlenu"

/obj/structure/closet/secure_closet/engineering_personal
	name = "szafka inżyniera Orlenu"
