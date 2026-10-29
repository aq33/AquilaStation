/datum/supply_pack
	var/name = "Skrzynia"
	var/group = ""
	var/hidden = FALSE
	var/contraband = FALSE
	var/cost = 400 // Minimum cost, or infinite points are possible. I've already had to fix it once because someone didn't listen. Don't be THAT person.
	var/access = FALSE
	var/access_budget = FALSE //prevents people from requesting stupid stuff with their department's budget via app
	var/access_any = FALSE
	var/list/contains = null
	var/crate_name = "skrzynia"
	var/desc = ""//no desc by default
	var/crate_type = /obj/structure/closet/crate
	var/dangerous = FALSE // Should we message admins?
	var/special = FALSE //Event/Station Goals/Admin enabled packs
	var/special_enabled = FALSE
	var/DropPodOnly = FALSE//only usable by the Bluespace Drop Pod via the express cargo console
	var/admin_spawned = FALSE
	var/small_item = FALSE //Small items can be grouped into a single crate.
	var/can_secure = TRUE //Can this order be secured (aquila, xenoarch z Bee)
	///Limit zapasu - używane tylko przez listingi xenoarch z Bee
	var/current_supply
	var/max_supply = 5

/datum/supply_pack/proc/generate(atom/A, datum/bank_account/paying_account)
	var/obj/structure/closet/crate/C
	if(paying_account && can_secure)
		C = new /obj/structure/closet/crate/secure/owned(A, paying_account)
		C.name = "[crate_name] – kupujący: [paying_account.account_holder]"
	else
		C = new crate_type(A)
		C.name = crate_name
	if(access)
		C.req_access = list(access)
	if(access_any)
		C.req_one_access = access_any

	fill(C)
	return C

/datum/supply_pack/proc/get_cost()
	. = cost
	if(HAS_TRAIT(SSstation, STATION_TRAIT_DISTANT_SUPPLY_LINES))
		. *= 1.2
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_STRONG_SUPPLY_LINES))
		. *= 0.8

/datum/supply_pack/proc/fill(obj/structure/closet/crate/C)
	if (admin_spawned)
		for(var/item in contains)
			var/atom/A = new item(C)
			A.flags_1 |= ADMIN_SPAWNED_1
	else
		for(var/item in contains)
			if(ispath(item))
				new item(C)
			else if(ismovable(item))
				var/atom/movable/MA = item
				MA.forceMove(C)

// AQUILA EDIT START - zawartość paczki i ikona dla okna Cargo z tg
/// Lista zawartości paczki do okna (nazwa, ikona, ilość), te same typy zliczone razem
/datum/supply_pack/proc/get_contents_ui_data()
	var/list/counts = list()
	for(var/item in contains)
		if(!ispath(item, /atom))
			continue
		counts[item] += isnum(contains[item]) ? contains[item] : 1
	var/list/data = list()
	for(var/item in counts)
		var/atom/thing = item
		data += list(list(
			"name" = initial(thing.name),
			"icon" = initial(thing.greyscale_config) ? null : initial(thing.icon),
			"icon_state" = initial(thing.greyscale_config) ? null : initial(thing.icon_state),
			"amount" = counts[item],
		))
	return data

/// Dane paczki wysyłane do okna Cargo
/datum/supply_pack/proc/get_ui_data(pack_id)
	var/atom/first_item = length(contains) ? contains[1] : null
	var/has_icon = ispath(first_item, /atom) && !initial(first_item.greyscale_config)
	return list(
		"name" = name,
		"cost" = get_cost(),
		"id" = pack_id,
		"desc" = desc || name, // If there is a description, use it. Otherwise use the pack's name.
		"small_item" = small_item,
		"access" = access,
		"contraband" = contraband,
		"first_item_icon" = has_icon ? initial(first_item.icon) : null,
		"first_item_icon_state" = has_icon ? initial(first_item.icon_state) : null,
		"contains" = get_contents_ui_data(),
	)
// AQUILA EDIT END

// If you add something to this list, please group it by type and sort it alphabetically instead of just jamming it in like an animal

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Emergency ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/emergency
	group = "Emergency"

/datum/supply_pack/emergency/vehicle
	name = "Zestaw gangu motocyklowego" //TUNNEL SNAKES OWN THIS TOWN
	desc = "TUNELOWE WĘŻE RZĄDZĄ TYM MIASTEM. Zawiera quada bez logo i kompletny strój gangu: czarne rękawiczki, groźną bandanę z czaszką i ZAJEFAJNY skórzany płaszcz!"
	cost = 1500
	contraband = TRUE
	contains = list(/obj/vehicle/ridden/atv,
					/obj/item/key,
					/obj/item/clothing/suit/jacket/leather/overcoat,
					/obj/item/clothing/gloves/color/black,
					/obj/item/clothing/head/soft/cargo,
					/obj/item/clothing/mask/bandana/skull)//so you can properly #cargoniabikergang
	crate_name = "zestaw motocyklisty"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/emergency/bio
	name = "Skrzynia ratunkowa – zagrożenie biologiczne"
	desc = "Ta skrzynia zawiera 2 pełne kombinezony biologiczne, które chronią przed wirusami."
	cost = 1500
	contains = list(/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/storage/bag/bio,
					/obj/item/reagent_containers/syringe/antiviral,
					/obj/item/reagent_containers/syringe/antiviral,
					/obj/item/clothing/gloves/color/latex/nitrile,
					/obj/item/clothing/gloves/color/latex/nitrile)
	crate_name = "skrzynia z kombinezonami biologicznymi"

/datum/supply_pack/emergency/equipment
	name = "Skrzynia ratunkowa – roboty i butle"
	desc = "Wybuchy cię dołują? Te zapasy na pewno załatają dziury, i w stacji, i w ludziach! Zawiera dwa floorboty, dwa mediboty, pięć masek tlenowych i pięć małych butli z tlenem."
	cost = 1500
	contains = list(/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/medbot,
					/mob/living/simple_animal/bot/medbot,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	crate_name = "skrzynia ratunkowa"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/medical
	name = "Skrzynia ratunkowa – medycyna"
	desc = "Na wypadek, gdy wszystko się sypie, a lekarze nie nadążają. Zawiera kapsułę medyczną 7x5 i 2 mediboty na nagłe wypadki."
	cost = 1100
	contains = list(/mob/living/simple_animal/bot/medbot,
					/mob/living/simple_animal/bot/medbot,
					/obj/item/survivalcapsule/medical)
	crate_name = "ratunkowa skrzynia medyczna"
	crate_type = /obj/structure/closet/crate/medical

/datum/supply_pack/emergency/bomb
	name = "Skrzynia ratunkowa – materiały wybuchowe"
	desc = "Naukowcy oszaleli? Coś pika za śluzą? Kup teraz i bądź bohaterem, na jakiego stacja zasługuje... to znaczy, jakiego potrzebuje! (czas nie wliczony)"
	cost = 800
	contains = list(/obj/item/clothing/head/bomb_hood,
					/obj/item/clothing/suit/bomb_suit,
					/obj/item/clothing/mask/gas,
					/obj/item/screwdriver,
					/obj/item/wirecutters,
					/obj/item/multitool)
	crate_name = "skrzynia z kombinezonami saperskimi"

/datum/supply_pack/emergency/firefighting //NSV13 - one less gas mask for economy
	name = "Skrzynia strażacka"
	desc = "Tylko ty możesz zapobiec pożarom na stacji. Weź do pomocy trzy kombinezony przeciwpożarowe, maski gazowe, latarki, duże butle z tlenem, gaśnice i kaski!"
	cost = 800
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/flashlight,
					/obj/item/flashlight,
					/obj/item/flashlight,
					/obj/item/flashlight,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/extinguisher/advanced,
					/obj/item/extinguisher/advanced,
					/obj/item/extinguisher/advanced,
					/obj/item/extinguisher/advanced,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red)
	crate_name = "skrzynia strażacka"

/datum/supply_pack/emergency/atmostank
	name = "Plecak gaśniczy"
	desc = "Gaś pożary pokotem dzięki temu pojemnemu plecakowi z gaśnicą."
	cost = 1000
	contains = list(/obj/item/watertank/atmos)
	crate_name = "skrzynia z plecakiem gaśniczym"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/internals //NSV13 - one gas mask, three breath masks
	name = "Skrzynia z butlami do oddychania"
	desc = "Zapanuj nad energią życiową i kontroluj oddech dzięki trzem maskom oddechowym, czterem awaryjnym butlom z tlenem i czterem dużym butlom z powietrzem."//IS THAT A
	cost = 800
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/tank/internals/emergency_oxygen,
					/obj/item/tank/internals/emergency_oxygen,
					/obj/item/tank/internals/emergency_oxygen,
					/obj/item/tank/internals/emergency_oxygen,
					/obj/item/tank/internals/emergency_oxygen,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air)
	crate_name = "skrzynia z butlami do oddychania"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/metalfoam
	name = "Skrzynia granatów z pianą metalową"
	desc = "Uszczelnij te uciążliwe wyrwy w kadłubie za pomocą 7 granatów z pianą metalową."
	cost = 700
	contains = list(/obj/item/storage/box/metalfoam)
	crate_name = "skrzynia granatów z pianą metalową"

/datum/supply_pack/emergency/plasma_spacesuit
	name = "Kombinezony środowiskowe dla plazmaludzi"
	desc = "Zawiera dwa kombinezony środowiskowe dla plazmaludzi, zdatne do wyjścia w kosmos. Zamów teraz, a dorzucimy dwa hełmy gratis! Do otwarcia wymaga dostępu EVA."
	cost = 1400 // 500 per suit, equal to normal space suits.
	contains = list(/obj/item/clothing/suit/space/eva/plasmaman,
					/obj/item/clothing/suit/space/eva/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman)
	crate_name = "skrzynia EVA dla plazmaludzi"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/plasmaman
	name = "Zestaw zaopatrzenia dla plazmaludzi"
	desc = "Utrzymaj plazmaludzi przy życiu dzięki trzem kompletom stroju plazmamana. Każdy komplet zawiera kombinezon plazmamana, butlę do oddychania i hełm."
	cost = 700 //50 credits per suit.
	contains = list(/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman)
	crate_name = "zestaw zaopatrzenia dla plazmaludzi"

/datum/supply_pack/emergency/radiation
	name = "Skrzynia ochrony przed promieniowaniem"
	desc = "Przetrwaj nuklearną apokalipsę i silnik z supermaterii dzięki dwóm kompletom kombinezonów przeciwradiacyjnych. Każdy komplet zawiera hełm, kombinezon i licznik Geigera. Dorzucimy nawet butelkę wódki i kieliszki, biorąc pod uwagę oczekiwaną długość życia osób, które to zamawiają."
	cost = 800
	contains = list(/obj/item/clothing/head/radiation,
					/obj/item/clothing/head/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/geiger_counter,
					/obj/item/geiger_counter,
					/obj/item/reagent_containers/food/drinks/bottle/vodka,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass,
					/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass)
	crate_name = "skrzynia ochrony przed promieniowaniem"
	crate_type = /obj/structure/closet/crate/radiation

/datum/supply_pack/emergency/spacesuit
	name = "Skrzynia ze skafandrem kosmicznym"
	desc = "Zawiera jeden podstarzały skafander z Kosmicznego Lumpeksu."
	cost = 900 //500 credits per 1 suit
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath)
	crate_name = "skrzynia ze skafandrem kosmicznym"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/spacesuit/bulk
	name = "Hurtowa skrzynia skafandrów kosmicznych"
	desc = "Zawiera trzy podstarzałe skafandry z Kosmicznego Lumpeksu."
	cost = 1600 //20% discount
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath)
	crate_name = "hurtowa skrzynia skafandrów kosmicznych"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/emergency/specialops
	name = "Zaopatrzenie do operacji specjalnych"
	desc = "(*!&@#AGENCIE, TO MAŁE ZAMÓWIENIE WCIĄŻ MOŻE CI POMÓC W OPAŁACH. ZAWIERA PUDEŁKO PIĘCIU GRANATÓW EMP, TRZY BOMBY DYMNE, GRANAT ZAPALAJĄCY I „USYPIAJĄCY DŁUGOPIS” PEŁEN MIŁYCH TOKSYN!#@*$"
	hidden = TRUE
	cost = 800
	contains = list(/obj/item/storage/box/emps,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/pen/sleepy,
					/obj/item/grenade/chem_grenade/incendiary)
	crate_name = "skrzynia ratunkowa"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/syndieclothes
	name = "Zaopatrzenie w mundury Syndykatu"
	desc = "(*!&@#AGENCIE, DZIĘKI TEMU MAŁEMU ZAMÓWIENIU BĘDZIESZ STYLOWY W STYLU SYNDYKATU. ZAWIERA TRZY TAKTYCZNE GOLFY, TRZY PARY BUTÓW BOJOWYCH, TRZY PARY RĘKAWIC BOJOWYCH, TRZY KOMINIARKI, TRZY BERETY SYNDYKATU I TRZY KAMIZELKI KULOODPORNE!#@*$"
	hidden = TRUE
	cost = 3000
	contains = list(/obj/item/clothing/under/syndicate,
					/obj/item/clothing/under/syndicate,
					/obj/item/clothing/under/syndicate,
					/obj/item/clothing/shoes/combat,
					/obj/item/clothing/shoes/combat,
					/obj/item/clothing/shoes/combat,
					/obj/item/clothing/mask/balaclava,
					/obj/item/clothing/mask/balaclava,
					/obj/item/clothing/mask/balaclava,
					/obj/item/clothing/gloves/combat,
					/obj/item/clothing/gloves/combat,
					/obj/item/clothing/gloves/combat,
					/obj/item/clothing/head/HoS/beret/syndicate,
					/obj/item/clothing/head/HoS/beret/syndicate,
					/obj/item/clothing/head/HoS/beret/syndicate,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest)
	crate_name = "skrzynia ratunkowa"
	crate_type = /obj/structure/closet/crate/internals

/datum/supply_pack/emergency/weedcontrol
	name = "Skrzynia do zwalczania chwastów"
	desc = "Trzymaj inwazyjne gatunki Z DALEKA. Zawiera kosę, maskę gazową i dwa granaty z chemicznym środkiem chwastobójczym. Gwarancja traci ważność po użyciu na ambrozji. Do otwarcia wymaga dostępu hydroponiki."
	cost = 800
	access = ACCESS_HYDROPONICS
	contains = list(/obj/item/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/grenade/chem_grenade/antiweed,
					/obj/item/grenade/chem_grenade/antiweed)
	crate_name = "skrzynia do zwalczania chwastów"
	crate_type = /obj/structure/closet/crate/secure/hydroponics

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security
	group = "Security"
	access = ACCESS_SECURITY
	access_budget = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/security/armor
	name = "Skrzynia z pancerzami"
	desc = "Trzy wszechstronne, przyzwoicie chroniące kamizelki i 3 hełmy. Do otwarcia wymaga dostępu ochrony."
	cost = 1500
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/head/helmet/sec,
					/obj/item/clothing/head/helmet/sec,
					/obj/item/clothing/head/helmet/sec)
	crate_name = "skrzynia z pancerzami"

/datum/supply_pack/security/hardsuit
	name = "Skrzynia z hardsuitami policyjnymi"
	desc = "Zawiera dwa wytrzymałe hardsuity policyjne. Do otwarcia wymaga dostępu ochrony."
	cost = 2500
	contains = list(/obj/item/clothing/suit/space/hardsuit/security,
					/obj/item/clothing/suit/space/hardsuit/security,)
	crate_name = "skrzynia z hardsuitami policyjnymi"

/* /datum/supply_pack/security/disabler NOT AVAILABLE - NSV
	name = "Disabler Crate"
	desc = "Three stamina-draining disabler weapons. Requires Security access to open."
	cost = 1500
	contains = list(/obj/item/gun/energy/disabler,
					/obj/item/gun/energy/disabler,
					/obj/item/gun/energy/disabler)
	crate_name = "disabler crate" */

/datum/supply_pack/security/dumdum
	name = "Szybkoładowacz .38 DumDum"
	desc = "Zawiera jeden szybkoładowacz z amunicją .38 DumDum, świetną do wbijania się w miękkie cele. Do otwarcia wymaga dostępu ochrony lub kryminalistyki."
	cost = 1200
	access = FALSE
	small_item = TRUE
	access_any = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)
	contains = list(/obj/item/ammo_box/c38/dumdum)
	crate_name = "skrzynia z amunicją .38 match"

/datum/supply_pack/security/dumdum
	name = "Szybkoładowacz .38 DumDum"
	desc = "Zawiera jeden szybkoładowacz z amunicją .38 DumDum, świetną do wbijania się w miękkie cele. Do otwarcia wymaga dostępu ochrony lub kryminalistyki."
	cost = 1200
	access = FALSE
	small_item = TRUE
	access_any = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)
	contains = list(/obj/item/ammo_box/c38/dumdum)
	crate_name = "skrzynia z amunicją .38 match"

/datum/supply_pack/security/forensics
	name = "Skrzynia kryminalistyczna"
	desc = "Depcz przestępcom po piętach z Niezbędnikiem Detektywa(tm) od Nanotrasen. Zawiera skaner kryminalistyczny, sześć torebek na dowody, aparat, dyktafon, białą kredkę i oczywiście fedorę. Do otwarcia wymaga dostępu ochrony."
	cost = 1700
	access_budget = ACCESS_MORGUE
	contains = list(/obj/item/detective_scanner,
					/obj/item/storage/box/evidence,
					/obj/item/camera,
					/obj/item/taperecorder,
					/obj/item/toy/crayon/white,
					/obj/item/clothing/head/fedora/det_hat)
	crate_name = "skrzynia kryminalistyczna"

/* /datum/supply_pack/security/laser //NSV13 - See nsv13/code/modules/cargo/packs.dm for new one
/datum/supply_pack/security/laser
	name = "Lasers Crate"
	desc = "Contains three lethal, high-energy laser guns. Requires Security access to open."
	cost = 1800
	access_budget = ACCESS_ARMORY
	contains = list(/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser)
	crate_name = "laser crate" */

/datum/supply_pack/security/match
	name = "Szybkoładowacz .38 match"
	desc = "Zawiera jeden szybkoładowacz z precyzyjną amunicją .38 match, idealną do popisowych strzałów. Do otwarcia wymaga dostępu ochrony lub kryminalistyki."
	cost = 1200
	access = FALSE
	small_item = TRUE
	access_any = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)
	contains = list(/obj/item/ammo_box/c38/match)
	crate_name = "skrzynia z amunicją .38 match"

/datum/supply_pack/security/match
	name = "Szybkoładowacz .38 match"
	desc = "Zawiera jeden szybkoładowacz z precyzyjną amunicją .38 match, idealną do popisowych strzałów. Do otwarcia wymaga dostępu ochrony lub kryminalistyki."
	cost = 1200
	access = FALSE
	small_item = TRUE
	access_any = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)
	contains = list(/obj/item/ammo_box/c38/match)
	crate_name = "skrzynia z amunicją .38 match"

/datum/supply_pack/security/securitybarriers
	name = "Granaty barierowe ochrony"
	desc = "Powstrzymaj falę czterema granatami barierowymi ochrony. Do otwarcia wymaga dostępu ochrony."
	cost = 1500
	access_budget = ACCESS_BRIG
	contains = list(/obj/item/grenade/barrier,
					/obj/item/grenade/barrier,
					/obj/item/grenade/barrier,
					/obj/item/grenade/barrier)
	crate_name = "skrzynia z barierami ochrony"

/datum/supply_pack/security/securityclothes
	name = "Skrzynia z odzieżą policyjną"
	desc = "Zawiera odpowiednie stroje dla prywatnych sił ochrony stacji: dla Naczelnika, Komendanta i dwóch Policjantów. Każdy strój zawiera mundur, kurtkę i beret odpowiednie do stopnia. Do otwarcia wymaga dostępu ochrony."
	cost = 1700
	contains = list(/obj/item/clothing/under/rank/security/officer/formal,
					/obj/item/clothing/under/rank/security/officer/formal,
					/obj/item/clothing/suit/security/officer,
					/obj/item/clothing/suit/security/officer,
					/obj/item/clothing/head/beret/sec/navyofficer,
					/obj/item/clothing/head/beret/sec/navyofficer,
					/obj/item/clothing/under/rank/security/warden/formal,
					/obj/item/clothing/suit/security/warden,
					/obj/item/clothing/head/beret/sec/navywarden,
					/obj/item/clothing/under/rank/security/head_of_security/formal,
					/obj/item/clothing/suit/security/hos,
					/obj/item/clothing/head/beret/sec/navyhos)
	crate_name = "skrzynia z odzieżą policyjną"

/datum/supply_pack/security/stingpack
	name = "Paczka granatów żądlących"
	desc = "Zawiera pięć granatów żądlących, idealnych do tłumienia zamieszek i robienia moralnie niewyobrażalnych psikusów. Do otwarcia wymaga dostępu ochrony."
	cost = 2500
	access_budget = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/stingbangs)
	crate_name = "skrzynia z paczką granatów żądlących"

/datum/supply_pack/security/stingpack/single
	name = "Granat żądlący – pojedyncza sztuka"
	desc = "Zawiera jeden granat żądlący, idealny do złośliwych psikusów. Do otwarcia wymaga dostępu ochrony."
	cost = 1400
	access_budget = ACCESS_ARMORY
	small_item = TRUE
	contains = list(/obj/item/grenade/stingbang)

/datum/supply_pack/security/supplies
	name = "Skrzynia z zaopatrzeniem ochrony"
	desc = "Zawiera siedem granatów hukowo-błyskowych, siedem granatów z gazem łzawiącym, sześć flashy i siedem par kajdanek. Do otwarcia wymaga dostępu ochrony."
	cost = 700
	access_budget = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/teargas,
					/obj/item/storage/box/flashes,
					/obj/item/storage/box/handcuffs)
	crate_name = "skrzynia z zaopatrzeniem ochrony"

/datum/supply_pack/security/vending/security
	name = "Skrzynia zaopatrzenia Zbrojowni Policyjnej" //AQUILA EDIT - SecTech
	desc = "Funkcjonariusz Paweł wykupił wszystkie kajdanki? Uzupełnij automat ochrony tą skrzynią."
	cost = 1200
	contains = list(/obj/item/vending_refill/security)
	crate_name = "skrzynia zaopatrzenia Zbrojowni Policyjnej" //AQUILA EDIT - SecTech

/datum/supply_pack/security/firingpins
	name = "Skrzynia standardowych iglic"
	desc = "Ulepsz swój arsenał dzięki 10 standardowym iglicom. Do otwarcia wymaga dostępu ochrony."
	cost = 1700
	access_budget = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/firingpins,
					/obj/item/storage/box/firingpins)
	crate_name = "skrzynia z iglicami"

/datum/supply_pack/security/firingpins/paywall
	name = "Skrzynia iglic z płatnym dostępem"
	desc = "Specjalne iglice z wbudowaną, konfigurowalną opłatą za strzał. Do otwarcia wymaga dostępu ochrony."
	cost = 1700
	access_budget = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/firingpins/paywall,
					/obj/item/storage/box/firingpins/paywall)
	crate_name = "skrzynia z iglicami z płatnym dostępem"

/datum/supply_pack/security/justiceinbound
	name = "Skrzynia ze standardowym Egzekutorem Sprawiedliwości"
	desc = "To jest to. Najlepsze z najlepszych. Śmietanka. Wisienka na torcie. Najlepsze z najlepszych z najlepszych. Klejnot w koronie Nanotrasen. Alfa i omega policyjnych nakryć głowy. Gwarantuje strach w sercu każdego przestępcy na pokładzie stacji. W zestawie także maska gazowa ochrony. Do otwarcia wymaga dostępu ochrony."
	cost = 5700 //justice comes at a price. An expensive, noisy price.
	contraband = TRUE
	contains = list(/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/mask/gas/sechailer)
	crate_name = "skrzynia z odzieżą policyjną"

/datum/supply_pack/security/baton
	name = "Skrzynia pałek ogłuszających"
	desc = "Uzbrój Siły Ochrony Cywilnej w trzy pałki ogłuszające. Baterie w zestawie. Do otwarcia wymaga dostępu ochrony."
	cost = 900
	contains = list(/obj/item/melee/baton/loaded,
					/obj/item/melee/baton/loaded,
					/obj/item/melee/baton/loaded)
	crate_name = "skrzynia z pałkami ogłuszającymi"

/datum/supply_pack/security/wall_flash
	name = "Skrzynia ściennych flashy"
	desc = "Zawiera pięć montowanych na ścianie flashy. Do otwarcia wymaga dostępu ochrony."
	cost = 800
	contains = list(/obj/item/storage/box/wall_flash,
					/obj/item/storage/box/wall_flash,
					/obj/item/storage/box/wall_flash,
					/obj/item/storage/box/wall_flash,
					/obj/item/storage/box/wall_flash)
	crate_name = "skrzynia ze ściennymi flashami"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Armory //////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/security/armory
	group = "Armory"
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/security/ammo
	name = "Skrzynia z amunicją"
	desc = "Zawiera dwa 20-nabojowe magazynki do karabinu automatycznego WT-550, trzy pudełka nabojów śrutowych, trzy pudełka amunicji gumowej i specjalne szybkoładowacze .38. Do otwarcia wymaga dostępu ochrony."
	cost = 2500
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/rubbershot,
					/obj/item/storage/box/rubbershot,
					/obj/item/storage/box/rubbershot,
					/obj/item/ammo_box/c38/trac,
					/obj/item/ammo_box/c38/hotshot,
					/obj/item/ammo_box/c38/iceblox)
	crate_name = "skrzynia z amunicją"

// NSV13 modified
/datum/supply_pack/security/armory/bulletarmor
	name = "Skrzynia z pancerzami kuloodpornymi"
	desc = "Zawiera trzy komplety pancerzy kuloodpornych z pasującymi hełmami. Gwarantowane zmniejszenie siły obalającej pocisku o ponad połowę. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 3000
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt)
	crate_name = "skrzynia z pancerzami kuloodpornymi"

/datum/supply_pack/security/armory/chemimp
	name = "Skrzynia implantów chemicznych"
	desc = "Zawiera pięć zdalnych implantów chemicznych. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 700
	contains = list(/obj/item/storage/box/chemimp)
	crate_name = "skrzynia z implantami chemicznymi"

/datum/supply_pack/security/armory/combatknives_single
	name = "Nóż bojowy – pojedyncza sztuka"
	desc = "Zawiera jeden naostrzony nóż bojowy. Na pewno pasuje do każdego buta zgodnego ze standardem Nanotrasen. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 700 // 300 credits per 1 knife
	small_item = TRUE
	contains = list(/obj/item/kitchen/knife/combat)

/datum/supply_pack/security/armory/combatknives
	name = "Skrzynia noży bojowych"
	desc = "Zawiera trzy naostrzone noże bojowe. Każdy na pewno pasuje do każdego buta zgodnego ze standardem Nanotrasen. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 1120 //20% discount
	contains = list(/obj/item/kitchen/knife/combat,
					/obj/item/kitchen/knife/combat,
					/obj/item/kitchen/knife/combat)
	crate_name = "skrzynia z nożami bojowymi"

/datum/supply_pack/security/armory/ballistic_single
	name = "Strzelba bojowa – pojedyncza sztuka"
	desc = "Na wypadek, gdy wroga trzeba koniecznie nafaszerować ołowiem. Zawiera jedną strzelbę bojową projektu Aussec i jeden bandolier na naboje. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 2900 //2500 credits per shotgun
	small_item = TRUE
	contains = list(/obj/item/gun/ballistic/shotgun/automatic/combat,
					/obj/item/storage/belt/bandolier)

/datum/supply_pack/security/armory/ballistic
	name = "Skrzynia strzelb bojowych"
	desc = "Na wypadek, gdy wroga trzeba koniecznie nafaszerować ołowiem. Zawiera trzy strzelby bojowe projektu Aussec i trzy bandoliery na naboje. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 6400 //20% discount
	contains = list(/obj/item/gun/ballistic/shotgun/automatic/combat,
					/obj/item/gun/ballistic/shotgun/automatic/combat,
					/obj/item/gun/ballistic/shotgun/automatic/combat,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier)
	crate_name = "skrzynia ze strzelbami bojowymi"

/datum/supply_pack/security/armory/riot_shotgun_single
	name = "Strzelba prewencyjna – pojedyncza sztuka"
	desc = "Gdy klaun o jeden raz za dużo cię poślizgnął. Do otwarcia wymaga dostępu do zbrojowni."
	cost =  2200 //1800 credits per shotgun
	contains = list(/obj/item/gun/ballistic/shotgun/riot)

/datum/supply_pack/security/armory/riot_shotgun
	name = "Skrzynia strzelb prewencyjnych"
	desc = "Na wypadek, gdy szara fala wymknie się spod kontroli. Zawiera 3 strzelby prewencyjne. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 4720 //20% discount
	contains = list(/obj/item/gun/ballistic/shotgun/riot,
					/obj/item/gun/ballistic/shotgun/riot,
					/obj/item/gun/ballistic/shotgun/riot)

/datum/supply_pack/security/armory/dragnet
	name = "Skrzynia DRAGnetów"
	desc = "Zawiera trzy sieciowe urządzenia „Dynamicznego Szybkiego Zatrzymywania Winnych”, najnowszy przełom w technologii zarządzania więźniami. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 2000 // NSV: 1500 -> 2000
	contains = list(/obj/item/gun/energy/e_gun/dragnet,
					/obj/item/gun/energy/e_gun/dragnet,
					/obj/item/gun/energy/e_gun/dragnet)
	crate_name = "\improper skrzynia z DRAGnetami"

/* /datum/supply_pack/security/armory/energy_single //NSV13 - not available
	name = "Energy Guns Single-Pack"
	desc = "Contains one Energy Gun, capable of firing both nonlethal and lethal blasts of light. Requires Armory access to open."
	cost = 1200
	small_item = TRUE
	contains = list(/obj/item/gun/energy/e_gun)
	crate_name = "single energy gun crate"

/datum/supply_pack/security/armory/energy
	name = "Bulk Energy Guns Crate"
	desc = "Contains three Energy Guns, capable of firing both nonlethal and lethal blasts of light. Requires Armory access to open."
	cost = 2320 //20%
	contains = list(/obj/item/gun/energy/e_gun,
					/obj/item/gun/energy/e_gun,
					/obj/item/gun/energy/e_gun)
	crate_name = "bulk energy guns crate"
	crate_type = /obj/structure/closet/crate/secure/plasma */

/datum/supply_pack/security/armory/exileimp
	name = "Skrzynia implantów wygnania"
	desc = "Zawiera pięć implantów wygnania. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 2700
	contains = list(/obj/item/storage/box/exileimp)
	crate_name = "skrzynia z implantami wygnania"

/datum/supply_pack/security/armory/fire
	name = "Skrzynia broni zapalającej"
	desc = "Płoń, mała, płoń. Zawiera trzy granaty zapalające, trzy kanistry z plazmą i miotacz ognia. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 1200
	access = ACCESS_HEADS
	contains = list(/obj/item/flamethrower/full,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary)
	crate_name = "skrzynia z bronią zapalającą"
	crate_type = /obj/structure/closet/crate/secure/plasma
	dangerous = TRUE

/datum/supply_pack/security/armory/securitybarriersxl
	name = "Kapsuły barier ochrony XL"
	desc = "Barykady 3x3 ze szkła zbrojonego na wypadek, gdyby operatorzy nuklearni zapukali do drzwi. Do otwarcia wymaga dostępu ochrony."
	small_item = TRUE
	contains = list(/obj/item/survivalcapsule/barricade,
					/obj/item/survivalcapsule/barricade,
					/obj/item/survivalcapsule/barricade)
	cost = 2000
	crate_name = "skrzynia z barierami ochrony XL"

/datum/supply_pack/security/armory/mindshield
	name = "Skrzynia implantów ochrony umysłu"
	desc = "Chroń się przed radykalnymi myślami dzięki trzem implantom ochrony umysłu. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 4000
	contains = list(/obj/item/storage/lockbox/loyalty)
	crate_name = "skrzynia z implantami ochrony umysłu"

/datum/supply_pack/security/armory/trackingimp
	name = "Skrzynia implantów namierzających"
	desc = "Zawiera cztery implanty namierzające i trzy szybkoładowacze z namierzającą amunicją .38. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 1200
	contains = list(/obj/item/storage/box/trackimp,
					/obj/item/ammo_box/c38/trac,
					/obj/item/ammo_box/c38/trac,
					/obj/item/ammo_box/c38/trac)
	crate_name = "skrzynia z implantami namierzającymi"

/* /datum/supply_pack/security/armory/laserarmor NOT AVAILABLE - NSV
	name = "Reflector Vest Crate"
	desc = "Contains two vests of highly reflective material. Each armor piece diffuses a laser's energy by over half, as well as offering a good chance to reflect the laser entirely. Requires Armory access to open."
	cost = 2000
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof)
	crate_name = "reflector vest crate"
	crate_type = /obj/structure/closet/crate/secure/plasma */

/datum/supply_pack/security/armory/riotarmor
	name = "Skrzynia strojów prewencyjnych"
	desc = "Zawiera trzy komplety ciężkiego pancerza z hełmami. Zaawansowane wyściółki chronią przed bronią do walki wręcz, przez co ciosy są dla noszącego o połowę słabsze. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 2200
	contains = list(/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot)
	crate_name = "skrzynia ze strojami prewencyjnymi"

/datum/supply_pack/security/armory/riotshields
	name = "Skrzynia tarcz prewencyjnych"
	desc = "Na wypadek, gdy szara fala naprawdę się rozzuchwali. Zawiera trzy tarcze prewencyjne. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 1500
	contains = list(/obj/item/shield/riot,
					/obj/item/shield/riot,
					/obj/item/shield/riot)
	crate_name = "skrzynia z tarczami prewencyjnymi"

/datum/supply_pack/security/armory/russian
	name = "Skrzynia rosyjskich nadwyżek"
	desc = "Witaj, towarzyszu, mamy najnowocześniejszy rosyjski sprzęt wojskowy, jaki może zaoferować czarny rynek, oczywiście za odpowiednią cenę. Niestety nie udało nam się zdjąć zamka, więc do otwarcia wymaga dostępu do zbrojowni."
	cost = 4000
	contraband = TRUE
	contains = list(/obj/item/food/rationpack,
					/obj/item/ammo_box/a762,
					/obj/item/storage/toolbox/ammo,
					/obj/item/clothing/suit/armor/vest/russian,
					/obj/item/clothing/head/helmet/rus_helmet,
					/obj/item/clothing/shoes/russian,
					/obj/item/clothing/gloves/combat,
					/obj/item/clothing/under/syndicate/rus_army,
					/obj/item/clothing/under/costume/soviet,
					/obj/item/clothing/mask/russian_balaclava,
					/obj/item/clothing/head/helmet/rus_ushanka,
					/obj/item/clothing/suit/armor/vest/russian_coat,
					/obj/item/gun/ballistic/rifle/boltaction,
					/obj/item/gun/ballistic/rifle/boltaction)
	crate_name = "skrzynia z wojskowymi nadwyżkami"

/datum/supply_pack/security/armory/russian/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 10)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/security/armory/smartmine
	name = "Skrzynia inteligentnych min"
	desc = "Zawiera trzy nieśmiercionośne miny ogłuszające aktywowane naciskiem, które ignorują personel z implantem ochrony umysłu. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 2500
	contains = list(/obj/item/deployablemine/smartstun,
					/obj/item/deployablemine/smartstun,
					/obj/item/deployablemine/smartstun)
	crate_name = "skrzynia z minami ogłuszającymi"

