// AQUILA - dział ochrony w barwach Żandarmerii (wcześniej Polskiej Policji z arkusza Kosmobagiet).
// Mundury, szafki i SecDrobe z arkusza zandarmeria.dmi. To, czego arkusz nie ma (śluzy, tablety, ubrania brig physiciana,
// dywan, dekale), przemalowane na zieleń mundurów. Folder i ścieżki typów zostały po Policji, żeby nie ruszać map.

/****************************\
|********** szafki ***********|
\****************************/
/// Stany closet.dmi, które w aquila/icons/policja/closet.dmi mają grafikę Żandarmerii (plik jest pełną kopią, więc nakładki zostają)
GLOBAL_LIST_INIT(zandarmeria_closet_states, list("sec", "warden", "hos", "armory", "tac", "shotguncase", "bio_sec"))

// Łapie też szafki z varedytem icon_state na mapach i spawnowane przez adminów
/obj/structure/closet/Initialize(mapload)
	if(icon == 'icons/obj/closet.dmi' && (icon_state in GLOB.zandarmeria_closet_states))
		icon = 'aquila/icons/policja/closet.dmi'
	return ..()

// Typy z żandarmską grafiką od razu, żeby edytor map i webmapa też je tak pokazywały
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
	product_ads = "Bij opryszków ze stylem!;Zieleń nie zdradzi, że to ty!;Masz prawo do bycia modnym!;Teraz możesz być tak modnym żandarmem, jak zawsze chciałeś!"
	light_color = LIGHT_COLOR_GREEN

/****************************\
|******* ubrania i rzeczy ****|
\****************************/
// Brig physician: te same ubrania, czerwień zamieniona na zieleń Żandarmerii
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

// Aspirant: mundur żandarmski zamiast mallcopa, statystyki bez zmian
/obj/item/clothing/under/rank/security/officer/mallcop/deputy
	icon_state = "security"
	item_state = "r_suit"

// Opaska Aspiranta w zieleni (nakładka na mundurze w nsv13/icons/mob/accessories.dmi)
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
#define ZANDARMERIA_DECAL_COLOR "#4F8A5B"

/obj/effect/turf_decal/tile/ship/police
	name = "żandarmski narożnik"
	color = ZANDARMERIA_DECAL_COLOR

/obj/effect/turf_decal/tile/ship/half/police
	name = "żandarmska połówka"
	color = ZANDARMERIA_DECAL_COLOR

/obj/effect/turf_decal/tile/ship/full/police
	name = "żandarmskie pole"
	color = ZANDARMERIA_DECAL_COLOR

/obj/effect/turf_decal/trimline/police
	color = ZANDARMERIA_DECAL_COLOR

/obj/effect/turf_decal/trimline/police/line
	icon_state = "trimline"

#undef ZANDARMERIA_DECAL_COLOR

/****************************\
|***** hełmy plazmoludzi *****|
\****************************/
// Kolory greyscale (podstawa, pas, środkowy pasek) w zieleni Żandarmerii z bordowym akcentem, jak kombinezony środowiskowe
/obj/item/clothing/head/helmet/space/plasmaman/security
	greyscale_colors = "#2B4432#2D2D2D#460109"

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	greyscale_colors = "#2B4432#C0C0C0#460109"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	greyscale_colors = "#2B4432#C7B83C#213325"

/obj/item/clothing/head/helmet/space/plasmaman/security/secmed
	greyscale_colors = "#A5A9B6#2B4432#A5A9B6"

/turf/open/floor/carpet/police
	name = "dywan żandarmski"
	icon = 'aquila/icons/policja/carpet_police.dmi'
	icon_state = "carpet_police-255"
	base_icon_state = "carpet_police"
	floor_tile = /obj/item/stack/tile/carpet/police
	carpet_connect_type = /turf/open/floor/carpet/police

/obj/item/stack/tile/carpet/police
	name = "dywan żandarmski"
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
GLOBAL_LIST_INIT(renamed_job_titles, list("Policjant" = JOB_NAME_SECURITYOFFICER))

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
// Ubrania i sprzęt ochrony nazwane po żandarmskiemu, w tym samym języku co dotąd (ubrania tg są po angielsku)
/obj/item/clothing/under/ship/military_police
	name = "mundur żandarmski"
	desc = "Wytrzymały mundur noszony przez żandarmów, którzy egzekwują prawo na statku."

