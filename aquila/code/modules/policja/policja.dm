// AQUILA - dział ochrony w barwach Polskiej Policji (Kosmobagiety, grafika: Ewa).
// Grafika z arkusza artystki w aquila/icons/policja/, a to, czego arkusz nie ma (śluzy, tablety, ubrania brig physiciana),
// przemalowane z czerwieni na granat mundurów. Wspólnych arkuszy tg nie ruszamy: typy ochrony dostają tu własne pliki.

/****************************\
|********** szafki ***********|
\****************************/
/// Stany closet.dmi, które w aquila/icons/policja/closet.dmi mają policyjną grafikę (plik jest pełną kopią, więc nakładki zostają)
GLOBAL_LIST_INIT(policja_closet_states, list("sec", "warden", "hos", "armory", "tac", "shotguncase", "bio_sec"))

// Łapie też szafki z varedytem icon_state na mapach i spawnowane przez adminów
/obj/structure/closet/Initialize(mapload)
	if(icon == 'icons/obj/closet.dmi' && (icon_state in GLOB.policja_closet_states))
		icon = 'aquila/icons/policja/closet.dmi'
	return ..()

// Typy z policyjną grafiką od razu, żeby edytor map i webmapa też je tak pokazywały
/obj/structure/closet/secure_closet/security
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/closet/secure_closet/warden
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/closet/secure_closet/hos
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/closet/secure_closet/ertSec
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/closet/secure_closet/armory1
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/closet/secure_closet/armory2
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/closet/secure_closet/armory3
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/closet/secure_closet/tac
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/closet/secure_closet/lethalshots
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/closet/l3closet/security
	icon = 'aquila/icons/policja/closet.dmi'

/obj/structure/guncase
	icon = 'aquila/icons/policja/closet.dmi'

/****************************\
|********** SecDrobe *********|
\****************************/
/obj/machinery/vending/wardrobe/sec_wardrobe
	icon = 'aquila/icons/policja/vending.dmi'
	product_ads = "Bij opryszków ze stylem!;Granat nie zdradzi, że to ty!;Masz prawo do bycia modnym!;Teraz możesz być tak modnym policjantem, jak zawsze chciałeś!"
	light_color = LIGHT_COLOR_BLUE

/****************************\
|******* ubrania i rzeczy ****|
\****************************/
// Brig physician: te same ubrania, czerwień zamieniona na granat
/obj/item/clothing/head/soft/sec/brig_physician
	icon = 'aquila/icons/policja/przedmioty.dmi'
	worn_icon = 'aquila/icons/policja/przedmioty_noszone.dmi'

/obj/item/clothing/suit/toggle/labcoat/brig_physician
	icon = 'aquila/icons/policja/przedmioty.dmi'
	worn_icon = 'aquila/icons/policja/przedmioty_noszone.dmi'

/obj/item/clothing/suit/hazardvest/brig_physician
	icon = 'aquila/icons/policja/przedmioty.dmi'
	worn_icon = 'aquila/icons/policja/przedmioty_noszone.dmi'

/obj/item/clothing/under/rank/brig_physician
	icon = 'aquila/icons/policja/przedmioty.dmi'
	worn_icon = 'aquila/icons/policja/przedmioty_noszone.dmi'

/obj/item/clothing/under/plasmaman/security/secmed
	icon = 'aquila/icons/policja/przedmioty.dmi'
	worn_icon = 'aquila/icons/policja/przedmioty_noszone.dmi'

// Aspirant: mundur policyjny zamiast mallcopa, statystyki bez zmian
/obj/item/clothing/under/rank/security/officer/mallcop/deputy
	icon_state = "security"
	item_state = "r_suit"

// Opaska Aspiranta w granacie (nakładka na mundurze w nsv13/icons/mob/accessories.dmi)
/obj/item/clothing/accessory/armband/deputy
	icon = 'aquila/icons/policja/przedmioty.dmi'
	icon_state = "policeband"

/obj/item/bedsheet/hos
	icon = 'aquila/icons/policja/przedmioty.dmi'
	worn_icon = 'aquila/icons/policja/przedmioty_noszone.dmi'

/obj/item/bedsheet/double/hos
	icon = 'aquila/icons/policja/przedmioty.dmi'

/****************************\
|********** podłogi **********|
\****************************/
#define POLICJA_DECAL_COLOR "#4B5BB4"

/obj/effect/turf_decal/tile/ship/police
	name = "policyjny narożnik"
	color = POLICJA_DECAL_COLOR

/obj/effect/turf_decal/tile/ship/half/police
	name = "policyjna połówka"
	color = POLICJA_DECAL_COLOR

/obj/effect/turf_decal/tile/ship/full/police
	name = "policyjne pole"
	color = POLICJA_DECAL_COLOR

/obj/effect/turf_decal/trimline/police
	color = POLICJA_DECAL_COLOR

/obj/effect/turf_decal/trimline/police/line
	icon_state = "trimline"

#undef POLICJA_DECAL_COLOR

/turf/open/floor/carpet/police
	name = "dywan policyjny"
	icon = 'aquila/icons/policja/carpet_police.dmi'
	icon_state = "carpet_police-255"
	base_icon_state = "carpet_police"
	floor_tile = /obj/item/stack/tile/carpet/police
	carpet_connect_type = /turf/open/floor/carpet/police

/obj/item/stack/tile/carpet/police
	name = "dywan policyjny"
	icon = 'aquila/icons/policja/przedmioty.dmi'
	icon_state = "tile-carpet-police"
	item_state = "tile-carpet-royalblue"
	merge_type = /obj/item/stack/tile/carpet/police
	turf_type = /turf/open/floor/carpet/police
	tableVariant = /obj/structure/table/wood/fancy/royalblue

/obj/item/stack/tile/carpet/police/fifty
	amount = 50