/datum/supply_pack/security/armory/stunmine
	name = "Skrzynia min ogłuszających"
	desc = "Zawiera pięć nieśmiercionośnych min ogłuszających aktywowanych naciskiem. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 2000
	contains = list(/obj/item/deployablemine/stun,
					/obj/item/deployablemine/stun,
					/obj/item/deployablemine/stun,
					/obj/item/deployablemine/stun,
					/obj/item/deployablemine/stun)
	crate_name = "skrzynia z minami ogłuszającymi"

/datum/supply_pack/security/armory/swat
	name = "Skrzynia SWAT"
	desc = "Zawiera dwa pełne komplety wytrzymałych, ognioodpornych, hermetycznych kombinezonów opracowanych wspólnie przez IS-ERI i Nanotrasen. Każdy komplet zawiera kombinezon, hełm, maskę, pas bojowy i rękawice bojowe. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 5000
	contains = list(/obj/item/clothing/head/helmet/swat/nanotrasen,
					/obj/item/clothing/head/helmet/swat/nanotrasen,
					/obj/item/clothing/suit/space/swat,
					/obj/item/clothing/suit/space/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/storage/belt/military/assault,
					/obj/item/storage/belt/military/assault,
					/obj/item/clothing/gloves/combat,
					/obj/item/clothing/gloves/combat)
	crate_name = "skrzynia SWAT"

/datum/supply_pack/security/armory/wt550_single
	name = "Karabin automatyczny WT-550 – pojedyncza sztuka"
	desc = "Zawiera jeden potężny karabin półautomatyczny kalibru 4.6x30mm. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 1600 // 1200 per 1 gun
	contains = list(/obj/item/gun/ballistic/automatic/wt550)
	small_item = TRUE

/datum/supply_pack/security/armory/wt550
	name = "Skrzynia karabinów automatycznych WT-550"
	desc = "Zawiera dwa potężne karabiny półautomatyczne kalibru 4.6x30mm. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 3280 //20%
	contains = list(/obj/item/gun/ballistic/automatic/wt550,
					/obj/item/gun/ballistic/automatic/wt550,
					/obj/item/gun/ballistic/automatic/wt550)
	crate_name = "skrzynia z karabinami automatycznymi"

/datum/supply_pack/security/armory/wt550ammo
	name = "Skrzynia amunicji do karabinu WT-550"
	desc = "Zawiera cztery 20-nabojowe magazynki do karabinu automatycznego WT-550. Każdy magazynek zaprojektowano z myślą o szybkim taktycznym przeładowaniu. Do otwarcia wymaga dostępu do zbrojowni."
	cost = 1500
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9)

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Engineering /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/engineering
	group = "Engineering"
	crate_type = /obj/structure/closet/crate/engineering
	access_budget = ACCESS_ENGINE

/datum/supply_pack/engineering/shieldgen
	name = "Skrzynia projektorów osłon przeciwwyłomowych"
	desc = "Znowu wyrwy w kadłubie? Koniec z tym dzięki projektorowi osłony przeciwwyłomowej Nanotrasen! Wykorzystuje technologię pola siłowego, by powietrze zostało w środku, a kosmos na zewnątrz. Zawiera dwa projektory osłon."
	cost = 1000
	access_budget = ACCESS_ENGINE_EQUIP
	contains = list(/obj/machinery/shieldgen,
					/obj/machinery/shieldgen)
	crate_name = "skrzynia z projektorami osłon przeciwwyłomowych"

/datum/supply_pack/engineering/ripley
	name = "Skrzynia APLU MK-I"
	desc = "Zestaw „zrób to sam” do zbudowania APLU MK-I „Ripley”, przeznaczonego do podnoszenia i przenoszenia ciężkiego sprzętu oraz innych prac na stacji. Baterie nie są dołączone."
	cost = 1500
	access_budget = FALSE
	contains = list(/obj/item/mecha_parts/chassis/ripley,
					/obj/item/mecha_parts/part/ripley_torso,
					/obj/item/mecha_parts/part/ripley_right_arm,
					/obj/item/mecha_parts/part/ripley_left_arm,
					/obj/item/mecha_parts/part/ripley_right_leg,
					/obj/item/mecha_parts/part/ripley_left_leg,
					/obj/item/stock_parts/capacitor,
					/obj/item/stock_parts/scanning_module,
					/obj/item/circuitboard/mecha/ripley/main,
					/obj/item/circuitboard/mecha/ripley/peripherals,
					/obj/item/mecha_parts/mecha_equipment/drill,
					/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp)
	crate_name= "zestaw APLU MK-I"

/datum/supply_pack/engineering/conveyor
	name = "Skrzynia do montażu taśmociągów"
	desc = "Niech produkcja idzie naprzód dzięki trzydziestu taśmociągom. Przełącznik taśmociągu w zestawie. W razie pytań zajrzyj do załączonej instrukcji."
	cost = 1200
	access_budget = FALSE
	contains = list(/obj/item/stack/conveyor/thirty,
					/obj/item/conveyor_switch_construct,
					/obj/item/paper/guides/conveyor)
	crate_name = "skrzynia do montażu taśmociągów"

/datum/supply_pack/engineering/engiequipment
	name = "Skrzynia sprzętu inżynieryjnego"
	desc = "Wyposaż się w trzy pasy na narzędzia, kamizelki odblaskowe, przyłbice spawalnicze, kaski i dwie pary gogli mezonowych!"
	cost = 1000
	contains = list(/obj/item/storage/belt/utility,
					/obj/item/storage/belt/utility,
					/obj/item/storage/belt/utility,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/suit/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/glasses/meson/engine,
					/obj/item/clothing/glasses/meson/engine)
	crate_name = "skrzynia ze sprzętem inżynieryjnym"

/datum/supply_pack/engineering/powergamermitts
	name = "Skrzynia rękawic izolacyjnych"
	desc = "Kręgosłup nowoczesnego społeczeństwa. Prawie nigdy nie zamawiane do prawdziwej pracy inżynieryjnej. Zawiera trzy pary rękawic izolacyjnych."
	cost = 1600	//Made of pure-grade bullshittinium
	access_budget = ACCESS_ENGINE_EQUIP
	contains = list(/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow)
	crate_name = "skrzynia z rękawicami izolacyjnymi"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/jetpack
	name = "Skrzynia z plecakiem odrzutowym"
	desc = "Na wypadek, gdy musisz się szybko przemieszczać w kosmosie!"
	cost = 850
	access_budget = FALSE
	contains = list(/obj/item/tank/jetpack/carbondioxide)
	crate_name = "skrzynia z plecakiem odrzutowym"

/datum/supply_pack/engineering/jetpack3
	name = "Hurtowa skrzynia plecaków odrzutowych"
	desc = "Trzy plecaki odrzutowe, wystarczy dla całej ekipy!"
	cost = 1750 //20% discount
	access_budget = FALSE
	contains = list(/obj/item/tank/jetpack/carbondioxide,
					/obj/item/tank/jetpack/carbondioxide,
					/obj/item/tank/jetpack/carbondioxide)
	crate_name = "hurtowa skrzynia plecaków odrzutowych"

/datum/supply_pack/engineering/spacecapsule
	name = "Kapsuła kosmicznego schronu"
	desc = "Skrzynia zawierająca RCD, kilka wkładów z materią i jedną kapsułę bluespace ze schronem zdatnym do użytku w kosmosie, na potrzeby budowy lub nagłych wypadków."
	cost = 1500
	contains = list(/obj/item/survivalcapsule/space,
					/obj/item/construction/rcd,
					/obj/item/rcd_ammo,
					/obj/item/rcd_ammo,
					/obj/item/rcd_ammo,
					/obj/item/rcd_ammo)
	crate_name = "skrzynia z kosmicznym schronem"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/obj/item/stock_parts/cell/inducer_supply
	maxcharge = 5000
	charge = 5000

/datum/supply_pack/engineering/inducers
	name = "Skrzynia wytrzymałych induktorów NT-100"
	desc = "Brak ładowarek? Żaden problem: z NT-100 EPI naładujesz dowolny standardowy sprzęt zasilany ogniwem, kiedy chcesz i gdzie chcesz, dwa razy szybciej niż konsumenckie zamienniki! Zawiera dwa inżynieryjne induktory."
	cost = 2000
	contains = list(/obj/item/inducer {cell_type = /obj/item/stock_parts/cell/high; opened = 0}, /obj/item/inducer {cell_type = /obj/item/stock_parts/cell/inducer_supply; opened = 0}) //FALSE doesn't work in modified type paths apparently.
	crate_name = "skrzynia z induktorami"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/pacman
	name = "Skrzynia z generatorem P.A.C.M.A.N."
	desc = "Inżynierowie nie potrafią uruchomić silnika? Dla ciebie to żaden problem, gdy dostaniesz w ręce ten generator P.A.C.M.A.N.! Przyjmuje plazmę i wypluwa słodką, słodką energię."
	cost = 1000
	contains = list(/obj/machinery/power/port_gen/pacman)
	crate_name = "skrzynia z generatorem P.A.C.M.A.N."
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/power
	name = "Skrzynia ogniw zasilających"
	desc = "Szukasz przytłaczającej mocy? Nie szukaj dalej. Zawiera trzy wysokonapięciowe ogniwa zasilające."
	cost = 500
	contains = list(/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	crate_name = "skrzynia z ogniwami zasilającymi"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engineering/shuttle_engine
	name = "Skrzynia z silnikiem promu"
	desc = "Dzięki zaawansowanym sztuczkom bluespace nasi inżynierowie zdołali zmieścić cały silnik promu w jednej malutkiej skrzyni. Do otwarcia wymaga dostępu Głównego Inżyniera."
	cost = 5000
	access = ACCESS_CE
	access_budget = ACCESS_CE
	contains = list(/obj/structure/shuttle/engine/propulsion/burst/cargo)
	crate_name = "skrzynia z silnikiem promu"
	crate_type = /obj/structure/closet/crate/secure/engineering
	special = TRUE

/datum/supply_pack/engineering/tools
	name = "Skrzynia skrzynek narzędziowych"
	desc = "Żaden porządny kosmonauta nie oddala się od swojej niezawodnej skrzynki narzędziowej. Zawiera trzy elektryczne i trzy mechaniczne skrzynki narzędziowe."
	cost = 700
	access_budget = ACCESS_ENGINE_EQUIP
	contains = list(/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical)
	cost = 700
	crate_name = "skrzynia ze skrzynkami narzędziowymi"

/datum/supply_pack/engineering/vending/engineering
	name = "Skrzynia uzupełnień automatów inżynieryjnych"
	desc = "Masz dość asystentów włamujących się do inżynierii po narzędzia? Zawiera jeden wkład uzupełniający Engi-Vend i jeden YouTool."
	cost = 1100
	contains = list(/obj/item/vending_refill/engivend,
					/obj/item/vending_refill/tool)
	crate_name = "skrzynia z uzupełnieniami automatów inżynieryjnych"

/datum/supply_pack/engineering/bsa
	name = "Części artylerii bluespace"
	desc = "Duma Dowództwa Marynarki Nanotrasen. Legendarne działo artylerii bluespace to niszczycielski wyczyn ludzkiej inżynierii i świadectwo wojennej determinacji. Do prawidłowego złożenia potrzebne są bardzo zaawansowane badania."
	cost = 15000
	special = TRUE
	access_budget = ACCESS_HEADS
	contains = list(/obj/item/circuitboard/machine/bsa/front,
					/obj/item/circuitboard/machine/bsa/middle,
					/obj/item/circuitboard/machine/bsa/back,
					/obj/item/circuitboard/computer/bsa_control
					)
	crate_name= "skrzynia z częściami artylerii bluespace"

/datum/supply_pack/engineering/dna_vault
	name = "Części skarbca DNA"
	desc = "Zapewnij przetrwanie obecnego stanu ludzkości w tej ogromnej bibliotece wiedzy naukowej, zdolnej obdarzyć nadludzkimi mocami i zdolnościami. Do prawidłowego złożenia potrzebne są bardzo zaawansowane badania. Zawiera też pięć próbników DNA."
	cost = 12000
	special = TRUE
	access_budget = ACCESS_HEADS
	contains = list(
					/obj/item/circuitboard/machine/dna_vault,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe
					)
	crate_name= "skrzynia z częściami skarbca DNA"

/datum/supply_pack/engineering/dna_probes
	name = "Próbniki do skarbca DNA"
	desc = "Zawiera pięć próbników DNA do skarbca DNA."
	cost = 3000
	special = TRUE
	access_budget = ACCESS_HEADS
	contains = list(/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe
					)
	crate_name= "skrzynia z próbnikami DNA"


/datum/supply_pack/engineering/shield_sat
	name = "Satelita generatora tarczy"
	desc = "Chroń samo istnienie tej stacji dzięki obronie przeciwmeteorytowej. Zawiera trzy satelity generatora tarczy."
	cost = 3000
	access_budget = ACCESS_HEADS
	contains = list(
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield
					)
	crate_name= "skrzynia z satelitami tarczy"


/datum/supply_pack/engineering/shield_sat_control
	name = "Płytka sterowania systemem tarcz"
	desc = "System sterowania satelitami generatora tarczy."
	cost = 5000
	access_budget = ACCESS_HEADS
	contains = list(/obj/item/circuitboard/computer/sat_control)
	crate_name= "skrzynia z płytką sterowania tarczami"

/datum/supply_pack/engineering/bluespace_tap
	name = "Części żniwiarki bluespace"
	cost = 15000
	special = TRUE
	contains = list(
					/obj/item/circuitboard/machine/bluespace_tap,
					/obj/item/paper/bluespace_tap
					)
	crate_name = "skrzynia z częściami żniwiarki bluespace"

/datum/supply_pack/engineering/shuttle_construction
	name = "Zestaw do budowy promu"
	desc = "Zestaw „zrób to sam” do zbudowania własnego promu! Zawiera wszystkie części potrzebne, by zabrać ludzi do gwiazd!"
	cost = 5000
	contains = list(
		/obj/machinery/portable_atmospherics/canister/toxins,
		/obj/item/construction/rcd/loaded,
		/obj/item/rcd_ammo/large,
		/obj/item/rcd_ammo/large,
		/obj/item/shuttle_creator,
		/obj/item/pipe_dispenser,
		/obj/item/storage/toolbox/mechanical,
		/obj/item/storage/toolbox/electrical,
		/obj/item/circuitboard/computer/shuttle/flight_control,
		/obj/item/circuitboard/machine/shuttle/engine/plasma,
		/obj/item/circuitboard/machine/shuttle/engine/plasma,
		/obj/item/circuitboard/machine/shuttle/heater,
		/obj/item/circuitboard/machine/shuttle/heater
		)
	crate_name = "skrzynia do budowy promu"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/engineering/portable_pumps
	name = "Przenośne pompy"
	desc = "Zestaw zapasowych przenośnych pomp. Idealny do większych projektów atmosferycznych albo uzupełnienia zapasów, gdy w toksynach coś pójdzie nie tak."
	cost = 1500
	contains = list(
		/obj/machinery/portable_atmospherics/pump,
		/obj/machinery/portable_atmospherics/pump
	)
	crate_name = "skrzynia z przenośnymi pompami"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/engineering/portable_scrubbers
	name = "Przenośne oczyszczacze"
	desc = "Zestaw zapasowych przenośnych oczyszczaczy powietrza. Idealny na wypadek, gdy plazma „przypadkiem” dostanie się do instalacji powietrza."
	cost = 1500
	contains = list(
		/obj/machinery/portable_atmospherics/scrubber,
		/obj/machinery/portable_atmospherics/scrubber
	)
	crate_name = "skrzynia z przenośnymi oczyszczaczami"
	crate_type = /obj/structure/closet/crate/large

//////////////////////////////////////////////////////////////////////////////
//////////////////////// Engine Construction /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/engine
	group = "Engine Construction"
	access = ACCESS_ENGINE_EQUIP //NSV13 - Do your hecking jobs
	crate_type = /obj/structure/closet/crate/engineering
	access_budget = ACCESS_ENGINE


/datum/supply_pack/engine/am_jar
	name = "Skrzynia słojów na antymaterię"
	desc = "Dwa słoje do przechowywania antymaterii upchnięte w jednej skrzyni."
	cost = 1700
	contains = list(/obj/item/am_containment,
					/obj/item/am_containment)
	crate_name = "skrzynia ze słojami na antymaterię"

/datum/supply_pack/engine/am_core
	name = "Skrzynia sterowania antymaterią"
	desc = "Mózg silnika antymaterii. To urządzenie z pewnością nauczy sieć energetyczną stacji, czym jest prawdziwa moc."
	cost = 4700
	contains = list(/obj/machinery/power/am_control_unit)
	crate_name = "skrzynia ze sterowaniem antymaterią"

/datum/supply_pack/engine/am_shielding
	name = "Skrzynia osłon antymaterii"
	desc = "Zawiera dziesięć osłon antymaterii, jakimś cudem wciśniętych do skrzyni."
	cost = 1700
	contains = list(/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container,
					/obj/item/am_shielding_container) //10 shields: 3x3 containment and a core
	crate_name = "skrzynia z osłonami antymaterii"


/datum/supply_pack/engine/emitter
	name = "Skrzynia emiterów"
	desc = "Przydatne do zasilania generatorów pola, a przy okazji do niszczenia zamkniętych skrzyń i intruzów. Zawiera dwa emitery wysokiej mocy. Do otwarcia wymaga dostępu Głównego Inżyniera."
	cost = 1200
	access = ACCESS_CE
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	crate_name = "skrzynia z emiterami"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/field_gen
	name = "Skrzynia generatorów pola"
	desc = "Zwykle jedyna rzecz, która dzieli stację od paskudnej śmierci. Zasilane przez emitery. Zawiera dwa generatory pola."
	cost = 1200
	contains = list(/obj/machinery/field/generator,
					/obj/machinery/field/generator)
	crate_name = "skrzynia z generatorami pola"

/datum/supply_pack/engine/grounding_rods
	name = "Skrzynia prętów uziemiających"
	desc = "Cztery pręty uziemiające, które na pewno utrzymają w ryzach pioruny każdej rozbrykanej kuli Tesli."
	cost = 700
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	crate_name = "skrzynia z prętami uziemiającymi"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engine/PA
	name = "Skrzynia z akceleratorem cząstek"
	desc = "Supermasywna czarna dziura albo naładowana do granic kula Tesli to idealny sposób na rozkręcenie każdej imprezy! Ten zestaw „Moja pierwsza apokalipsa” zawiera wszystko, czego potrzebujesz do zbudowania własnego akceleratora cząstek! Od lat 10."
	cost = 2700
	access = ACCESS_CE
	access_budget = ACCESS_CE
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	crate_name = "skrzynia z akceleratorem cząstek"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/collector
	name = "Skrzynia kolektorów promieniowania"
	desc = "Zawiera trzy kolektory promieniowania. Przydają się do zbierania energii z pobliskich kryształów supermaterii, osobliwości albo kul Tesli!"
	cost = 2200
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	crate_name = "skrzynia z kolektorami"

/datum/supply_pack/engine/sing_gen
	name = "Skrzynia z generatorem osobliwości"
	desc = "Klucz do wyzwolenia mocy Pana Singulotha. Akcelerator cząstek nie jest dołączony."
	cost = 4700
	access = ACCESS_CE
	access_budget = ACCESS_CE
	contains = list(/obj/machinery/the_singularitygen)
	crate_name = "skrzynia z generatorem osobliwości"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/solar
	name = "Skrzynia paneli słonecznych"
	desc = "Postaw na zieleń z tym zaawansowanym zestawem paneli słonecznych do samodzielnego montażu. Zawiera dwadzieścia jeden zespołów paneli słonecznych, płytkę konsoli paneli słonecznych i nadążnik. W razie pytań zajrzyj do załączonej instrukcji."
	cost = 1700
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/circuitboard/computer/solar_control,
					/obj/item/electronics/tracker,
					/obj/item/paper/guides/jobs/engi/solars)
	crate_name = "skrzynia z panelami słonecznymi"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engine/supermatter_shard
	name = "Skrzynia z odłamkiem supermaterii"
	desc = "Moc niebios zamknięta w jednym krysztale. Do otwarcia wymaga dostępu Głównego Inżyniera."
	cost = 10000
	access = ACCESS_CE
	access_budget = ACCESS_CE
	contains = list(/obj/machinery/power/supermatter_crystal/shard)
	crate_name = "skrzynia z odłamkiem supermaterii"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/tesla_coils
	name = "Skrzynia cewek Tesli"
	desc = "Egzekucje wysokim napięciem, punkty badawcze czy zwykła produkcja energii: ten zestaw czterech cewek Tesli poradzi sobie ze wszystkim!"
	cost = 1200
	contains = list(/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil)
	crate_name = "skrzynia z cewkami Tesli"
	crate_type = /obj/structure/closet/crate/engineering/electrical

