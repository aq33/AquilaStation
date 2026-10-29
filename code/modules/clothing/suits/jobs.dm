/*
 * Job related
 */

//Botanist
/obj/item/clothing/suit/apron
	name = "fartuch"
	desc = "Zwykły niebieski fartuch."
	icon_state = "apron"
	item_state = "apron"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	allowed = list(/obj/item/reagent_containers/spray/plantbgone, /obj/item/plant_scanner, /obj/item/plant_seeds, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/cultivator, /obj/item/reagent_containers/spray/pestspray, /obj/item/hatchet, /obj/item/storage/bag/plants)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/exo/large

//Captain
/obj/item/clothing/suit/captunic
	name = "paradna tunika kapitana"
	desc = "Kapitan nosi ją, żeby pokazać klasę."
	icon_state = "captunic"
	item_state = "bio_suit"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/disk, /obj/item/stamp, /obj/item/reagent_containers/food/drinks/flask, /obj/item/melee, /obj/item/storage/lockbox/medal, /obj/item/assembly/flash/handheld, /obj/item/storage/box/matches, /obj/item/lighter, /obj/item/clothing/mask/cigarette, /obj/item/storage/fancy/cigarettes, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)

//Chef
/obj/item/clothing/suit/toggle/chef
	name = "fartuch szefa kuchni"
	desc = "Fartuch z rękawami, jaki nosi szef kuchni wysokiej klasy."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.5
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(/obj/item/kitchen)
	togglename = "rękawy"

//Cook
/obj/item/clothing/suit/apron/chef
	name = "fartuch kucharza"
	desc = "Zwykły, nudny, biały fartuch kucharski."
	icon_state = "apronchef"
	item_state = "apronchef"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN
	allowed = list(/obj/item/kitchen)

//Detective
/obj/item/clothing/suit/det_suit
	name = "trencz"
	desc = "Wielofunkcyjny trencz z XVIII wieku. Kto go nosi, ten nie żartuje."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list("melee" = 25, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 45, "stamina" = 40, "bleed" = 30)
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/suit/det_suit/Initialize(mapload)
	. = ..()
	allowed = GLOB.detective_vest_allowed

/obj/item/clothing/suit/det_suit/grey
	name = "trencz noir"
	desc = "Szary trencz twardego prywatnego detektywa."
	icon_state = "greydet"
	item_state = "greydet"

/obj/item/clothing/suit/det_suit/noir
	name = "marynarka noir"
	desc = "Szara marynarka eleganckiego prywatnego detektywa."
	icon_state = "detsuit"
	item_state = "detsuit"

//Brig Phys
/obj/item/clothing/suit/hazardvest/brig_physician
	name = "kamizelka Lekarza Więziennego"
	desc = "Lekka kamizelka noszona przez lekarza aresztu."
	icon_state = "brig_phys_vest"
	item_state = "sec_helm"//looks kinda similar, I guess
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/police/telescopic, /obj/item/soap, /obj/item/sensor_device, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0, fire = 50, acid = 50, stamina = 30, "bleed" = 20)

//Engineering
/obj/item/clothing/suit/hazardvest
	name = "kamizelka odblaskowa"
	desc = "Kamizelka o wysokiej widoczności, noszona w strefach robót."
	icon_state = "hazard"
	item_state = "hazard"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/radio)
	resistance_flags = NONE
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/exo/large

//Lawyer
/obj/item/clothing/suit/toggle/lawyer
	name = "niebieska marynarka"
	desc = "Elegancka marynarka."
	icon_state = "suitjacket_blue"
	item_state = "suitjacket_blue"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	togglename = "guziki"

/obj/item/clothing/suit/toggle/lawyer/purple
	name = "fioletowa marynarka"
	desc = "Fircykowata marynarka."
	icon_state = "suitjacket_purp"
	item_state = "suitjacket_purp"

/obj/item/clothing/suit/toggle/lawyer/black
	name = "czarna marynarka"
	desc = "Profesjonalna marynarka."
	icon_state = "suitjacket_black"
	item_state = "ro_suit"


//Mime
/obj/item/clothing/suit/suspenders
	name = "szelki"
	desc = "Podtrzymują iluzję gry mima."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	blood_overlay_type = "armor" //it's the less thing that I can put here

//Security
/obj/item/clothing/suit/security/officer
	name = "kurtka policyjna"
	desc = "Kurtka na te szczególne okazje, kiedy policjant nie musi nosić pancerza."
	icon_state = "officerbluejacket"
	item_state = "officerbluejacket"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/security/warden
	name = "kurtka Naczelnika"
	desc = "Idealna dla Naczelnika, który chce zrobić stylowe wrażenie na odwiedzających areszt."
	icon_state = "wardenbluejacket"
	item_state = "wardenbluejacket"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/security/hos
	name = "kurtka Komendanta"
	desc = "Ten element garderoby zaprojektowano specjalnie po to, by podkreślać wyższy autorytet."
	icon_state = "hosbluejacket"
	item_state = "hosbluejacket"
	body_parts_covered = CHEST|ARMS

//Surgeon
/obj/item/clothing/suit/apron/surgical
	name = "fartuch chirurgiczny"
	desc = "Sterylny niebieski fartuch chirurgiczny."
	icon_state = "surgical"
	allowed = list(/obj/item/scalpel, /obj/item/surgical_drapes, /obj/item/cautery, /obj/item/hemostat, /obj/item/retractor)

//Curator
/obj/item/clothing/suit/curator
	name = "płaszcz łowcy skarbów"
	desc = "Modna i lekko opancerzona kurtka, ulubiona przez łowców skarbów w całej galaktyce."
	icon_state = "curator"
	item_state = "curator"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	allowed = list(/obj/item/tank/internals, /obj/item/melee/curator_whip)
	armor = list("melee" = 25, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 45, "stamina" = 30, "bleed" = 10)
	cold_protection = CHEST|ARMS
	heat_protection = CHEST|ARMS

//Roboticist

/obj/item/clothing/suit/hooded/techpriest
	name = "szaty technokapłana"
	desc = "Dla tych, którzy NAPRAWDĘ kochają swoje tostery."
	icon_state = "techpriest"
	item_state = "techpriest"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/techpriest

/obj/item/clothing/head/hooded/techpriest
	name = "kaptur technokapłana"
	desc = "Kaptur dla tych, którzy NAPRAWDĘ kochają swoje tostery."
	icon_state = "techpriesthood"
	item_state = "techpriesthood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS
