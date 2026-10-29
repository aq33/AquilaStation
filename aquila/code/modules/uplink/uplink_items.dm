/datum/uplink_item
	var/surplus_nullcrates
	/// If TRUE, UPLINK_INFILTRATORS is stripped from purchasable_from on top of whatever core sets (keeps the core restrictions intact)
	var/exclude_infiltrators = FALSE

/datum/uplink_item/New()
	. = ..()
	if(isnull(surplus_nullcrates))
		surplus_nullcrates = surplus
	if(exclude_infiltrators)
		purchasable_from &= ~UPLINK_INFILTRATORS

/datum/uplink_item/dangerous/guardian
	surplus_nullcrates = 0

/datum/uplink_item/stealthy_weapons/martialarts
	surplus_nullcrates = 0

/datum/uplink_item/device_tools/fakenucleardisk
	surplus_nullcrates = 0

// Infiltratorzy nie dostają "murderbone" przedmiotów
/datum/uplink_item/bundles_TC/contract_kit
	exclude_infiltrators = TRUE

/datum/uplink_item/bundles_TC/bundle_A
	exclude_infiltrators = TRUE

/datum/uplink_item/bundles_TC/bundle_B
	exclude_infiltrators = TRUE

/datum/uplink_item/bundles_TC/surplus
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/sword
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/doublesword
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/bostaff
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/guardian
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/rapid
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/powerfist
	exclude_infiltrators = TRUE

/datum/uplink_item/ammo/pistolfire
	exclude_infiltrators = TRUE

/datum/uplink_item/stealthy_weapons/dehy_carp
	exclude_infiltrators = TRUE

/datum/uplink_item/stealthy_weapons/martialarts
	exclude_infiltrators = TRUE

/datum/uplink_item/stealthy_weapons/romerol_kit
	exclude_infiltrators = TRUE

/datum/uplink_item/explosives
	exclude_infiltrators = TRUE

/datum/uplink_item/suits/space_suit
	exclude_infiltrators = TRUE

/datum/uplink_item/suits/hardsuit
	exclude_infiltrators = TRUE

/datum/uplink_item/suits/modsuit
	exclude_infiltrators = TRUE

/datum/uplink_item/device_tools/failsafe
	exclude_infiltrators = TRUE

/datum/uplink_item/device_tools/hacked_module
	exclude_infiltrators = TRUE

/datum/uplink_item/device_tools/powersink
	exclude_infiltrators = TRUE

/datum/uplink_item/device_tools/suspiciousphone
	exclude_infiltrators = TRUE

// Events
/datum/uplink_item/services
	category = "Services"
	surplus = 0
	restricted = TRUE
	purchasable_from = UPLINK_INFILTRATORS

/datum/uplink_item/services/manifest_spoof
	name = "Fałszywy wpis w manifeście załogi"
	desc = "Przycisk, który dopisuje jedną osobę do manifestu załogi."
	item = /obj/item/service/manifest
	cost = 4
	limited_stock = 1

/datum/uplink_item/services/fake_ion
	name = "Fałszywa burza jonowa"
	desc = "Nadaje fałszywe ogłoszenie o burzy jonowej. Dobra dywersja, zwłaszcza gdy SI i tak dziwnie się zachowuje."
	item = /obj/item/service/ion
	cost = 7

/datum/uplink_item/services/fake_meteor
	name = "Fałszywe ogłoszenie o meteorach"
	desc = "Nadaje fałszywe ogłoszenie o meteorach. Dobry sposób, by C4 na zewnątrz statku albo każdy mały wybuch uznano za uderzenie meteoru."
	item = /obj/item/service/meteor
	cost = 7

/datum/uplink_item/services/fake_rod
	name = "Fałszywy nieruchomy pręt"
	desc = "Nadaje fałszywe ogłoszenie o nieruchomym pręcie. Dobre na krótką dywersję."
	item = /obj/item/service/rodgod
	cost = 6 //less likely to be believed

//Infiltrator shit
/datum/uplink_item/infiltration
	category = "Infiltration Gear"
	purchasable_from = UPLINK_INFILTRATORS
	surplus = 0

/datum/uplink_item/infiltration/extra_stealthsuit
	name = "Dodatkowy kameleonowy skafander"
	desc = "Skafander infiltracyjny, który potrafi natychmiast zmienić wygląd."
	item = /obj/item/clothing/suit/space/hardsuit/infiltration
	cost = 10

/datum/uplink_item/infiltration/access_kit
	name = "Zestaw dostępu"
	desc = "Tajne urządzenie odtworzone na podstawie sprzętu zdobytego w poprzednich misjach infiltracji Nanotrasen. Pozwala podrobić kartę ID tak, by miała stanowisko i dostępy jednego niskiego zawodu."
	item = /obj/item/access_kit/syndicate
	limited_stock = 1
	cost = 5

/datum/uplink_item/dangerous/gremlin
	name = "Granat z gremlinami"
	desc = "Ten granat jest pełen gremlinów. Nikomu nie zrobią krzywdy, ale uwielbiają grzebać w maszynach: śluzach, APC, silniku... Woda sprawia, że się mnożą. Świetna zabawa dla B+R i inżynierii!"
	item = /obj/item/grenade/spawnergrenade/gremlin
	cost = 2
	surplus = 30

// AQUILA - Eldritch Horror for curators (Yogstation#13033, price from Yogstation#19619)
/datum/uplink_item/role_restricted/horror
	name = "Horror w pudełku"
	desc = "Podczas sekcji głowy martwego naukowca Nanotrasenu nasi chirurdzy znaleźli w środku niezwykle osobliwe stworzenie i zdołali bezpiecznie je wydobyć. \
	Nieudany eksperyment czy pozaziemski potwór, to stworzenie zostało wyszkolone, by pomagać temu, kto je obudzi. Jeśli nie boisz się, że wejdzie ci do głowy, może okazać się przydatnym sojusznikiem. \
	Nie bierzemy odpowiedzialności za twoje nowo nabyte szaleństwo i nie przyjmujemy zwrotów."
	item = /obj/item/horrorspawner
	cost = 14
	surplus = 0
	restricted_roles = list(JOB_NAME_CURATOR)
	player_minimum = 20