/datum/supply_pack/engine/tesla_gen
	name = "Skrzynia z generatorem Tesli"
	desc = "Klucz do wyzwolenia mocy kuli energii Tesli. Akcelerator cząstek nie jest dołączony."
	cost = 5000
	access = ACCESS_CE
	access_budget = ACCESS_CE
	contains = list(/obj/machinery/the_singularitygen/tesla)
	crate_name = "skrzynia z generatorem Tesli"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

//////////////////////////////////////////////////////////////////////////////
/////////////////////// Canisters & Materials ////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/materials
	group = "Canisters & Materials"

/datum/supply_pack/materials/cardboard50
	name = "50 arkuszy tektury"
	desc = "Zrób kupę pudełek."
	cost = 1000
	contains = list(/obj/item/stack/sheet/cardboard/fifty)
	crate_name = "skrzynia z arkuszami tektury"

/datum/supply_pack/materials/glass50
	name = "50 arkuszy szkła"
	desc = "Wpuść trochę ładnego światła dzięki pięćdziesięciu arkuszom szkła!"
	cost = 1000
	contains = list(/obj/item/stack/sheet/glass/fifty)
	crate_name = "skrzynia z arkuszami szkła"

/datum/supply_pack/materials/glass250
	name = "250 arkuszy szkła"
	desc = "O ja cię, ale dużo szkła!"
	cost = 2800 //20%
	contains = list(/obj/item/stack/sheet/glass/fifty,
					/obj/item/stack/sheet/glass/fifty,
					/obj/item/stack/sheet/glass/fifty,
					/obj/item/stack/sheet/glass/fifty,
					/obj/item/stack/sheet/glass/fifty)
	crate_name = "hurtowa skrzynia arkuszy szkła"

/datum/supply_pack/materials/iron50
	name = "50 arkuszy żelaza"
	desc = "Każdy projekt budowlany zaczyna się od porządnego stosu pięćdziesięciu arkuszy żelaza!"
	cost = 1000
	contains = list(/obj/item/stack/sheet/iron/fifty)
	crate_name = "skrzynia z arkuszami żelaza"

/datum/supply_pack/materials/iron250
	name = "250 arkuszy żelaza"
	desc = "Tyle żelaza, że wystarczy na odbudowę połowy stacji!"
	cost = 2800 //20%
	contains = list(/obj/item/stack/sheet/iron/fifty,
					/obj/item/stack/sheet/iron/fifty,
					/obj/item/stack/sheet/iron/fifty,
					/obj/item/stack/sheet/iron/fifty,
					/obj/item/stack/sheet/iron/fifty)
	crate_name = "hurtowa skrzynia arkuszy żelaza"

/datum/supply_pack/materials/plasteel20
	name = "20 arkuszy plastali"
	desc = "Wzmocnij integralność stacji dwudziestoma arkuszami plastali!"
	cost = 7200
	contains = list(/obj/item/stack/sheet/plasteel/twenty)
	crate_name = "skrzynia z arkuszami plastali"

/datum/supply_pack/materials/plasteel50
	name = "50 arkuszy plastali"
	desc = "Na wypadek, gdy NAPRAWDĘ musisz coś wzmocnić."
	cost = 14000 // 20% discount
	contains = list(/obj/item/stack/sheet/plasteel/fifty)
	crate_name = "skrzynia z arkuszami plastali"

/datum/supply_pack/materials/copper20
	name = "20 arkuszy miedzi"
	desc = "Twoje podłogi będą ładnie wyglądać, a obwody – działać!"
	cost = 1000
	contains = list(/obj/item/stack/sheet/mineral/copper/twenty)
	crate_name = "skrzynia z arkuszami miedzi"

/datum/supply_pack/materials/copper50
	name = "50 arkuszy miedzi"
	desc = "Twoje podłogi będą ładnie wyglądać, a obwody – działać!"
	cost = 1600 //20% discount
	contains = list(/obj/item/stack/sheet/mineral/copper/fifty)
	crate_name = "hurtowa skrzynia arkuszy miedzi"

/datum/supply_pack/materials/plastic50
	name = "50 arkuszy plastiku"
	desc = "Zbuduj nieograniczoną liczbę zabawek z pięćdziesięciu arkuszy plastiku!"
	cost = 800
	contains = list(/obj/item/stack/sheet/plastic/fifty)
	crate_name = "skrzynia z arkuszami plastiku"

/datum/supply_pack/materials/sandstone30
	name = "30 bloków piaskowca"
	desc = "Ani piaszczyste, ani kamienne, ale te trzydzieści bloków i tak spełni swoje zadanie."
	cost = 800
	contains = list(/obj/item/stack/sheet/mineral/sandstone/thirty)
	crate_name = "skrzynia z blokami piaskowca"

/datum/supply_pack/materials/wood50
	name = "50 desek"
	desc = "Zamień nudne metalowe podłoże zaopatrzenia w piękną drewnianą podłogę i wiele więcej dzięki pięćdziesięciu deskom!"
	cost = 1700
	contains = list(/obj/item/stack/sheet/mineral/wood/fifty)
	crate_name = "skrzynia z deskami"

/datum/supply_pack/materials/bz
	name = "Skrzynia z kanistrem BZ"
	desc = "Zawiera kanister BZ. Do otwarcia wymaga dostępu atmosferyki."
	cost = 8000
	access = ACCESS_ATMOSPHERICS
	access_budget = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/bz)
	crate_name = "skrzynia z kanistrem BZ"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/materials/carbon_dio
	name = "Kanister dwutlenku węgla"
	desc = "Zawiera kanister dwutlenku węgla. Do otwarcia wymaga dostępu atmosferyki."
	cost = 1200
	access = ACCESS_ATMOSPHERICS
	access_budget = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	crate_name = "skrzynia z kanistrem dwutlenku węgla"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/materials/foamtank
	name = "Skrzynia ze zbiornikiem piany gaśniczej"
	desc = "Zawiera zbiornik piany gaśniczej, znanej też jako „zmora plazmaludzi”."
	cost = 1500
	contains = list(/obj/structure/reagent_dispensers/foamtank)
	crate_name = "skrzynia ze zbiornikiem piany"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/fueltank
	name = "Skrzynia ze zbiornikiem paliwa"
	desc = "Zawiera zbiornik paliwa spawalniczego. Uwaga, łatwopalne."
	cost = 800
	access_budget = ACCESS_ENGINE
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	crate_name = "skrzynia ze zbiornikiem paliwa"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/hightank
	name = "Skrzynia z dużym zbiornikiem wody"
	desc = "Zawiera pojemny zbiornik wody. Przydaje się w botanice i innych pracach służby."
	cost = 1200
	contains = list(/obj/structure/reagent_dispensers/watertank/high)
	crate_name = "skrzynia z pojemnym zbiornikiem wody"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/nitrogen
	name = "Kanister azotu"
	desc = "Zawiera kanister azotu."
	cost = 800
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	crate_name = "skrzynia z kanistrem azotu"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/nitrous_oxide_canister
	name = "Kanister podtlenku azotu"
	desc = "Zawiera kanister podtlenku azotu. Do otwarcia wymaga dostępu atmosferyki."
	cost = 2400
	access = ACCESS_ATMOSPHERICS
	access_budget = ACCESS_ATMOSPHERICS
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrous_oxide)
	crate_name = "skrzynia z kanistrem podtlenku azotu"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/materials/oxygen
	name = "Kanister tlenu"
	desc = "Zawiera kanister tlenu. Zapuszkowany w Druidii."
	cost = 800
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	crate_name = "skrzynia z kanistrem tlenu"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/watertank
	name = "Skrzynia ze zbiornikiem wody"
	desc = "Zawiera zbiornik monotlenku diwodoru... brzmi groźnie."
	cost = 750
	contains = list(/obj/structure/reagent_dispensers/watertank)
	crate_name = "skrzynia ze zbiornikiem wody"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/water_vapor
	name = "Kanister pary wodnej"
	desc = "Zawiera kanister pary wodnej. Przysięgam, jeśli otworzysz to na korytarzu..."
	cost = 2500
	contains = list(/obj/machinery/portable_atmospherics/canister/water_vapor)
	crate_name = "skrzynia z kanistrem pary wodnej"
	crate_type = /obj/structure/closet/crate/large

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Medical /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/medical
	group = "Medical"
	access_budget = ACCESS_MEDICAL
	crate_type = /obj/structure/closet/crate/medical

/datum/supply_pack/medical/bloodpacks
	name = "Skrzynia z różnymi workami krwi"
	desc = "Zawiera osiem różnych worków z krwią do przetaczania krwi pacjentom."
	cost = 700
	contains = list(/obj/item/reagent_containers/blood,
					/obj/item/reagent_containers/blood,
					/obj/item/reagent_containers/blood/APlus,
					/obj/item/reagent_containers/blood/AMinus,
					/obj/item/reagent_containers/blood/BPlus,
					/obj/item/reagent_containers/blood/BMinus,
					/obj/item/reagent_containers/blood/OPlus,
					/obj/item/reagent_containers/blood/OMinus,
					/obj/item/reagent_containers/blood/lizard,
					/obj/item/reagent_containers/blood/ethereal,
					/obj/item/reagent_containers/blood/oozeling)
	crate_name = "zamrażarka z krwią"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/medical/synthflesh
	name = "Uzupełnienie syntetycznego ciała"
	desc = "Zawiera cztery kartony po 100 j. syntetycznego ciała na wypadek, gdyby w klonerze go zabrakło."
	cost = 1400
	contains = list(/obj/item/reagent_containers/food/drinks/bottle/synthflesh,
					/obj/item/reagent_containers/food/drinks/bottle/synthflesh,
					/obj/item/reagent_containers/food/drinks/bottle/synthflesh,
					/obj/item/reagent_containers/food/drinks/bottle/synthflesh)
	crate_name = "zardzewiała zamrażarka"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/medical/basickits
	name = "Skrzynia podstawowych apteczek"
	desc = "Zawiera trzy podstawowe apteczki, które w prosty sposób leczą podstawowe rodzaje obrażeń."
	cost = 1400
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular)
	crate_name = "skrzynia z podstawowymi apteczkami"

/datum/supply_pack/medical/bruisekits
	name = "Skrzynia apteczek na urazy"
	desc = "Zawiera trzy apteczki pierwszej pomocy do leczenia stłuczeń i złamań."
	cost = 1400
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/brute)
	crate_name = "skrzynia z apteczkami na urazy"

/datum/supply_pack/medical/burnkits
	name = "Skrzynia apteczek na oparzenia"
	desc = "Zawiera trzy apteczki pierwszej pomocy do leczenia ciężkich oparzeń."
	cost = 1400
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire)
	crate_name = "skrzynia z apteczkami na oparzenia"

/datum/supply_pack/medical/oxylosskits
	name = "Skrzynia apteczek na niedotlenienie"
	desc = "Zawiera trzy apteczki pierwszej pomocy do ratowania ofiar niedotlenienia."
	cost = 1400
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2)
	crate_name = "skrzynia z apteczkami na niedotlenienie"

/datum/supply_pack/medical/toxinkits
	name = "Skrzynia apteczek na toksyny"
	desc = "Zawiera trzy apteczki pierwszej pomocy do leczenia obrażeń od silnych toksyn."
	cost = 1400
	small_item = TRUE
	contains = list(/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin)
	crate_name = "skrzynia z apteczkami na toksyny"

/datum/supply_pack/medical/chemical
	name = "Skrzynia startowa chemika"
	desc = "Zawiera trzynaście różnych substancji chemicznych do wszystkich zabawnych eksperymentów, jakie przyjdą ci do głowy."
	cost = 1000
	contains = list(/obj/item/reagent_containers/glass/bottle/hydrogen,
					/obj/item/reagent_containers/glass/bottle/carbon,
					/obj/item/reagent_containers/glass/bottle/nitrogen,
					/obj/item/reagent_containers/glass/bottle/oxygen,
					/obj/item/reagent_containers/glass/bottle/fluorine,
					/obj/item/reagent_containers/glass/bottle/phosphorus,
					/obj/item/reagent_containers/glass/bottle/silicon,
					/obj/item/reagent_containers/glass/bottle/chlorine,
					/obj/item/reagent_containers/glass/bottle/radium,
					/obj/item/reagent_containers/glass/bottle/sacid,
					/obj/item/reagent_containers/glass/bottle/ethanol,
					/obj/item/reagent_containers/glass/bottle/potassium,
					/obj/item/reagent_containers/glass/bottle/sugar,
					/obj/item/clothing/glasses/science,
					/obj/item/reagent_containers/dropper,
					/obj/item/storage/box/beakers)
	crate_name = "skrzynia z chemikaliami"

/datum/supply_pack/medical/defibs
	name = "Skrzynia defibrylatorów"
	desc = "Zawiera dwa defibrylatory do przywracania do życia niedawno zmarłych."
	cost = 1800
	contains = list(/obj/item/defibrillator/loaded,
					/obj/item/defibrillator/loaded)
	crate_name = "skrzynia z defibrylatorami"

/datum/supply_pack/medical/iv_drip
	name = "Skrzynia kroplówek"
	desc = "Zawiera trzy kroplówki do podawania pacjentom krwi."
	cost = 800
	contains = list(/obj/machinery/iv_drip,
					/obj/machinery/iv_drip,
					/obj/machinery/iv_drip)
	crate_name = "skrzynia z kroplówkami"

/datum/supply_pack/medical/supplies
	name = "Skrzynia zaopatrzenia medycznego"
	desc = "Zawiera po trochu wszystkiego, czego trzeba do zaopatrzenia ambulatorium albo założenia własnego."
	cost = 2000
	contains = list(/obj/item/reagent_containers/glass/bottle/charcoal,
					/obj/item/reagent_containers/glass/bottle/epinephrine,
					/obj/item/reagent_containers/glass/bottle/morphine,
					/obj/item/reagent_containers/glass/bottle/toxin,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/reagent_containers/pill/insulin,
					/obj/item/stack/medical/gauze,
					/obj/item/storage/box/beakers,
					/obj/item/storage/box/medsprays,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/bodybags,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/fire,
					/obj/item/defibrillator/loaded,
					/obj/item/reagent_containers/blood/OMinus,
					/obj/item/storage/pill_bottle/mining,
					/obj/item/reagent_containers/pill/neurine,
					/obj/item/vending_refill/medical)
	crate_name = "skrzynia z zaopatrzeniem medycznym"

/datum/supply_pack/medical/supplies/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 10)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/medical/surgery
	name = "Skrzynia zaopatrzenia chirurgicznego"
	desc = "Chcesz przeprowadzać operacje, ale nie masz żadnego z tych wymyślnych dyplomów? Zacznij od tej skrzyni z medyczną torbą podróżną, sprayem ze sterylizyną i składanymi noszami na kółkach."
	cost = 900
	contains = list(/obj/item/storage/backpack/duffelbag/med/surgery,
					/obj/item/reagent_containers/medspray/sterilizine,
					/obj/item/roller)
	crate_name = "skrzynia z zaopatrzeniem chirurgicznym"

/datum/supply_pack/medical/salglucanister
	name = "Wytrzymały kanister z solą fizjologiczną"
	desc = "Zawiera hurtowy zapas soli fizjologicznej z glukozą w jednym kanistrze, który powinien wystarczyć na kilka dni, oraz dużą pompę do napełniania pojemników. Bezpośrednie wstrzykiwanie soli fizjologicznej najlepiej zostawić profesjonalistom, bo pompa może przedawkować pacjenta. Do otwarcia wymaga dostępu do ambulatorium."
	cost = 1200
	access = ACCESS_MEDICAL
	contains = list(/obj/machinery/iv_drip/saline)

/datum/supply_pack/medical/randomvirus
	name = "Skrzynia próbek wirusów"
	desc = "Zawiera pięć losowych eksperymentalnych kultur chorób do badań epidemiologicznych."
	cost = 3750
	access = ACCESS_VIROLOGY
	access_budget = ACCESS_VIROLOGY
	contains = list(/obj/item/reagent_containers/glass/bottle/random_virus,
					/obj/item/reagent_containers/glass/bottle/random_virus,
					/obj/item/reagent_containers/glass/bottle/random_virus,
					/obj/item/reagent_containers/glass/bottle/random_virus,
					/obj/item/reagent_containers/glass/bottle/random_virus)
	crate_name = "skrzynia z próbkami wirusów"
	crate_type = /obj/structure/closet/crate/secure/plasma
	dangerous = TRUE

/datum/supply_pack/medical/virology
	name = "Zestaw Młodego Epidemiologa"
	desc = "Zawiera zaopatrzenie potrzebne do uruchomienia laboratorium badań epidemiologicznych. P.A.N.D.E.M.I.C. nie jest dołączony. W zestawie figurka wirologa gratis!"
	cost = 1500
	access = ACCESS_VIROLOGY
	contains = list(/obj/item/food/monkeycube,
					/obj/item/reagent_containers/food/drinks/bottle/virusfood,
					/obj/item/reagent_containers/glass/bottle/mutagen,
					/obj/item/reagent_containers/glass/bottle/formaldehyde,
					/obj/item/reagent_containers/glass/bottle/synaptizine,
					/obj/item/storage/box/beakers,
					/obj/item/toy/figure/virologist)
	crate_name = "zestaw Młodego Epidemiologa"
	dangerous = TRUE

/datum/supply_pack/medical/vending
	name = "Skrzynia uzupełnień automatów medycznych"
	desc = "Zawiera jeden wkład uzupełniający NanoMed Plus i jeden do ściennego NanoMedu."
	cost = 1500
	contains = list(/obj/item/vending_refill/medical,
					/obj/item/vending_refill/wallmed)
	crate_name = "skrzynia z uzupełnieniami automatów medycznych"

/datum/supply_pack/medical/virus
	name = "Skrzynia wirusów"
	desc = "Zawiera kilka próbek zaraźliwych wirusów, od irytujących po śmiertelne. Zwinięte dżinsy nie są dołączone. Do otwarcia wymaga dostępu Ordynatora."
	cost = 2000
	access = ACCESS_CMO
	access_budget = ACCESS_VIROLOGY
	contraband = TRUE
	contains = list(/obj/item/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/reagent_containers/glass/bottle/magnitis,
					/obj/item/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/reagent_containers/glass/bottle/brainrot,
					/obj/item/reagent_containers/glass/bottle/anxiety,
					/obj/item/reagent_containers/glass/bottle/beesease)
	crate_name = "skrzynia z wirusami"
	crate_type = /obj/structure/closet/crate/secure/plasma
	dangerous = TRUE

/datum/supply_pack/medical/extrapolator
	name = "Skrzynia ekstrapolatorów wirusów"
	desc = "Zawiera 3 ekstrapolatory wirusów na wypadek, gdyby istniejące zginęły lub zostały zniszczone."
	cost = 4500
	access = ACCESS_VIROLOGY
	contains = list(/obj/item/extrapolator, /obj/item/extrapolator, /obj/item/extrapolator)
	crate_name = "skrzynia z ekstrapolatorami"
	crate_type = /obj/structure/closet/crate/secure/plasma
	dangerous = TRUE

/datum/supply_pack/medical/pandemic
	name = "Zapasowy P.A.N.D.E.M.I.C."
	desc = "Zawiera zapasowy P.A.N.D.E.M.I.C. na wypadek, gdyby ten w wirusologii został zniszczony albo chcesz zbudować nowe laboratorium."
	cost = 7500
	access = ACCESS_VIROLOGY
	contains = list(/obj/machinery/computer/pandemic)
	crate_name = "skrzynia z zapasowym P.A.N.D.E.M.I.C."
	dangerous = TRUE
//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Science /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/science
	group = "Science"
	access_budget = ACCESS_RESEARCH
	crate_type = /obj/structure/closet/crate/science

/datum/supply_pack/science/plasma
	name = "Skrzynia zespołów plazmowych"
	desc = "Wszystko, czego trzeba, by spalić coś do gołej ziemi: trzy zestawy zespołów plazmowych. Każdy zawiera butlę z plazmą, zapalnik, czujnik zbliżeniowy i zegar! Gwarancja traci ważność w wysokiej temperaturze. Do otwarcia wymaga dostępu do toksyn."
	cost = 800
	access = ACCESS_TOX_STORAGE
	access_budget = ACCESS_TOX_STORAGE
	contains = list(/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer)
	crate_name = "skrzynia z zespołami plazmowymi"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/science/robotics
	name = "Skrzynia do montażu robotów"
	desc = "Narzędzia, dzięki którym zastąpisz tych kapryśnych ludzi wierną armią robotów! Zawiera cztery czujniki zbliżeniowe, dwie puste apteczki, dwa analizatory zdrowia, dwa czerwone kaski, dwie mechaniczne skrzynki narzędziowe i dwa zespoły cleanbota! Do otwarcia wymaga dostępu robotyki."
	cost = 1200
	access = ACCESS_ROBOTICS
	access_budget = ACCESS_ROBOTICS
	contains = list(/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/storage/firstaid,
					/obj/item/storage/firstaid,
					/obj/item/healthanalyzer,
					/obj/item/healthanalyzer,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/bot_assembly/cleanbot,
					/obj/item/bot_assembly/cleanbot)
	crate_name = "skrzynia do montażu robotów"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/mod_core
	name = "Skrzynia rdzeni MOD"
	desc = "Trzy rdzenie, idealne do budowy dowolnego MODsuita! Oczywiście ze zbiorów naturalnych™."
	cost = 600
	access = ACCESS_ROBOTICS
	access_budget = ACCESS_ROBOTICS
	contains = list(/obj/item/mod/core/standard,
		/obj/item/mod/core/standard,
		/obj/item/mod/core/standard)
	crate_name = "skrzynia z rdzeniami MOD"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/recharging
	name = "Skrzynia ze stacją ładowania"
	desc = "Jeśli szukasz ulepszenia, które sprawi, że twoja stacja będzie przyjaźniejsza jednostkom krzemowym, ta paczka jest dla ciebie! Zawiera wszystkie materiały potrzebne do złożenia stacji ładowania. Narzędzia nie są dołączone."
	cost = 2500
	access = ACCESS_ROBOTICS
	contains = list(/obj/item/stack/sheet/iron/five,
					/obj/item/stack/cable_coil,
					/obj/item/circuitboard/machine/cyborgrecharger,
					/obj/item/stock_parts/capacitor,
					/obj/item/stock_parts/cell,
					/obj/item/stock_parts/manipulator)
	crate_name = "skrzynia ze stacją ładowania"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/inducers
	name = "Skrzynia induktorów NT-50"
	desc = "Brak ładowarek? Żaden problem: z NT-50 EPI naładujesz dowolny standardowy sprzęt zasilany ogniwem, kiedy chcesz i gdzie chcesz! Zawiera dwa naukowe induktory."
	cost = 1000
	contains = list(/obj/item/inducer/sci {cell_type = /obj/item/stock_parts/cell/inducer_supply; opened = 0}, /obj/item/inducer/sci {cell_type = /obj/item/stock_parts/cell/inducer_supply; opened = 0}) //FALSE doesn't work in modified type paths apparently.
	crate_name = "skrzynia z induktorami"

/datum/supply_pack/science/rped
	name = "Skrzynia z RPED"
	desc = "Musisz odbudować maszynę wymiany rudy, ale naukowców zmiotło po teście bomby? Kup to, a dostaniesz najbardziej zaawansowane części, jakie może ci dać NT."
	cost = 800
	access_budget = FALSE
	contains = list(/obj/item/storage/part_replacer/cargo)
	crate_name = "\improper skrzynia z RPED"

/datum/supply_pack/science/shieldwalls
	name = "Skrzynia generatorów tarczy"
	desc = "Te generatory ścian tarczy wysokiej mocy gwarantują, że wszelkie niechciane formy życia zostaną na zewnątrz, tam gdzie ich miejsce! Zawiera cztery generatory ścian tarczy. Do otwarcia wymaga dostępu do teleportera."
	cost = 1700
	access = ACCESS_TELEPORTER
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	crate_name = "skrzynia z generatorami tarczy"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/modularpc
	name = "Wkład uzupełniający Deluxe Silicate Selections"
	desc = "Co to jest komputer? Zawiera wkład uzupełniający Deluxe Silicate Selections."
	cost = 1200
	contains = list(/obj/item/vending_refill/modularpc)
	crate_name = "skrzynia z zaopatrzeniem komputerowym"

/datum/supply_pack/science/transfer_valves
	name = "Skrzynia zaworów transferowych"
	desc = "Kluczowy składnik, by bardzo szybko bardzo rozzłościć mnóstwo ludzi. Zawiera dwa zawory transferowe do butli. Do otwarcia wymaga dostępu Dyrektora Naukowego."
	cost = 4000
	access = ACCESS_RD
	contains = list(/obj/item/transfer_valve,
					/obj/item/transfer_valve)
	crate_name = "skrzynia z zaworami transferowymi"
	crate_type = /obj/structure/closet/crate/secure/science
	dangerous = TRUE

/datum/supply_pack/science/xenobio
	name = "Skrzynia laboratorium ksenobiologii"
	desc = "Na wypadek, gdyby niecodzienny wypadek unieruchomił laboratorium ksenobiologii! Zawiera dwa szare ekstrakty szlamu, trochę plazmy i płytki potrzebne do ponownego uruchomienia laboratorium! Do otwarcia wymaga dostępu ksenobiologii."
	cost = 10000
	access = ACCESS_XENOBIOLOGY
	access_budget = ACCESS_XENOBIOLOGY
	contains = list(/obj/item/slime_extract/grey,
					/obj/item/slime_extract/grey,
					/obj/item/reagent_containers/syringe/plasma,
					/obj/item/circuitboard/computer/xenobiology,
					/obj/item/circuitboard/machine/monkey_recycler,
					/obj/item/circuitboard/machine/processor/slime)
	crate_name = "skrzynia startowa ksenobiologii"
	crate_type = /obj/structure/closet/crate/secure/science

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////// Service //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/service
	group = "Service"

/datum/supply_pack/service/cargo_supples
	name = "Skrzynia zaopatrzenia magazynu"
	desc = "Sprzedaliście wszystko, co nie było przykręcone? Wrócisz do pracy dzięki tej skrzyni z pieczątkami, skanerem eksportowym, znacznikiem adresowym, etykieciarką i papierem do pakowania."
	cost = 700
	access_budget = ACCESS_CARGO
	contains = list(/obj/item/stamp,
					/obj/item/stamp/denied,
					/obj/item/export_scanner,
					/obj/item/dest_tagger,
					/obj/item/hand_labeler,
					/obj/item/stack/package_wrap)
	crate_name = "skrzynia z zaopatrzeniem magazynu"

/datum/supply_pack/service/noslipfloor
	name = "Antypoślizgowe płytki podłogowe"
	desc = "Niech poślizgnięcia odejdą w przeszłość dzięki trzydziestu przemysłowym antypoślizgowym płytkom podłogowym!"
	cost = 800
	access_budget = ACCESS_JANITOR
	contains = list(/obj/item/stack/tile/noslip/thirty)
	crate_name = "skrzynia z antypoślizgowymi płytkami"

/datum/supply_pack/service/noslipfloorbulk
	name = "Hurtowe antypoślizgowe płytki podłogowe"
	desc = "Oszczędź całemu działowi bólu poślizgnięcia na mokrej podłodze dzięki 120 antypoślizgowym płytkom podłogowym!"
	cost = 2000
	access_budget = ACCESS_JANITOR
	contains = list(/obj/item/stack/tile/noslip/thirty,
					/obj/item/stack/tile/noslip/thirty,
					/obj/item/stack/tile/noslip/thirty,
					/obj/item/stack/tile/noslip/thirty)
	crate_name = "skrzynia z antypoślizgowymi płytkami"

/datum/supply_pack/service/janitor
	name = "Skrzynia środków czystości"
	desc = "Walcz z brudem i szlamem dzięki Niezbędnikowi Woźnego(tm) od Nanotrasen! Zawiera trzy wiadra, znaki ostrzegawcze i granaty czyszczące. Do tego jeden mop, miotła, spryskiwacz ze środkiem czyszczącym, szmata i worek na śmieci."
	cost = 800
	access_budget = ACCESS_JANITOR
	contains = list(/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/mop,
					/obj/item/pushbroom,
					/obj/item/clothing/suit/caution,
					/obj/item/clothing/suit/caution,
					/obj/item/clothing/suit/caution,
					/obj/item/storage/bag/trash,
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/reagent_containers/glass/rag,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner)
	crate_name = "skrzynia ze środkami czystości"

/datum/supply_pack/service/janitor/janicart
	name = "Skrzynia z wózkiem woźnego i kaloszami"
	desc = "Podstawa każdego dobrego woźnego. Dopóki masz stopy, te kalosze utrzymają je mocno na ziemi. Zawiera też wózek woźnego."
	cost = 1000
	access_budget = ACCESS_JANITOR
	contains = list(/obj/structure/janitorialcart,
					/obj/item/clothing/shoes/galoshes)
	crate_name = "skrzynia z wózkiem woźnego"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/janitor/janitank
	name = "Skrzynia z plecakiem woźnego"
	desc = "Ześlij boski sąd na brud i szlam dzięki temu pojemnemu plecakowi woźnego. Zawiera 500 j. środka czyszczącego, który wyczyści całą stację."
	cost = 700
	access_budget = ACCESS_JANITOR
	contains = list(/obj/item/watertank/janitor)
	crate_name = "skrzynia z plecakiem woźnego"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/service/mule
	name = "Skrzynia z MULEbotem"
	desc = "Różowowłosa Kwatermistrzyni nie wykonuje swojej pracy? Zastąp ją już dziś tym niestrudzonym pracownikiem!"
	cost = 1700
	access_budget = ACCESS_CARGO
	contains = list(/mob/living/simple_animal/bot/mulebot)
	crate_name = "\improper skrzynia z MULEbotem"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/party
	name = "Sprzęt imprezowy"
	desc = "Świętuj na stacji zarówno życie, jak i śmierć z Niezbędnikiem Imprezowym(tm) od Nanotrasen! Zawiera specjalną strefę imprezową, siedem kolorowych świetlików chemicznych, cztery piwa, dwa ale oraz butelkę patrona, goldschlagera i shaker!"
	cost = 1500
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/reagent_containers/food/drinks/shaker,
					/obj/item/reagent_containers/food/drinks/bottle/patron,
					/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/reagent_containers/food/drinks/ale,
					/obj/item/reagent_containers/food/drinks/ale,
					/obj/item/reagent_containers/food/drinks/beer,
					/obj/item/reagent_containers/food/drinks/beer,
					/obj/item/reagent_containers/food/drinks/beer,
					/obj/item/reagent_containers/food/drinks/beer,
					/obj/item/flashlight/glowstick,
					/obj/item/flashlight/glowstick/red,
					/obj/item/flashlight/glowstick/blue,
					/obj/item/flashlight/glowstick/cyan,
					/obj/item/flashlight/glowstick/orange,
					/obj/item/flashlight/glowstick/yellow,
					/obj/item/flashlight/glowstick/pink,
					/obj/item/survivalcapsule/party)
	crate_name = "skrzynia ze sprzętem imprezowym"

/datum/supply_pack/service/carpet
	name = "Skrzynia wykładzin premium"
	desc = "Płytki z plastali działają ci na nerwy? Te stosy wyjątkowo miękkiej wykładziny dopełnią każde pomieszczenie."
	cost = 700
	contains = list(/obj/item/stack/tile/carpet/fifty,
					/obj/item/stack/tile/carpet/fifty,
					/obj/item/stack/tile/carpet/black/fifty,
					/obj/item/stack/tile/carpet/black/fifty)
	crate_name = "skrzynia z wykładzinami premium"

/datum/supply_pack/service/carpet_exotic
	name = "Skrzynia egzotycznych wykładzin"
	desc = "Egzotyczne wykładziny prosto z Kosmicznej Rosji na wszystkie twoje potrzeby dekoratorskie. Zawiera po 100 płytek 8 różnych wzorów podłogi."
	cost = 2000
	contains = list(/obj/item/stack/tile/carpet/blue/fifty,
					/obj/item/stack/tile/carpet/blue/fifty,
					/obj/item/stack/tile/carpet/cyan/fifty,
					/obj/item/stack/tile/carpet/cyan/fifty,
					/obj/item/stack/tile/carpet/green/fifty,
					/obj/item/stack/tile/carpet/green/fifty,
					/obj/item/stack/tile/carpet/orange/fifty,
					/obj/item/stack/tile/carpet/orange/fifty,
					/obj/item/stack/tile/carpet/purple/fifty,
					/obj/item/stack/tile/carpet/purple/fifty,
					/obj/item/stack/tile/carpet/red/fifty,
					/obj/item/stack/tile/carpet/red/fifty,
					/obj/item/stack/tile/carpet/royalblue/fifty,
					/obj/item/stack/tile/carpet/royalblue/fifty,
					/obj/item/stack/tile/eighties/fifty,
					/obj/item/stack/tile/eighties/fifty,
					/obj/item/stack/tile/carpet/royalblack/fifty,
					/obj/item/stack/tile/carpet/royalblack/fifty)
	crate_name = "skrzynia z egzotycznymi wykładzinami"

