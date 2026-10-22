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
	name = "police corner"
	color = POLICJA_DECAL_COLOR

/obj/effect/turf_decal/tile/ship/half/police
	name = "police half"
	color = POLICJA_DECAL_COLOR

/obj/effect/turf_decal/tile/ship/full/police
	name = "police full"
	color = POLICJA_DECAL_COLOR

/obj/effect/turf_decal/trimline/police
	color = POLICJA_DECAL_COLOR

/obj/effect/turf_decal/trimline/police/line
	icon_state = "trimline"

#undef POLICJA_DECAL_COLOR

/turf/open/floor/carpet/police
	name = "police carpet"
	icon = 'aquila/icons/policja/carpet_police.dmi'
	icon_state = "carpet_police-255"
	base_icon_state = "carpet_police"
	floor_tile = /obj/item/stack/tile/carpet/police
	carpet_connect_type = /turf/open/floor/carpet/police

/obj/item/stack/tile/carpet/police
	name = "police carpet"
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
	name = "police uniform"
	desc = "A durable uniform worn by police officers, who enforce ship-law."

/obj/item/clothing/suit/ship/squad/military_police
	name = "police armour"
	desc = "A heavy-duty chestplate and shinpad combo which denotes that the user is a police officer. Protects legs unlike a normal vest."

/obj/item/clothing/under/rank/security/officer
	name = "police uniform"

/obj/item/clothing/under/rank/security/officer/white
	name = "police service uniform"

/obj/item/clothing/under/rank/security/officer/formal
	name = "police officer's formal uniform"

/obj/item/clothing/under/rank/security/officer/mallcop/deputy
	name = "police deputy uniform"

/obj/item/clothing/under/rank/security/head_of_security
	name = "police commander's uniform"

/obj/item/clothing/under/rank/security/head_of_security/alt
	name = "police commander's turtleneck"

/obj/item/clothing/under/rank/security/head_of_security/formal
	name = "police commander's formal uniform"

/obj/item/clothing/under/rank/security/warden
	name = "warden's uniform"

/obj/item/clothing/under/rank/security/warden/white
	name = "warden's service uniform"

/obj/item/clothing/suit/security/officer
	name = "police officer's jacket"

/obj/item/clothing/suit/security/hos
	name = "police commander's jacket"

/obj/item/clothing/suit/ship/peacekeeper/jacket/police
	name = "police commander's armored jacket"

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "police winter coat"

/obj/item/clothing/suit/toggle/labcoat/brig_physician
	name = "police medic's labcoat"

/obj/item/clothing/neck/cloak/hos
	name = "police commander's cloak"

/obj/item/clothing/head/HoS
	name = "police commander's cap"

/obj/item/clothing/head/HoS/beret
	name = "police commander's beret"

/obj/item/clothing/head/beret/sec/navyhos
	name = "police commander's formal beret"

/obj/item/clothing/head/beret/sec
	name = "police beret"

/obj/item/clothing/head/beret/sec/bandana
	name = "police bandana"

/obj/item/clothing/head/beret/sec/garrison
	name = "police garrison cap"

/obj/item/clothing/head/beret/sec/officercap
	name = "police officer's cap"

/obj/item/clothing/head/soft/sec
	name = "police cap"

/obj/item/clothing/head/soft/sec/alt
	name = "alternative police cap"

/obj/item/clothing/head/soft/sec/brig_physician
	name = "police medic cap"

/obj/item/clothing/mask/gas/sechailer
	name = "police gas mask"

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "police hailer"

/obj/item/clothing/glasses/hud/security
	name = "police HUD"

/obj/item/clothing/glasses/hud/security/deputy
	name = "deputy police HUD"

/obj/item/clothing/glasses/hud/security/night
	name = "night vision police HUD"

/obj/item/clothing/glasses/hud/security/prescription
	name = "prescription police HUD glasses"

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "police HUD sunglasses"

/obj/item/clothing/glasses/hud/security/sunglasses/degraded
	name = "degraded police HUD sunglasses"

/obj/item/clothing/accessory/armband/deputy
	name = "police deputy armband"

/obj/item/clothing/accessory/medal/silver/security
	name = "robust police award"

/obj/item/storage/belt/security
	name = "police belt"

/obj/item/storage/belt/security/deputy
	name = "deputy police belt"

/obj/item/storage/belt/security/webbing
	name = "police webbing"

/obj/item/storage/backpack/security
	name = "plecak policyjny"

/obj/item/storage/backpack/satchel/sec
	name = "police satchel"

/obj/item/storage/backpack/duffelbag/sec
	name = "police duffel bag"
