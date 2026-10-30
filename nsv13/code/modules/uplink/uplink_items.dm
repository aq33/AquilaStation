/datum/uplink_item/device_tools/tc_rod
	name = "Telekryształowy pręt paliwowy"
	desc = "Ten specjalny pręt paliwowy ma osiem gniazd na materiał, do których wkładasz telekryształy. \
			Gdy pręt całkiem się wypali, możesz zebrać z niego dodatkowe telekryształy. \
			Uwaga: ten pręt rozszczepia się znacznie szybciej niż jego odpowiednik z Nanotrasen, \
			więc łatwo nim przeciążyć reaktor..."
	item = /obj/item/fuel_rod/material/telecrystal
	cost = 7

/datum/uplink_item/role_restricted/pdc_rifle
	name = "Karabin obrony punktowej"
	desc = "Karabin zaprojektowany specjalnie do strzelania nabojami 30.12x82 mm, które znajdziesz na okrętach."
	item = /obj/item/gun/ballistic/rifle/boltaction/pdc
	cost = 12
	restricted_roles = list(JOB_NAME_MUNITIONSTECHNICIAN,JOB_NAME_MASTERATARMS)

/datum/uplink_item/badass/maid
	name = "Awaryjny zestaw pokojówki"
	desc = "Zestaw ze wszystkim, czego potrzebujesz, by zostać porządną pokojówką Syndykatu. \
			Zawiera strój pokojówki, mopa, wiadro i kostkę mydła. \
			Bo nigdy nie wiesz, kiedy przyjdzie posprzątać bałagan."
	item = /obj/item/storage/box/syndie_kit/maid
	cost = 20
	cant_discount = TRUE
	surplus = 0

/datum/uplink_item/explosives/fighterplushie
	name = "Zestaw pluszobomby"
	desc = "Zestaw ze wszystkimi narzędziami i przedmiotami potrzebnymi do złożenia własnej pluszobomby! \
			Wyeliminuj niczego nieświadome ścierwa z Nanotrasen prezentem, którego się nie spodziewają. \
			Zawiera pluszowy lekki myśliwiec Syndykatu, minibombę Syndykatu, śrubokręt i nóż survivalowy."
	item = /obj/item/storage/box/syndie_kit/plushie
	cost = 8

/datum/uplink_item/race_restricted/robotic_firstaid
	name = "Apteczka dla robotów"
	desc = "Apteczka ze wszystkimi narzędziami potrzebnymi do naprawy podwozia pozytronicznego. \
			Zawiera też butelkę radioaktywnego środka dezynfekującego i medipeny czyszczące system."
	item = /obj/item/storage/firstaid/robot
	restricted_species = list(SPECIES_IPC)
	cost = 3