/datum/supply_pack/service/lightbulbs
	name = "Zapasowe oświetlenie"
	desc = "Niech światło Eteru opromieni tę stację! A przynajmniej światło pięćdziesięciu sześciu świetlówek i dwudziestu ośmiu żarówek."
	cost = 800
	contains = list(/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed)
	crate_name = "zapasowe oświetlenie"

/datum/supply_pack/service/minerkit
	name = "Zestaw startowy górnika"
	desc = "Wszyscy górnicy zbyt szybko zginęli? Asystent chce posmakować życia poza stacją? Tak czy inaczej, ten zestaw najlepiej zmieni zwykłego członka załogi w maszynę do wydobywania rudy i zabijania potworów. Zawiera gogle mezonowe, kilof, zaawansowany skaner górniczy, słuchawki zaopatrzenia, torbę na rudę, maskę gazową, kombinezon górniczy i ulepszenie karty identyfikacyjnej górnika. Do otwarcia wymaga dostępu Kwatermistrza."
	cost = 800
	access = ACCESS_QM
	access_budget = ACCESS_MINING_STATION
	contains = list(/obj/item/storage/backpack/duffelbag/mining_conscript)
	crate_name = "zestaw startowy górnika"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/service/vending/bartending
	name = "Skrzynia uzupełnień Booze-o-mat i kawy"
	desc = "Wkłady uzupełniające do automatów z alkoholem i kawą."
	cost = 1200
	access_budget = ACCESS_BAR
	contains = list(/obj/item/vending_refill/boozeomat,
					/obj/item/vending_refill/coffee)
	crate_name = "skrzynia z zaopatrzeniem barowym"

/datum/supply_pack/service/vending/cigarette
	name = "Skrzynia uzupełnień papierosów"
	desc = "Nie wierz w raporty – zapal już dziś! Zawiera wkład uzupełniający do automatu z papierosami."
	cost = 1200
	contains = list(/obj/item/vending_refill/cigarette)
	crate_name = "skrzynia z zaopatrzeniem w papierosy"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/service/vending/dinnerware
	name = "Skrzynia zastawy stołowej"
	desc = "Więcej noży dla kucharza."
	cost = 800
	access_budget = ACCESS_KITCHEN
	contains = list(/obj/item/vending_refill/dinnerware)
	crate_name = "skrzynia z zastawą stołową"

/datum/supply_pack/service/vending/games
	name = "Skrzynia uzupełnień gier"
	desc = "Pograj sobie dzięki temu wkładowi uzupełniającemu do automatu z grami."
	cost = 800
	contains = list(/obj/item/vending_refill/games)
	crate_name = "skrzynia z zaopatrzeniem w gry"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/service/vending/imported
	name = "Importowane automaty"
	desc = "Automaty sprzedające słynne w innych częściach galaktyki."
	cost = 3000
	contains = list(/obj/item/vending_refill/sustenance,
					/obj/item/vending_refill/robotics,
					/obj/item/vending_refill/sovietsoda,
					/obj/item/vending_refill/engineering)
	crate_name = "nieoznaczona skrzynia zaopatrzenia"

/datum/supply_pack/service/vending/ptech
	name = "Skrzynia uzupełnień PTech"
	desc = "Brakuje dysków z programami, bo połowa załogi straciła PDA w wybuchach? To może pomóc."
	cost = 800
	access_budget = ACCESS_HOP
	contains = list(/obj/item/vending_refill/job_disk)
	crate_name = "skrzynia z zaopatrzeniem PTech"

/datum/supply_pack/service/vending/snack
	name = "Skrzynia uzupełnień przekąsek"
	desc = "Jeden wkład uzupełniający pełen dobroci, od której psują się zęby! Zamówienie numer jeden polecane przez dentystów!"
	cost = 800
	contains = list(/obj/item/vending_refill/snack)
	crate_name = "skrzynia z przekąskami"

/datum/supply_pack/service/vending/cola
	name = "Skrzynia uzupełnień napojów"
	desc = "Oberwałeś skrzynką narzędziową, a wciąż masz te uciążliwe zęby? Pozbądź się perłowej bieli już dziś dzięki temu wkładowi do automatu z napojami!"
	cost = 800
	contains = list(/obj/item/vending_refill/cola)
	crate_name = "skrzynia z napojami"

/datum/supply_pack/service/vending/vendomat
	name = "Skrzynia uzupełnień Vendomat"
	desc = "Więcej narzędzi do twojego poligonu testowego bomb domowej roboty."
	cost = 800
	contains = list(/obj/item/vending_refill/assist)
	crate_name = "skrzynia z zaopatrzeniem Vendomat"

/datum/supply_pack/service/randomized/donkpockets
	name = "Skrzynia z różnymi pierożkami Donk"
	desc = "Przegląd najpopularniejszych wypieków Donk Co.!"
	cost = 1500
	contains = list(/obj/item/storage/box/donkpockets/donkpocketspicy,
	/obj/item/storage/box/donkpockets/donkpocketteriyaki,
	/obj/item/storage/box/donkpockets/donkpocketpizza,
	/obj/item/storage/box/donkpockets/donkpocketgondola,//AQ EDIT
	/obj/item/storage/box/donkpockets/donkpocketberry,
	/obj/item/storage/box/donkpockets/donkpockethonk)
	crate_name = "skrzynia z pierożkami Donk"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Organic /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/organic
	group = "Food & Hydroponics"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/organic/hydroponics/beekeeping_suits
	name = "Skrzynia strojów pszczelarskich"
	desc = "Biznes pszczelarski kwitnie? Bądź bratem botaników i bezzwłocznie bierz bajeczne bluzy pszczelarza! Zawiera dwa stroje pszczelarskie i pasujące nakrycia głowy."
	cost = 800
	contains = list(/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	crate_name = "stroje pszczelarskie"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/hydroponics/beekeeping_fullkit
	name = "Startowa skrzynia pszczelarza"
	desc = "PSZCZOŁY PSZCZOŁY PSZCZOŁY. Zawiera trzy ramki na miód, strój i kapelusz pszczelarza, packę na muchy, ul i oczywiście rasową, ustandaryzowaną przez Nanotrasen królową pszczół!"
	cost = 1400
	contains = list(/obj/structure/beebox/unwrenched,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/queen_bee/bought,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/melee/flyswatter)
	crate_name = "startowa skrzynia pszczelarza"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/randomized/chef
	name = "Skrzynia wyśmienitego mięsa"
	desc = "Najlepsze kawałki w całej galaktyce."
	cost = 1700
	access_budget = ACCESS_KITCHEN
	contains = list(/obj/item/food/meat/slab/human/mutant/slime,
					/obj/item/food/meat/slab/killertomato,
					/obj/item/food/meat/slab/bear,
					/obj/item/food/meat/slab/xeno,
					/obj/item/food/meat/slab/spider,
					/obj/item/food/meat/rawbacon,
					/obj/item/food/meat/slab/penguin,
					/obj/item/food/spiderleg,
					/obj/item/food/fishmeat/carp,
					/obj/item/food/meat/slab/human)
	crate_name = "skrzynia z żywnością"

/datum/supply_pack/organic/randomized/chef/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 15)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/organic/exoticseeds
	name = "Skrzynia egzotycznych nasion"
	desc = "Marzenie każdego przedsiębiorczego botanika. Zawiera czternaście różnych nasion, w tym trzy nasiona strąka replikującego i dwa tajemnicze nasiona!"
	cost = 1000
	access_budget = ACCESS_HYDROPONICS
	contains = list(/obj/item/plant_seeds/preset/nettle,
					/obj/item/plant_seeds/preset/diona_pod,
					/obj/item/plant_seeds/preset/diona_pod,
					/obj/item/plant_seeds/preset/diona_pod,
					/obj/item/plant_seeds/preset/plump,
					/obj/item/plant_seeds/preset/liberty,
					/obj/item/plant_seeds/preset/amanita,
					/obj/item/plant_seeds/preset/reishi,
					/obj/item/plant_seeds/preset/banana,
					/obj/item/plant_seeds/preset/bamboo,
					/obj/item/plant_seeds/preset/eggy_plant,
					/obj/item/plant_seeds/preset/rainbow,
					/obj/item/plant_seeds/preset/rainbow)
	crate_name = "skrzynia z egzotycznymi nasionami"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/food
	name = "Skrzynia z żywnością"
	desc = "Rozkręć gotowanie dzięki tej skrzyni pełnej przydatnych składników! Zawiera tuzin jajek, trzy banany oraz trochę mąki, ryżu, mleka, mleka sojowego, soli, pieprzu, enzymu, cukru i mięsa małpy."
	cost = 1000
	access_budget = ACCESS_KITCHEN
	contains = list(/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/rice,
					/obj/item/reagent_containers/food/condiment/milk,
					/obj/item/reagent_containers/food/condiment/soymilk,
					/obj/item/reagent_containers/food/condiment/saltshaker,
					/obj/item/reagent_containers/food/condiment/peppermill,
					/obj/item/storage/fancy/egg_box,
					/obj/item/reagent_containers/food/condiment/enzyme,
					/obj/item/reagent_containers/food/condiment/sugar,
					/obj/item/food/meat/slab/monkey,
					/obj/item/food/grown/banana,
					/obj/item/food/grown/banana,
					/obj/item/food/grown/banana)
	crate_name = "skrzynia z żywnością"

/datum/supply_pack/organic/randomized/chef/fruits
	name = "Skrzynia owoców"
	desc = "Bogate w witaminy, mogą zawierać pomarańcze."
	cost = 1200
	access_budget = ACCESS_KITCHEN
	contains = list(/obj/item/food/grown/citrus/lime,
					/obj/item/food/grown/citrus/orange,
					/obj/item/food/grown/watermelon,
					/obj/item/food/grown/apple,
					/obj/item/food/grown/berries,
					/obj/item/food/grown/citrus/lemon)
	crate_name = "skrzynia z żywnością"

/datum/supply_pack/organic/cream_piee
	name = "Skrzynia wysokowydajnych tortów z kremem klasy klaunowskiej"
	desc = "Te wysokowydajne torty z kremem klasy klaunowskiej, zaprojektowane przez Dział Badań nad Zaawansowanymi Działaniami Wojennymi Aussec, łączą w synergii osiągi i wydajność. Gwarancja maksymalnych rezultatów."
	cost = 6000
	access = ACCESS_THEATRE
	access_budget = ACCESS_THEATRE
	contains = list(/obj/item/storage/backpack/duffelbag/clown/cream_pie)
	crate_name = "skrzynia ze sprzętem imprezowym"
	contraband = TRUE
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/organic/hydroponics
	name = "Skrzynia hydroponiczna"
	desc = "Zaopatrzenie do uprawy wspaniałego ogrodu! Zawiera dwie butelki amoniaku, dwa spryskiwacze z Plant-B-Gone, toporek, kultywator, analizator roślin, a także parę skórzanych rękawic i fartuch botanika."
	cost = 800
	access_budget = ACCESS_HYDROPONICS
	contains = list(/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/hatchet,
					/obj/item/cultivator,
					/obj/item/plant_scanner,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron,
					/obj/item/storage/box/disks_plantgene)
	crate_name = "skrzynia hydroponiczna"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/hydroponics/hydrotank
	name = "Skrzynia z plecakiem hydroponicznym"
	desc = "Wywołaj powódź dzięki tej skrzyni z pojemnym plecakiem. Zawiera 500 j. życiodajnego H2O. Do otwarcia wymaga dostępu hydroponiki."
	cost = 700
	contains = list(/obj/item/watertank)
	crate_name = "skrzynia z plecakiem hydroponicznym"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/organic/pizza
	name = "Skrzynia pizzy"
	desc = "Po co iść do kuchni, skoro możesz mieć pięć losowych pizz w ułamku tego czasu? \
		Najlepsze ceny po tej stronie galaktyki! Gwarantujemy, że wszystkie dostawy są w 99% wolne od anomalii."
	cost = 5000 // Best prices this side of the galaxy.
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable,
					/obj/item/pizzabox/pineapple)
	crate_name = "skrzynia z pizzą"
	///Whether we've provided an infinite pizza box already this shift or not.
	var/static/anomalous_box_provided = FALSE
	///The percentage chance (per pizza) of this supply pack to spawn an anomalous pizza box.
	var/anna_molly_box_chance = 1
	///Total tickets in our figurative lottery (per pizza) to decide if we create a bomb box, and if so what type. 1 to 3 create a bomb. The rest do nothing.
	var/boombox_tickets = 100
	///Whether we've provided a bomb pizza box already this shift or not.
	var/boombox_provided = FALSE

/datum/supply_pack/organic/pizza/fill(obj/structure/closet/crate/C)
	. = ..()

	var/list/pizza_types = list(
		/obj/item/food/pizza/margherita = 10,
		/obj/item/food/pizza/meat = 10,
		/obj/item/food/pizza/mushroom = 10,
		/obj/item/food/pizza/vegetable = 10,
		/obj/item/food/pizza/donkpocket = 10,
		/obj/item/food/pizza/dank = 7,
		/obj/item/food/pizza/sassysage = 10,
		/obj/item/food/pizza/pineapple = 10,
		/obj/item/food/pizza/arnold = 3
	) //weighted by chance to disrupt eaters' rounds

	for(var/obj/item/pizzabox/P in C)
		if(!anomalous_box_provided)
			if(prob(anna_molly_box_chance)) //1% chance for each box, so 4% total chance per order
				var/obj/item/pizzabox/infinite/fourfiveeight = new(C)
				fourfiveeight.boxtag = P.boxtag
				fourfiveeight.boxtag_set = TRUE
				fourfiveeight.update_icon()
				qdel(P)
				anomalous_box_provided = TRUE
				log_game("An anomalous pizza box was provided in a pizza crate at during cargo delivery")
				if(prob(50))
					addtimer(CALLBACK(src, PROC_REF(anomalous_pizza_report)), rand(300, 1800))
				else
					message_admins("W dostawie skrzyni pizzy po cichu utworzono anomalne pudełko po pizzy, bez raportu Centrali.")
				continue

		if(!boombox_provided)
			var/boombox_lottery = rand(1,boombox_tickets)
			var/boombox_type
			switch(boombox_lottery)
				if(1 to 2)
					boombox_type = /obj/item/pizzabox/bomb/armed //explodes after opening
				if(3)
					boombox_type = /obj/item/pizzabox/bomb //free bomb

			if(boombox_type)
				new boombox_type(C)
				qdel(P)
				boombox_provided = TRUE
				log_game("A bomb pizza box was created by a pizza crate delivery.")
				message_admins("W dostawie skrzyni pizzy przybyło pudełko po pizzy z bombą.")
				continue

		//here we randomly replace our pizzas for a chance at the full range
		var/obj/item/food/pizza/replacement_type = pickweight(pizza_types)
		pizza_types -= replacement_type
		if(replacement_type && !istype(P.pizza, replacement_type))
			QDEL_NULL(P.pizza)
			P.pizza = new replacement_type
			P.boxtag = P.pizza.boxtag
			P.boxtag_set = TRUE
			P.update_icon()

/datum/supply_pack/organic/pizza/proc/anomalous_pizza_report()
	print_command_report("[station_name()], nasz dział materiałów anomalnych zgłosił zaginięcie obiektu, który najprawdopodobniej trafił na waszą stację podczas rutynowej dostawy zaopatrzenia. Przeszukajcie wszystkie skrzynie i manifesty dostarczone z dostawą i zwróćcie obiekt, jeśli go znajdziecie. Obiekt przypomina standardowy <b>\[DANE USUNIĘTE\]</b>, należy go uznać za <b>\[UTAJNIONE\]</b> i zwrócić w dogodnym czasie. Uwaga: obiekty wytwarzane przez anomalię są dostrojone dokładnie do osoby, która ją otwiera; niezależnie od gatunku osoba ta uzna obiekt za jadalny i będzie on smakował wybornie według jej osobistych upodobań, które znacznie się różnią w zależności od osoby i gatunku.")

/datum/supply_pack/organic/potted_plants
	name = "Skrzynia roślin doniczkowych"
	desc = "Upiększ stację tymi uroczymi roślinami! Zawiera losowy zestaw pięciu roślin doniczkowych z działu badań nad roślinami doniczkowymi Nanotrasen. Gwarancja traci ważność po rzuceniu."
	cost = 550
	contains = list(/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random)
	crate_name = "skrzynia z roślinami doniczkowymi"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/seeds
	name = "Skrzynia nasion"
	desc = "Wielkie rzeczy mają małe początki. Zawiera czternaście różnych nasion."
	cost = 800
	contains = list(/obj/item/plant_seeds/preset/chili,
					/obj/item/plant_seeds/preset/cotton,
					/obj/item/plant_seeds/preset/berry,
					/obj/item/plant_seeds/preset/corn,
					/obj/item/plant_seeds/preset/eggplant,
					/obj/item/plant_seeds/preset/tomato,
					/obj/item/plant_seeds/preset/soybean,
					/obj/item/plant_seeds/preset/wheat,
					/obj/item/plant_seeds/preset/rice,
					/obj/item/plant_seeds/preset/carrot,
					/obj/item/plant_seeds/preset/sunflower,
					/obj/item/plant_seeds/preset/chanterelle,
					/obj/item/plant_seeds/preset/potato,
					/obj/item/plant_seeds/preset/sugarcane)
	crate_name = "skrzynia z nasionami"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/randomized/chef/vegetables
	name = "Skrzynia warzyw"
	desc = "Wyhodowane w kadziach."
	cost = 1000
	access_budget = ACCESS_KITCHEN
	contains = list(/obj/item/food/grown/chili,
					/obj/item/food/grown/corn,
					/obj/item/food/grown/tomato,
					/obj/item/food/grown/potato,
					/obj/item/food/grown/carrot,
					/obj/item/food/grown/mushroom/chanterelle,
					/obj/item/food/grown/onion,
					/obj/item/food/grown/pumpkin)
	crate_name = "skrzynia z żywnością"

