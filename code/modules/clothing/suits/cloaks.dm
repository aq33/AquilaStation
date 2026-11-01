//Cloaks. No, not THAT kind of cloak.

/obj/item/clothing/neck/cloak
	name = "brązowa peleryna"
	desc = "Peleryna, którą zakładasz na szyję."
	icon = 'icons/obj/clothing/cloaks.dmi'
	icon_state = "qmcloak"
	item_state = "qmcloak"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESUITSTORAGE
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/exo/cloak

/obj/item/clothing/neck/cloak/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] dusi się [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return(OXYLOSS)

/obj/item/clothing/neck/cloak/hos
	name = "peleryna Komendanta"
	desc = "Nosi ją Securistan, który rządzi statkiem żelazną ręką."
	icon_state = "hoscloak"

/obj/item/clothing/neck/cloak/qm
	name = "peleryna Kwatermistrza"
	desc = "Nosi ją Cargonia, która zaopatruje statek we wszystko, co niezbędne do przetrwania."

/obj/item/clothing/neck/cloak/cmo
	name = "peleryna Ordynatora"
	desc = "Nosi ją Meditopia – dzielni mężczyźni i kobiety, którzy trzymają zarazę na dystans."
	icon_state = "cmocloak"

/obj/item/clothing/neck/cloak/ce
	name = "peleryna Głównego Inżyniera"
	desc = "Nosi ją Engitopia, władcy nieograniczonej mocy."
	icon_state = "cecloak"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/cloak/rd
	name = "peleryna Dyrektora Naukowego"
	desc = "Nosi ją Sciencia – cudotwórcy i badacze wszechświata."
	icon_state = "rdcloak"

/obj/item/clothing/neck/cloak/cap
	name = "peleryna kapitana"
	desc = "Nosi ją dowódca statku."
	icon_state = "capcloak"

/obj/item/clothing/neck/cloak/hop
	name = "peleryna Starszego Oficera"
	desc = "Nosi ją Starszy Oficer. Lekko pachnie biurokracją."
	icon_state = "hopcloak"

/obj/item/clothing/suit/hooded/cloak/goliath
	name = "peleryna z goliata"
	icon_state = "goliath_cloak"
	desc = "Solidna, praktyczna peleryna uszyta z wielu materiałów pozyskanych z potworów. Pożądana wśród wygnańców i pustelników."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/spear, /obj/item/spear/bonespear, /obj/item/organ/regenerative_core/legion, /obj/item/kitchen/knife/combat/bone, /obj/item/kitchen/knife/combat/survival)
	armor = list("melee" = 50, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "stamina" = 30, "bleed" = 20) //a fair alternative to bone armor, requiring alternative materials and gaining a suit slot
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/goliath
	body_parts_covered = CHEST|GROIN|ARMS
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/hooded/cloakhood/goliath
	name = "kaptur peleryny z goliata"
	icon_state = "golhood"
	desc = "Kaptur, który chroni i ukrywa."
	armor = list("melee" = 50, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "stamina" = 30, "bleed" = 30)
	flags_inv = HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	transparent_protection = HIDEMASK
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/hooded/cloak/drake
	name = "smocza zbroja"
	icon_state = "dragon"
	desc = "Zbroja wykonana ze szczątków popielnego smoka."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/spear)
	armor = list("melee" = 70, "bullet" = 30, "laser" = 50, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 30, "bleed" = 50)
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/drake
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES
	high_pressure_multiplier = 0.4

/obj/item/clothing/head/hooded/cloakhood/drake
	name = "smoczy hełm"
	icon_state = "dragon"
	desc = "Czaszka smoka."
	armor = list("melee" = 70, "bullet" = 30, "laser" = 50, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 30, "bleed" = 50)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	high_pressure_multiplier = 0.4

/obj/item/clothing/suit/hooded/cloak/bone
	name = "ciężki pancerz z kości"
	icon_state = "hbonearmor"
	desc = "Plemienny napierśnik wykonany ze zwierzęcych kości. Cięższa wersja zwykłego pancerza z kości."
	armor = list("melee" = 40, "bullet" = 25, "laser" = 30, "energy" = 30, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 20, "bleed" = 70)
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/bone
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	resistance_flags = NONE
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES

/obj/item/clothing/head/hooded/cloakhood/bone
	name = "hełm z kości"
	icon_state = "hskull"
	desc = "Onieśmielający plemienny hełm. Nie wygląda na zbyt wygodny."
	armor = list("melee" = 35, "bullet" = 25, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 20, "bleed" = 50)
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	resistance_flags = NONE
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/neck/cloak/syndcap //NSV13 - syndicate captain
	name = "peleryna kapitana Syndykatu"
	desc = "Peleryna, która budzi strach wśród pracowników Nanotrasen. Noszą ją najwięksi kapitanowie Syndykatu."
	icon_state = "syndcapt"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 70) //NSV13 - armor stacking clear

/obj/item/clothing/neck/cloak/syndadmiral //NSV13 - syndicate admiral
	name = "peleryna admirała Syndykatu"
	desc = "Głęboko czerwona peleryna, którą noszą tylko najwięksi z Syndykatu. Jeśli na nią patrzysz, to raczej niedługo przestaniesz."
	icon_state = "syndadmiral"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90) //NSV13 - armor stacking clear

/obj/item/clothing/neck/cloak/chap/bishop
	name = "peleryna biskupa"
	desc = "Zostań kosmicznym papieżem."
	icon_state = "bishopcloak"

/obj/item/clothing/neck/cloak/chap/bishop/black
	name = "czarna peleryna biskupa"
	icon_state = "blackbishopcloak"