/****************************\
|***** zmiana nazwy roli *****|
\****************************/
/// Stary tytuł => nowy. Preferencje, czas gry i bany w bazie są zapisane po tytule roli, więc stare wpisy przenosimy przy odczycie.
GLOBAL_LIST_INIT(renamed_job_titles, list("Żandarm" = JOB_NAME_SECURITYOFFICER))

/// Przenosi wpisy starych tytułów na nowe. sum_values sumuje (czas gry), inaczej nowy wpis wygrywa (priorytet w preferencjach).
/proc/migrate_renamed_job_titles(list/entries, sum_values = FALSE)
	if(!islist(entries))
		return
	for(var/old_title in GLOB.renamed_job_titles)
		if(!(old_title in entries))
			continue
		var/new_title = GLOB.renamed_job_titles[old_title]
		if(sum_values)
			entries[new_title] = text2num(entries[new_title]) + text2num(entries[old_title])
		else if(!entries[new_title])
			entries[new_title] = entries[old_title]
		entries -= old_title

/// Ban na stary tytuł obowiązuje też na nowy
/proc/add_renamed_job_titles(roles)
	var/list/result = list()
	result += roles
	for(var/old_title in GLOB.renamed_job_titles)
		if((GLOB.renamed_job_titles[old_title] in result) && !(old_title in result))
			result += old_title
	return result

/****************************\
|*********** nazwy ***********|
\****************************/
// Ubrania i sprzęt ochrony nazwane po policyjnemu, w tym samym języku co dotąd (ubrania tg są po angielsku)
/obj/item/clothing/under/ship/military_police
	name = "mundur policyjny"
	desc = "Wytrzymały mundur noszony przez policjantów, którzy egzekwują prawo na statku."

/obj/item/clothing/suit/ship/squad/military_police
	name = "pancerz policyjny"
	desc = "Solidny zestaw napierśnika i nagolenników, który oznacza, że nosi go policjant. W przeciwieństwie do zwykłej kamizelki chroni też nogi."

/obj/item/clothing/under/rank/security/officer
	name = "mundur policyjny"

/obj/item/clothing/under/rank/security/officer/white
	name = "służbowy mundur policyjny"

/obj/item/clothing/under/rank/security/officer/formal
	name = "galowy mundur policjanta"

/obj/item/clothing/under/rank/security/officer/mallcop/deputy
	name = "mundur Aspiranta"

/obj/item/clothing/under/rank/security/head_of_security
	name = "mundur Komendanta"

/obj/item/clothing/under/rank/security/head_of_security/alt
	name = "golf Komendanta"

/obj/item/clothing/under/rank/security/head_of_security/formal
	name = "galowy mundur Komendanta"

/obj/item/clothing/under/rank/security/warden
	name = "mundur Naczelnika"

/obj/item/clothing/under/rank/security/warden/white
	name = "służbowy mundur Naczelnika"

/obj/item/clothing/suit/security/officer
	name = "kurtka policjanta"

/obj/item/clothing/suit/security/hos
	name = "kurtka Komendanta"

/obj/item/clothing/suit/ship/peacekeeper/jacket/police
	name = "opancerzona kurtka Komendanta"

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "policyjna kurtka zimowa"

/obj/item/clothing/suit/toggle/labcoat/brig_physician
	name = "fartuch Lekarza Więziennego"

/obj/item/clothing/neck/cloak/hos
	name = "płaszcz Komendanta"

/obj/item/clothing/head/HoS
	name = "czapka Komendanta"

/obj/item/clothing/head/HoS/beret
	name = "beret Komendanta"

/obj/item/clothing/head/beret/sec/navyhos
	name = "galowy beret Komendanta"

/obj/item/clothing/head/beret/sec
	name = "beret policyjny"

/obj/item/clothing/head/beret/sec/bandana
	name = "bandana policyjna"

/obj/item/clothing/head/beret/sec/garrison
	name = "furażerka policyjna"

/obj/item/clothing/head/beret/sec/officercap
	name = "czapka policjanta"

/obj/item/clothing/head/soft/sec
	name = "czapka policyjna"

/obj/item/clothing/head/soft/sec/alt
	name = "alternatywna czapka policyjna"

/obj/item/clothing/head/soft/sec/brig_physician
	name = "czapka Lekarza Więziennego"

/obj/item/clothing/mask/gas/sechailer
	name = "policyjna maska gazowa"

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "policyjna maska z megafonem"

/obj/item/clothing/glasses/hud/security
	name = "HUD policyjny"

/obj/item/clothing/glasses/hud/security/deputy
	name = "HUD policyjny Aspiranta"

/obj/item/clothing/glasses/hud/security/night
	name = "HUD policyjny z noktowizją"

/obj/item/clothing/glasses/hud/security/prescription
	name = "korekcyjne okulary z HUD-em policyjnym"

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "okulary przeciwsłoneczne z HUD-em policyjnym"

/obj/item/clothing/glasses/hud/security/sunglasses/degraded
	name = "zużyte okulary przeciwsłoneczne z HUD-em policyjnym"

/obj/item/clothing/accessory/armband/deputy
	name = "opaska Aspiranta"

/obj/item/clothing/accessory/medal/silver/security
	name = "odznaczenie za solidną służbę w policji"

/obj/item/storage/belt/security
	name = "pas policyjny"

/obj/item/storage/belt/security/deputy
	name = "pas policyjny Aspiranta"

/obj/item/storage/belt/security/webbing
	name = "oporządzenie policyjne"

/obj/item/storage/backpack/security
	name = "plecak policyjny"

/obj/item/storage/backpack/satchel/sec
	name = "policyjna torba na ramię"

/obj/item/storage/backpack/duffelbag/sec
	name = "policyjna torba podróżna"