/obj/item/clothing/suit/ship/squad/military_police
	name = "pancerz żandarmski"
	desc = "Solidny zestaw napierśnika i nagolenników, który oznacza, że nosi go żandarm. W przeciwieństwie do zwykłej kamizelki chroni też nogi."

/obj/item/clothing/under/rank/security/officer
	name = "mundur żandarmski"

/obj/item/clothing/under/rank/security/officer/white
	name = "służbowy mundur żandarmski"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/officer/formal
	name = "galowy mundur żandarma"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/officer/mallcop/deputy
	name = "mundur Aspiranta"

/obj/item/clothing/under/rank/security/head_of_security
	name = "mundur Komendanta"

/obj/item/clothing/under/rank/security/head_of_security/alt
	name = "golf Komendanta"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/head_of_security/formal
	name = "galowy mundur Komendanta"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/warden
	name = "mundur Naczelnika"

/obj/item/clothing/under/rank/security/warden/white
	name = "służbowy mundur Naczelnika"
	can_adjust = FALSE

// Arkusz rysuje wersje zwinięte tylko dla zwykłych mundurów Żandarma, Naczelnika i Komendanta (_alt), służbowe i galowe ich nie mają
/obj/item/clothing/under/rank/security/head_of_security/white
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/warden/formal
	can_adjust = FALSE

/obj/item/clothing/suit/security/officer
	name = "kurtka żandarma"

/obj/item/clothing/suit/security/hos
	name = "kurtka Komendanta"

/obj/item/clothing/suit/ship/peacekeeper/jacket/police
	name = "opancerzona kurtka Komendanta"

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "żandarmska kurtka zimowa"

/obj/item/clothing/suit/toggle/labcoat/brig_physician
	name = "fartuch Lekarza Więziennego"

/obj/item/clothing/neck/cloak/hos
	name = "płaszcz Komendanta"

/obj/item/clothing/head/HoS
	name = "czapka Komendanta"

/obj/item/clothing/head/HoS/beret
	name = "beret Komendanta"

/obj/item/clothing/head/beret/sec/navyhos
	name = "beret oficerski Komendanta"

/obj/item/clothing/head/beret/sec/navywarden
	name = "beret oficerski Naczelnika"

// Bez własnej nazwy dziedziczył „beret żandarmski” i w SecDrobe były dwa przedmioty o tej samej nazwie
/obj/item/clothing/head/beret/sec/navyofficer
	name = "beret oficerski Żandarma"

/obj/item/clothing/head/beret/sec
	name = "beret żandarmski"

/obj/item/clothing/head/beret/sec/bandana
	name = "bandana żandarmska"

/obj/item/clothing/head/beret/sec/garrison
	name = "furażerka żandarmska"

/obj/item/clothing/head/beret/sec/officercap
	name = "czapka żandarma"

/obj/item/clothing/head/soft/sec
	name = "czapka żandarmska"

/obj/item/clothing/head/soft/sec/alt
	name = "alternatywna czapka żandarmska"

/obj/item/clothing/head/soft/sec/brig_physician
	name = "czapka Lekarza Więziennego"

/obj/item/clothing/mask/gas/sechailer
	name = "żandarmska maska gazowa"

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "żandarmska maska z megafonem"

/obj/item/clothing/glasses/hud/security
	name = "HUD żandarmski"

/obj/item/clothing/glasses/hud/security/deputy
	name = "HUD żandarmski Aspiranta"

/obj/item/clothing/glasses/hud/security/night
	name = "HUD żandarmski z noktowizją"

/obj/item/clothing/glasses/hud/security/prescription
	name = "korekcyjne okulary z HUD-em żandarmskim"

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "okulary przeciwsłoneczne z HUD-em żandarmskim"

/obj/item/clothing/glasses/hud/security/sunglasses/degraded
	name = "zużyte okulary przeciwsłoneczne z HUD-em żandarmskim"

/obj/item/clothing/accessory/armband/deputy
	name = "opaska Aspiranta"

/obj/item/clothing/accessory/medal/silver/security
	name = "odznaczenie za solidną służbę w Żandarmerii"

/obj/item/storage/belt/security
	name = "pas żandarmski"

/obj/item/storage/belt/security/deputy
	name = "pas żandarmski Aspiranta"

/obj/item/storage/belt/security/webbing
	name = "oporządzenie żandarmskie"

/obj/item/storage/backpack/security
	name = "plecak żandarmski"

/obj/item/storage/backpack/satchel/sec
	name = "żandarmska torba na ramię"

/obj/item/storage/backpack/duffelbag/sec
	name = "żandarmska torba podróżna"