/datum/supply_pack/organic/vending/hydro_refills
	name = "Uzupełnienia automatów hydroponicznych"
	desc = "Na wypadek, gdy klaun zabierze wszystkie nasiona bananów. Zawiera wkład uzupełniający NutriMax i wkład do MegaSeed Servitor."
	cost = 1700
	access_budget = ACCESS_HYDROPONICS
	crate_type = /obj/structure/closet/crate
	contains = list(/obj/item/vending_refill/hydroseeds,
					/obj/item/vending_refill/hydronutrients)
	crate_name = "skrzynia z zaopatrzeniem hydroponicznym"

/datum/supply_pack/organic/grill
	name = "Startowy zestaw grillowy"
	desc = "Tato, jestem głodny. Cześć, Głodny, jestem NOWYM STARTOWYM ZESTAWEM GRILLOWYM ZA JEDYNE 5000 KREDYTÓW, KUP TERAZ! Zawiera grill i paliwo."
	cost = 5000
	crate_type = /obj/structure/closet/crate
	contains = list(/obj/item/stack/sheet/mineral/coal/five,
					/obj/machinery/grill/unwrenched,
					/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy
					)
	crate_name = "skrzynia ze startowym zestawem grillowym"

/datum/supply_pack/organic/grillfuel
	name = "Zestaw paliwa do grilla"
	desc = "Zawiera propan i akcesoria do propanu. (Uwaga: nie zawiera prawdziwego propanu)."
	cost = 2000
	crate_type = /obj/structure/closet/crate
	contains = list(/obj/item/stack/sheet/mineral/coal/ten,
					/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy
					)
	crate_name = "skrzynia z zestawem paliwa do grilla"

/datum/supply_pack/organic/beefbroth

	name = "Hurtowa skrzynia rosołu wołowego"
	desc = "Nikt tak naprawdę nie chce zamawiać rosołu wołowego, więc sprzedajemy go hurtem!"
	cost = 5000
	contraband = TRUE
	crate_type = /obj/structure/closet/crate
	contains = list(/obj/item/food/canned/beefbroth,
					/obj/item/food/canned/beefbroth,
					/obj/item/food/canned/beefbroth,
					/obj/item/food/canned/beefbroth,
					/obj/item/food/canned/beefbroth,
					/obj/item/food/canned/beefbroth,
					/obj/item/food/canned/beefbroth,
					/obj/item/food/canned/beefbroth,
					/obj/item/food/canned/beefbroth,
					/obj/item/food/canned/beefbroth
					)
	crate_name = "skrzynia rosołu wołowego"
//////////////////////////////////////////////////////////////////////////////
////////////////////////////// Livestock /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/critter
	group = "Livestock"
	crate_type = /obj/structure/closet/crate/critter

/datum/supply_pack/critter/parrot
	name = "Skrzynia ptaków"
	desc = "Zawiera pięć wykwalifikowanych ptaków telekomunikacyjnych."
	cost = 4000
	contains = list(/mob/living/simple_animal/parrot)
	crate_name = "skrzynia z papugami"

/datum/supply_pack/critter/parrot/generate()
	. = ..()
	for(var/i in 1 to 4)
		new /mob/living/simple_animal/parrot(.)
	if(prob(1))
		new /mob/living/simple_animal/parrot/clock_hawk(.)

/datum/supply_pack/critter/butterfly
	name = "Skrzynia motyli"
	desc = "Niezbyt groźne owady, ale dają lepsze wrażenie niż, dajmy na to, muchy czy karaluchy."//is that a motherfucking worm reference
	contraband = TRUE
	cost = 5000
	contains = list(/mob/living/simple_animal/butterfly)
	crate_name = "skrzynia z okazami entomologicznymi"

/datum/supply_pack/critter/butterfly/generate()
	. = ..()
	for(var/i in 1 to 49)
		new /mob/living/simple_animal/butterfly(.)

/datum/supply_pack/critter/cat
	name = "Skrzynia z kotem"
	desc = "Kotek robi miau! W zestawie obroża i ładna zabawka dla kota! Cheeseburger nie jest dołączony."//i can't believe im making this reference
	cost = 5000 //Cats are worth as much as corgis.
	contains = list(/mob/living/simple_animal/pet/cat,
					/obj/item/clothing/neck/petcollar,
					/obj/item/toy/cattoy)
	crate_name = "skrzynia z kotem"

/datum/supply_pack/critter/cat/generate()
	. = ..()
	if(prob(50))
		var/mob/living/simple_animal/pet/cat/C = locate() in .
		qdel(C)
		new /mob/living/simple_animal/pet/cat/Proc(.)

/datum/supply_pack/critter/cat/exotic
	name = "Skrzynia z egzotycznym kotem"
	desc = "W zestawie jeden z egzotycznych kotów, obroża i zabawka."
	cost = 5500
	contains = list(/obj/item/clothing/neck/petcollar,
					/obj/item/toy/cattoy)
	crate_name = "skrzynia z kotem"

/datum/supply_pack/critter/cat/exotic/generate()
	. = ..()
	switch(rand(1, 5))
		if(1)
			new /mob/living/simple_animal/pet/cat/original(.)
		if(2)
			new /mob/living/simple_animal/pet/cat/breadcat(.)
		if(3)
			new /mob/living/simple_animal/pet/cat/cak(.)
		if(4)
			new /mob/living/simple_animal/pet/cat/space(.)
		if(5)
			new /mob/living/simple_animal/pet/cat/halal(.)

/datum/supply_pack/critter/chick
	name = "Skrzynia z kurą"
	desc = "Kura robi ko-ko!"
	cost = 2000
	contains = list( /mob/living/simple_animal/chick)
	crate_name = "skrzynia z kurą"

/datum/supply_pack/critter/corgi
	name = "Skrzynia z corgim"
	desc = "Tysiące naukowców uznają ją za optymalną rasę psa. Ten corgi to zaledwie jeden z milionów psów ze szlachetnego rodu Iana. W zestawie urocza obroża!"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/dog/corgi,
					/obj/item/clothing/neck/petcollar)
	crate_name = "skrzynia z corgim"

/datum/supply_pack/critter/corgi/generate()
	. = ..()
	if(prob(50))
		var/mob/living/simple_animal/pet/dog/corgi/D = locate() in .
		if(D.gender == FEMALE)
			qdel(D)
			new /mob/living/simple_animal/pet/dog/corgi/Lisa(.)

/datum/supply_pack/critter/cow
	name = "Skrzynia z krową"
	desc = "Krowa robi muu!"
	cost = 3000
	contains = list(/mob/living/simple_animal/cow)
	crate_name = "skrzynia z krową"

/datum/supply_pack/critter/crab
	name = "Krabia rakieta"
	desc = "KRAAAAAAABIA RAKIETA. KRABIA RAKIETA. KRABIA RAKIETA. KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB RAKIETA. ZRÓB. RAKIETĘ. KUP. ZRÓB RAKIETĘ. KRABIA RAKIEEETA. KRABIA RAKIEEEETA. KRAB KRAB KRAB KRAB KRAB KRAB KRAB KRAB RAKIEEEEEEEEEEEEEEEEEEEEEEEEE EEEEEEEEEEEEEEEEEEEEEEEEE EEEETTTTTTTTTTTTAAAAAAAAA AAAHHHHHHHHHHHHH. KRABIA RAKIETA. KRAAABIA RAKIEEEEEEEEEGGGGHHHHTA KRAB KRAB KRAABIARAKIETA KRABIA RAKIEEEETA."//fun fact: i actually spent like 10 minutes and transcribed the entire video.
	cost = 5000
	contains = list(/mob/living/simple_animal/crab)
	crate_name = "patrz pan, darmowe kraby"
	DropPodOnly = TRUE

/datum/supply_pack/critter/crab/generate()
	. = ..()
	for(var/i in 1 to 49)
		new /mob/living/simple_animal/crab(.)

/datum/supply_pack/critter/corgis/exotic
	name = "Skrzynia z egzotycznym corgim"
	desc = "Corgi godne króla. Mają wyjątkowe umaszczenie, które podkreśla ich wyższość. W zestawie urocza obroża!"
	cost = 5500
	contains = list(/mob/living/simple_animal/pet/dog/corgi/exoticcorgi,
					/obj/item/clothing/neck/petcollar)
	crate_name = "skrzynia z egzotycznym corgim"

/datum/supply_pack/critter/fox
	name = "Skrzynia z lisem"
	desc = "A lis robi...? W zestawie obroża!"//what does the fox say
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/fox,
					/obj/item/clothing/neck/petcollar)
	crate_name = "skrzynia z lisem"

/datum/supply_pack/critter/goat
	name = "Skrzynia z kozą"
	desc = "Koza robi mee! Gwarancja traci ważność, jeśli posłuży jako zastępstwo za Pete'a."
	cost = 2500
	contains = list(/mob/living/simple_animal/hostile/retaliate/goat)
	crate_name = "skrzynia z kozą"

/datum/supply_pack/critter/mothroach
	name = "Skrzynia z ćmokaraluchem"
	desc = "Połóż sobie ćmokaralucha na głowie i przekonaj się, jak wygląda prawdziwa słodycz."
	cost = 5000
	contains = list(/mob/living/simple_animal/mothroach)
	crate_name = "skrzynia z ćmokaraluchem"

/datum/supply_pack/critter/monkey
	name = "Skrzynia małpich kostek"
	desc = "Przestań się małpować! Zawiera pięć małpich kostek. Wystarczy dodać wody!"
	cost = 1000
	contains = list (/obj/item/storage/box/monkeycubes)
	crate_type = /obj/structure/closet/crate
	crate_name = "skrzynia z małpimi kostkami"
	small_item = TRUE

/datum/supply_pack/critter/pug
	name = "Skrzynia z mopsem"
	desc = "Jak zwykły pies, tylko... spłaszczony. W zestawie ładna obroża!"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/dog/pug,
					/obj/item/clothing/neck/petcollar)
	crate_name = "skrzynia z mopsem"

/datum/supply_pack/critter/sheep
	name = "Skrzynia z owcą"
	desc = "Owca robi bee!"
	cost = 2000
	contains = list(/mob/living/simple_animal/sheep)
	crate_name = "skrzynia z owcą"

/datum/supply_pack/critter/bullterrier
	name = "Skrzynia z bulterierem"
	desc = "Jak zwykły pies, tylko z głową w kształcie jajka. W zestawie ładna obroża!"
	cost = 5000
	contains = list(/mob/living/simple_animal/pet/dog/bullterrier,
					/obj/item/clothing/neck/petcollar)
	crate_name = "skrzynia z bulterierem"

/datum/supply_pack/critter/snake
	name = "Skrzynia węży"
	desc = "Masz dość tych PIERDOLONYCH węży na tej PIERDOLONEJ stacji kosmicznej? To ta skrzynia nie jest dla ciebie. Zawiera trzy jadowite węże."
	cost = 3000
	access_budget = ACCESS_SECURITY
	contains = list(/mob/living/simple_animal/hostile/retaliate/poison/snake,
					/mob/living/simple_animal/hostile/retaliate/poison/snake,
					/mob/living/simple_animal/hostile/retaliate/poison/snake)
	crate_name = "skrzynia z wężami"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Costumes & Toys /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/costumes_toys
	group = "Costumes & Toys"

/datum/supply_pack/costumes_toys/randomised
	name = "Skrzynia kolekcjonerskich kapeluszy"
	desc = "Pochwal się swoim statusem dzięki trzem unikatowym, bardzo poszukiwanym przez kolekcjonerów kapeluszom!"
	cost = 20000
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/HoS,
					/obj/item/clothing/head/collectable/HoP,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	crate_name = "skrzynia z kolekcjonerskimi kapeluszami"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/contraband
	name = "Skrzynia kontrabandy"
	desc = "Pssst... kolego... chcesz trochę kontrabandy? Załatwię ci plakat, porządne fajki, zielsko, nawet trochę sponsorowanych rzeczy... no wiesz, dobry towar. Tylko trzymaj to z dala od glin, dobra?"
	contraband = TRUE
	cost = 3000
	num_contained = 7
	contains = list(/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband,
					/obj/item/food/grown/cannabis,
					/obj/item/food/grown/cannabis/rainbow,
					/obj/item/food/grown/cannabis/white,
					/obj/item/storage/pill_bottle/zoom,
					/obj/item/storage/pill_bottle/happy,
					/obj/item/storage/pill_bottle/lsd,
					/obj/item/storage/pill_bottle/aranesp,
					/obj/item/storage/pill_bottle/stimulant,
					/obj/item/toy/cards/deck/syndicate,
					/obj/item/reagent_containers/food/drinks/bottle/absinthe,
					/obj/item/clothing/under/syndicate/tacticool,
					/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
					/obj/item/storage/fancy/cigarettes/cigpack_shadyjims,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/neck/necklace/dope,
					/obj/item/vending_refill/donksoft)
	crate_name = "skrzynia"

/datum/supply_pack/costumes_toys/foamforce
	name = "Skrzynia Foam Force"
	desc = "Wyciągnij grube działa: osiem strzelb Foam Force!"
	cost = 1000
	contains = list(/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy,
					/obj/item/gun/ballistic/shotgun/toy)
	crate_name = "skrzynia Foam Force"

/datum/supply_pack/costumes_toys/foamforce/bonus
	name = "Skrzynia pistoletów Foam Force"
	desc = "Pssst... hej, kolego... pamiętasz te stare pistolety Foam Force, które wycofano, bo były za fajne? No to mam tu dwa takie z twoim imieniem. Dorzucę nawet zapasowy magazynek do każdego, co ty na to?"
	contraband = TRUE
	cost = 4000
	contains = list(/obj/item/gun/ballistic/automatic/toy/pistol,
					/obj/item/gun/ballistic/automatic/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol)
	crate_name = "skrzynia Foam Force"

/datum/supply_pack/costumes_toys/formalwear
	name = "Skrzynia strojów wizytowych"
	desc = "Spodoba ci się, jak wyglądasz, gwarantuję. Zawiera od groma eleganckich ciuchów."
	cost = 3000 //Lots of very expensive items. You gotta pay up to look good!
	contains = list(/obj/item/clothing/under/dress/blacktango,
					/obj/item/clothing/under/misc/assistantformal,
					/obj/item/clothing/under/misc/assistantformal,
					/obj/item/clothing/under/rank/civilian/lawyer/bluesuit,
					/obj/item/clothing/suit/toggle/lawyer,
					/obj/item/clothing/under/rank/civilian/lawyer/purpsuit,
					/obj/item/clothing/suit/toggle/lawyer/purple,
					/obj/item/clothing/suit/toggle/lawyer/black,
					/obj/item/clothing/accessory/waistcoat,
					/obj/item/clothing/neck/tie/blue,
					/obj/item/clothing/neck/tie/red,
					/obj/item/clothing/neck/tie/black,
					/obj/item/clothing/head/bowler,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/head/flatcap,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/head/that,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/under/suit/charcoal,
					/obj/item/clothing/under/suit/navy,
					/obj/item/clothing/under/suit/burgundy,
					/obj/item/clothing/under/suit/checkered,
					/obj/item/clothing/under/suit/tan,
					/obj/item/lipstick/random)
	crate_name = "skrzynia ze strojami wizytowymi"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/clownpin
	name = "Skrzynia z przezabawną iglicą"
	desc = "Eee... sam nie wiem, co to właściwie robi. Chcesz kupić?"
	cost = 5000
	contraband = TRUE
	contains = list(/obj/item/firing_pin/clown)
	crate_name = "skrzynia z zabawkami" // It's /technically/ a toy. For the clown, at least.
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/lasertag
	name = "Skrzynia laser taga"
	desc = "Foam Force jest dla chłopców. Laser tag jest dla mężczyzn. Zawiera po trzy komplety czerwonych i niebieskich strojów, pasujące hełmy i pasujące pistolety do laser taga."
	cost = 1500
	contains = list(/obj/item/gun/energy/laser/redtag,
					/obj/item/gun/energy/laser/redtag,
					/obj/item/gun/energy/laser/redtag,
					/obj/item/gun/energy/laser/bluetag,
					/obj/item/gun/energy/laser/bluetag,
					/obj/item/gun/energy/laser/bluetag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm)
	crate_name = "skrzynia laser taga"

/datum/supply_pack/costumes_toys/lasertag/pins
	name = "Skrzynia iglic do laser taga"
	desc = "Trzy iglice do laser taga, używane w broni do laser taga, by mieć pewność, że użytkownicy noszą kamizelki."
	cost = 3000
	contraband = TRUE
	contains = list(/obj/item/storage/box/lasertagpins)
	crate_name = "skrzynia laser taga"

/datum/supply_pack/costumes_toys/costume_original
	name = "Skrzynia oryginalnych kostiumów"
	desc = "Odegraj sztuki Szekspira dzięki temu zestawowi strojów. Zawiera osiem różnych kostiumów!"
	cost = 1000
	contains = list(/obj/item/clothing/head/snowman,
					/obj/item/clothing/suit/snowman,
					/obj/item/clothing/head/chicken,
					/obj/item/clothing/suit/chickensuit,
					/obj/item/clothing/mask/gas/monkeymask,
					/obj/item/clothing/suit/monkeysuit,
					/obj/item/clothing/head/cardborg,
					/obj/item/clothing/suit/cardborg,
					/obj/item/clothing/head/xenos,
					/obj/item/clothing/suit/xenos,
					/obj/item/clothing/suit/hooded/ian_costume,
					/obj/item/clothing/suit/hooded/carp_costume,
					/obj/item/clothing/suit/hooded/bee_costume)
	crate_name = "skrzynia z oryginalnymi kostiumami"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/costume
	name = "Skrzynia standardowych kostiumów"
	desc = "Zaopatrz artystów stacji w narzędzia ich fachu dzięki tym kostiumom zatwierdzonym przez Nanotrasen! Zawiera pełny strój klauna i mima, a do tego trąbkę i butelkę niczego."
	cost = 1000
	access = ACCESS_THEATRE
	contains = list(/obj/item/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/civilian/clown,
					/obj/item/bikehorn,
					/obj/item/clothing/under/rank/civilian/mime,
					/obj/item/clothing/shoes/sneakers/black,
					/obj/item/clothing/gloves/color/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/frenchberet,
					/obj/item/clothing/suit/suspenders,
					/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing,
					/obj/item/storage/backpack/mime)
	crate_name = "skrzynia ze standardowymi kostiumami"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/toys
	name = "Skrzynia zabawek"
	desc = "Kogo obchodzi duma i poczucie osiągnięcia? Pomiń granie i przejdź od razu do słodkich nagród dzięki temu produktowi! Zawiera pięć losowych zabawek. Gwarancja traci ważność po użyciu do robienia psikusów dyrektorom naukowym."
	cost = 5000 // or play the arcade machines ya lazy bum
	num_contained = 5
	contains = list()
	crate_name = "skrzynia z zabawkami"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/toys/fill(obj/structure/closet/crate/C)
	var/the_toy
	for(var/i in 1 to num_contained)
		if(prob(50))
			the_toy = pickweight(GLOB.arcade_prize_pool)
		else
			the_toy = pick(subtypesof(/obj/item/toy/plush))
		new the_toy(C)

/datum/supply_pack/costumes_toys/wizard
	name = "Skrzynia z kostiumem czarodzieja"
	desc = "Udawaj, że wstępujesz do Federacji Czarodziejów, dzięki temu pełnemu strojowi czarodzieja! Nanotrasen przypomina pracownikom, że prawdziwe wstąpienie do Federacji Czarodziejów grozi rozwiązaniem umowy o pracę i zakończeniem życia."
	cost = 2000
	contains = list(/obj/item/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	crate_name = "skrzynia z kostiumem czarodzieja"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/fill(obj/structure/closet/crate/C)
	var/list/L = contains.Copy()
	for(var/i in 1 to num_contained)
		var/item = pick_n_take(L)
		new item(C)

/datum/supply_pack/costumes_toys/chess_white
	name = "Skrzynia białych figur szachowych"
	desc = "Patrzcie go, gra w grę dla nerdów wewnątrz gry dla nerdów!"
	cost = 800
	contains = list(
		/obj/item/cardboard_cutout/adaptive/chess/king,
		/obj/item/cardboard_cutout/adaptive/chess/queen,
		/obj/item/cardboard_cutout/adaptive/chess/rook,
		/obj/item/cardboard_cutout/adaptive/chess/rook,
		/obj/item/cardboard_cutout/adaptive/chess/knight,
		/obj/item/cardboard_cutout/adaptive/chess/knight,
		/obj/item/cardboard_cutout/adaptive/chess/bishop,
		/obj/item/cardboard_cutout/adaptive/chess/bishop,
		/obj/item/cardboard_cutout/adaptive/chess/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/pawn,
	)
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/chess_black
	name = "Skrzynia czarnych figur szachowych"
	desc = "Patrzcie go, gra w grę dla nerdów wewnątrz gry dla nerdów!"
	cost = 800
	contains = list(
		/obj/item/cardboard_cutout/adaptive/chess/black/king,
		/obj/item/cardboard_cutout/adaptive/chess/black/queen,
		/obj/item/cardboard_cutout/adaptive/chess/black/rook,
		/obj/item/cardboard_cutout/adaptive/chess/black/rook,
		/obj/item/cardboard_cutout/adaptive/chess/black/knight,
		/obj/item/cardboard_cutout/adaptive/chess/black/knight,
		/obj/item/cardboard_cutout/adaptive/chess/black/bishop,
		/obj/item/cardboard_cutout/adaptive/chess/black/bishop,
		/obj/item/cardboard_cutout/adaptive/chess/black/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/black/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/black/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/black/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/black/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/black/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/black/pawn,
		/obj/item/cardboard_cutout/adaptive/chess/black/pawn,
	)
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/costumes_toys/randomised/plush
	name = "Skrzynia pluszaków"
	desc = "Skrzynia pełna pluszaków (5 szt.)!"
	cost = 1500
	num_contained = 5
	contains = list()
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "skrzynia z pluszakami"

/datum/supply_pack/costumes_toys/randomised/plush/fill(obj/structure/closet/crate/C)
	var/plush
	for(var/i in 1 to num_contained)
		plush = pick(subtypesof(/obj/item/toy/plush))
		new plush(C)

//////////////////////////////////////////////////////////////////////////////
///////////////////////// Wardrobe Resupplies ////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/costumes_toys/wardrobes/autodrobe
	name = "Skrzynia uzupełnień Autodrobe"
	desc = "W Autodrobe brakuje twojej ulubionej sukienki? Rozwiąż ten problem już dziś dzięki temu wkładowi do Autodrobe."
	cost = 800
	contains = list(/obj/item/vending_refill/autodrobe)
	crate_name = "skrzynia z uzupełnieniem Autodrobe"

/datum/supply_pack/costumes_toys/wardrobes/cargo
	name = "Skrzynia uzupełnień garderoby zaopatrzenia"
	desc = "Ta skrzynia zawiera wkład uzupełniający do CargoDrobe."
	cost = 800
	access_budget = ACCESS_CARGO
	contains = list(/obj/item/vending_refill/wardrobe/cargo_wardrobe)
	crate_name = "skrzynia zaopatrzenia działu zaopatrzenia"

/datum/supply_pack/costumes_toys/wardrobes/clothesmate
	name = "Skrzynia uzupełnień garderoby ClothesMate"
	desc = "Ta skrzynia zawiera wkład uzupełniający do ClothesMate."
	cost = 800
	contains = list(/obj/item/vending_refill/clothing)
	crate_name = "skrzynia z uzupełnieniem ClothesMate"

/datum/supply_pack/costumes_toys/wardrobes/engineering
	name = "Skrzynia uzupełnień garderoby inżynierii"
	desc = "Ta skrzynia zawiera wkłady uzupełniające do EngiDrobe i AtmosDrobe."
	cost = 800
	access_budget = ACCESS_ENGINE
	contains = list(/obj/item/vending_refill/wardrobe/engi_wardrobe,
					/obj/item/vending_refill/wardrobe/atmos_wardrobe)
	crate_name = "skrzynia uzupełnień garderoby działu inżynierii"

/datum/supply_pack/costumes_toys/wardrobes/general
	name = "Skrzynia uzupełnień garderób ogólnych"
	desc = "Ta skrzynia zawiera wkłady uzupełniające do CuraDrobe, BarDrobe, ChefDrobe, JaniDrobe i ChapDrobe."
	cost = 1200
	contains = list(/obj/item/vending_refill/wardrobe/curator_wardrobe,
					/obj/item/vending_refill/wardrobe/bar_wardrobe,
					/obj/item/vending_refill/wardrobe/chef_wardrobe,
					/obj/item/vending_refill/wardrobe/jani_wardrobe,
					/obj/item/vending_refill/wardrobe/chap_wardrobe)
	crate_name = "uzupełnienia garderób ogólnych"

/datum/supply_pack/costumes_toys/wardrobes/hydroponics
	name = "Skrzynia uzupełnień Hydrobe"
	desc = "Ta skrzynia zawiera wkład uzupełniający do Hydrobe."
	cost = 800 //NSV edit, upped price to avoid infinite money
	access_budget = ACCESS_HYDROPONICS
	contains = list(/obj/item/vending_refill/wardrobe/hydro_wardrobe)
	crate_name = "skrzynia z uzupełnieniem Hydrobe"

/datum/supply_pack/costumes_toys/wardrobes/medical
	name = "Skrzynia uzupełnień garderoby medycznej"
	desc = "Ta skrzynia zawiera wkłady uzupełniające do MediDrobe, ChemDrobe, GeneDrobe i ViroDrobe."
	cost = 1200
	access_budget = ACCESS_MEDICAL
	contains = list(/obj/item/vending_refill/wardrobe/medi_wardrobe,
					/obj/item/vending_refill/wardrobe/chem_wardrobe,
					/obj/item/vending_refill/wardrobe/gene_wardrobe,
					/obj/item/vending_refill/wardrobe/viro_wardrobe)
	crate_name = "skrzynia uzupełnień garderoby działu medycznego"

/datum/supply_pack/costumes_toys/wardrobes/science
	name = "Skrzynia uzupełnień garderoby naukowej"
	desc = "Ta skrzynia zawiera wkłady uzupełniające do SciDrobe i RoboDrobe."
	cost = 800
	access_budget = ACCESS_RESEARCH
	contains = list(/obj/item/vending_refill/wardrobe/robo_wardrobe,
					/obj/item/vending_refill/wardrobe/science_wardrobe)
	crate_name = "skrzynia uzupełnień garderoby działu naukowego"

/datum/supply_pack/costumes_toys/wardrobes/security
	name = "Skrzynia uzupełnień garderoby policyjnej"
	desc = "Ta skrzynia zawiera wkłady uzupełniające do Mundurowni Policyjnej, DetDrobe i LawDrobe."
	cost = 1000
	access_budget = ACCESS_SECURITY
	contains = list(/obj/item/vending_refill/wardrobe/sec_wardrobe,
					/obj/item/vending_refill/wardrobe/det_wardrobe,
					/obj/item/vending_refill/wardrobe/law_wardrobe)
	crate_name = "skrzynia zaopatrzenia policji"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/misc
	group = "Miscellaneous Supplies"

/datum/supply_pack/misc/artsupply
	name = "Przybory plastyczne"
	desc = "Stwórz kilka szczęśliwych przypadków dzięki sześciu płótnom, dwóm sztalugom i dwóm tęczowym kredkom!"
	cost = 800 //NSV edit, upped price to avoid infinite money
	contains = list(/obj/structure/easel,
					/obj/structure/easel,
					/obj/item/canvas/nineteen_nineteen,
					/obj/item/canvas/nineteen_nineteen,
					/obj/item/canvas/twentythree_nineteen,
					/obj/item/canvas/twentythree_nineteen,
					/obj/item/canvas/twentythree_twentythree,
					/obj/item/canvas/twentythree_twentythree,
					/obj/item/toy/crayon/rainbow,
					/obj/item/toy/crayon/rainbow,
					/obj/item/vending_refill/sticker)
	crate_name = "skrzynia z przyborami plastycznymi"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/aquarium_kit
	name = "Zestaw akwarystyczny"
	desc = "Wszystko, czego trzeba do założenia własnego akwarium. Zawiera zestaw do budowy akwarium, katalog ryb, puszkę karmy i trzy ryby słodkowodne z naszej kolekcji."
	cost = 2000
	contains = list(/obj/item/book/fish_catalog,
					/obj/item/storage/fish_case/random/freshwater,
					/obj/item/storage/fish_case/random/freshwater,
					/obj/item/storage/fish_case/random/freshwater,
					/obj/item/fish_feed,
					/obj/item/storage/box/aquarium_props,
					/obj/item/aquarium_kit)
	crate_name = "skrzynia z zestawem akwarystycznym"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/aquarium_fish
	name = "Pojemnik z rybą akwariową"
	desc = "Ryba akwariowa wybrana ręcznie przez małpy z naszej kolekcji."
	cost = 600
	contains = list(/obj/item/storage/fish_case/random)
	crate_name = "skrzynia z rybą akwariową"

/datum/supply_pack/misc/bicycle
	name = "Rower"
	desc = "Nanotrasen przypomina wszystkim pracownikom, by nigdy nie igrali z mocami, nad którymi nie panują."
	cost = 1000000
	contains = list(/obj/vehicle/ridden/bicycle)
	crate_name = "skrzynia z rowerem"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/misc/bicycle/generate(atom/A, datum/bank_account/paying_account)
	. = ..()
	for(var/client/C as() in GLOB.clients)
		if(C?.mob.mind.assigned_role == JOB_NAME_QUARTERMASTER || C?.mob.mind.assigned_role == JOB_NAME_CARGOTECHNICIAN)
			C?.give_award(/datum/award/achievement/misc/bike, C?.mob)

/datum/supply_pack/misc/bigband
	name = "Kolekcja instrumentów big bandu"
	desc = "Rozkręć smutną stację dzięki tej świetnej kolekcji! Zawiera dziewięć różnych instrumentów!"
	cost = 800
	crate_name = "kolekcja instrumentów big bandu"
	contains = list(/obj/item/instrument/violin,
					/obj/item/instrument/guitar,
					/obj/item/instrument/glockenspiel,
					/obj/item/instrument/accordion,
					/obj/item/instrument/saxophone,
					/obj/item/instrument/trombone,
					/obj/item/instrument/recorder,
					/obj/item/instrument/harmonica,
					/obj/structure/musician/piano/unanchored)
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/book_crate
	name = "Skrzynia książek"
	desc = "Nadwyżki z Archiwów Nanotrasen. Te siedem książek na pewno dobrze się czyta."
	cost = 1200
	access_budget = ACCESS_LIBRARY
	contains = list(/obj/item/book/codex_gigas,
					/obj/item/book/manual/random/,
					/obj/item/book/manual/random/,
					/obj/item/book/manual/random/,
					/obj/item/book/random,
					/obj/item/book/random,
					/obj/item/book/random)
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/misc/paper
	name = "Skrzynia biurokratyczna"
	desc = "Wysokie stosy papierów na biurku to duży problem – zmniejsz go do rozmiaru grochu dzięki temu zaopatrzeniu biurowemu! Zawiera sześć długopisów, trochę filmu do aparatu, materiały do etykieciarki, podajnik papieru, trzy teczki, wskaźnik laserowy, dwie podkładki i dwie pieczątki."//that was too forced
	cost = 800
	contains = list(/obj/structure/filingcabinet/chestdrawer/wheeled,
					/obj/item/camera_film,
					/obj/item/hand_labeler,
					/obj/item/hand_labeler_refill,
					/obj/item/hand_labeler_refill,
					/obj/item/paper_bin,
					/obj/item/pen/fourcolor,
					/obj/item/pen/fourcolor,
					/obj/item/pen,
					/obj/item/pen/fountain,
					/obj/item/pen/blue,
					/obj/item/pen/red,
					/obj/item/folder/blue,
					/obj/item/folder/red,
					/obj/item/folder/yellow,
					/obj/item/clipboard,
					/obj/item/clipboard,
					/obj/item/stamp,
					/obj/item/stamp/denied,
					/obj/item/laser_pointer/purple,
					/obj/item/sticky_note_pile)
	crate_name = "skrzynia biurokratyczna"

/datum/supply_pack/misc/fountainpens
	name = "Skrzynia kaligraficzna"
	desc = "Podpisuj wyroki śmierci z klasą dzięki tym siedmiu ekskluzywnym piórom wiecznym."
	cost = 800
	contains = list(/obj/item/storage/box/fountainpens)
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "skrzynia kaligraficzna"

/datum/supply_pack/misc/wrapping_paper
	name = "Skrzynia świątecznego papieru do pakowania"
	desc = "Chcesz wysłać bliskim zapakowane na prezent czekoladki, pluszaki albo odciętą głowę Klauna? Wszystko to zrobisz dzięki tej skrzyni pełnej papieru do pakowania."
	cost = 800
	contains = list(/obj/item/stack/wrapping_paper)
	crate_type = /obj/structure/closet/crate/wooden
	crate_name = "skrzynia ze świątecznym papierem do pakowania"


/datum/supply_pack/misc/funeral
	name = "Skrzynia zaopatrzenia pogrzebowego"
	desc = "Pod koniec dnia ktoś zawsze będzie chciał, żeby ktoś inny nie żył. Zapewnij zmarłym godne pożegnanie dzięki temu zaopatrzeniu pogrzebowemu! Zawiera trumnę z całunami i kwiatami."
	cost = 800
	access_budget = ACCESS_CHAPEL_OFFICE
	contains = list(/obj/item/clothing/under/misc/burial,
					/obj/item/food/grown/harebell,
					/obj/item/food/grown/poppy/geranium)
	crate_name = "trumna"
	crate_type = /obj/structure/closet/crate/coffin

/datum/supply_pack/misc/religious_supplies
	name = "Skrzynia zaopatrzenia religijnego"
	desc = "Zadbaj, by lokalny kapłan był zadowolony i dobrze zaopatrzony, zanim ściągnie gniew niebios na twoją ładownię. Zawiera dwie butelki wody święconej, biblie, szaty kapłana i całuny."
	cost = 4000	// it costs so much because the Space Church is ran by Space Jews
	access_budget = ACCESS_CHAPEL_OFFICE
	contains = list(/obj/item/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/storage/book/bible/booze,
					/obj/item/storage/book/bible/booze,
					/obj/item/clothing/neck/crucifix/rosary,
					/obj/item/clothing/suit/hooded/chaplain_hoodie,
					/obj/item/clothing/suit/hooded/chaplain_hoodie)
	crate_name = "skrzynia z zaopatrzeniem religijnym"

/datum/supply_pack/misc/toner
	name = "Skrzynia tonerów"
	desc = "Zużyłeś za dużo tuszu na drukowanie zdjęć tyłków? Nie martw się, z tymi ośmioma wkładami tonera będziesz drukować tyłki do usranej śmierci!"
	cost = 800
	contains = list(/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner)
	crate_name = "skrzynia z tonerami"

/datum/supply_pack/misc/toner_large
	name = "Skrzynia tonerów (duża)"
	desc = "Masz dość wymieniania wkładów tonera? Te sześć wyjątkowo wytrzymałych wkładów zawiera mniej więcej pięć razy więcej tonera niż model podstawowy!"
	cost = 3000
	contains = list(/obj/item/toner/large,
					/obj/item/toner/large,
					/obj/item/toner/large,
					/obj/item/toner/large,
					/obj/item/toner/large,
					/obj/item/toner/large)
	crate_name = "duża skrzynia z tonerami"
