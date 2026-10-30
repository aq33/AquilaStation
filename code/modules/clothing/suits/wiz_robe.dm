/obj/item/clothing/head/wizard
	name = "kapelusz czarodzieja"
	desc = "Dziwnie wyglądające nakrycie głowy, które z pewnością należy do prawdziwego użytkownika magii."
	clothing_flags = SNUG_FIT | THICKMATERIAL
	icon_state = "wizard"
	gas_transfer_coefficient = 0.01 // IT'S MAGICAL OKAY JEEZ +1 TO NOT DIE
	permeability_coefficient = 0.01
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100, "stamina" = 50, "bleed" = 60)
	strip_delay = 50
	equip_delay_other = 50
	resistance_flags = FIRE_PROOF | ACID_PROOF
	dog_fashion = /datum/dog_fashion/head/blue_wizard

/obj/item/clothing/head/wizard/red
	name = "czerwony kapelusz czarodzieja"
	desc = "Dziwnie wyglądające czerwone nakrycie głowy, które z pewnością należy do prawdziwego użytkownika magii."
	icon_state = "redwizard"
	dog_fashion = /datum/dog_fashion/head/red_wizard

/obj/item/clothing/head/wizard/yellow
	name = "żółty kapelusz czarodzieja"
	desc = "Dziwnie wyglądające żółte nakrycie głowy, które z pewnością należy do potężnego użytkownika magii."
	icon_state = "yellowwizard"
	dog_fashion = null

/obj/item/clothing/head/wizard/black
	name = "czarny kapelusz czarodzieja"
	desc = "Dziwnie wyglądające czarne nakrycie głowy, które z pewnością należy do prawdziwego szkieletu. Upiorne."
	icon_state = "blackwizard"
	dog_fashion = null

/obj/item/clothing/head/wizard/fake
	name = "kapelusz czarodzieja"
	desc = "Cekinami wyszyto na nim napis CZARODZIEJJ. W zestawie fajna broda."
	icon_state = "wizard-fake"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)
	resistance_flags = FLAMMABLE
	dog_fashion = /datum/dog_fashion/head/blue_wizard
	clothing_flags = NONE

/obj/item/clothing/head/wizard/marisa
	name = "kapelusz wiedźmy"
	desc = "Dziwnie wyglądające nakrycie głowy. Masz ochotę rzucać kule ognia."
	icon_state = "marisa"
	dog_fashion = null

/obj/item/clothing/head/wizard/magus
	name = "\improper hełm Maga"
	desc = "Tajemniczy hełm, który buczy nieziemską mocą."
	icon_state = "magus"
	item_state = "magus"
	dog_fashion = null

/obj/item/clothing/head/wizard/santa
	name = "czapka Świętego Mikołaja"
	desc = "Ho ho ho. Wesołych Świąt!"
	icon_state = "santahat"
	flags_inv = HIDEHAIR|HIDEFACIALHAIR
	dog_fashion = null

/obj/item/clothing/suit/wizrobe
	name = "szata czarodzieja"
	desc = "Wspaniała szata wysadzana klejnotami, która zdaje się promieniować mocą."
	icon_state = "wizard"
	item_state = "wizrobe"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100, "stamina" = 50, "bleed" = 60)
	allowed = list(/obj/item/teleportation_scroll)
	flags_inv = HIDEJUMPSUIT
	strip_delay = 50
	equip_delay_other = 50
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = THICKMATERIAL

/obj/item/clothing/suit/wizrobe/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)

/obj/item/clothing/suit/wizrobe/red
	name = "czerwona szata czarodzieja"
	desc = "Wspaniała czerwona szata wysadzana klejnotami, która zdaje się promieniować mocą."
	icon_state = "redwizard"
	item_state = "redwizrobe"

/obj/item/clothing/suit/wizrobe/yellow
	name = "żółta szata czarodzieja"
	desc = "Wspaniała żółta szata wysadzana klejnotami, która zdaje się promieniować mocą."
	icon_state = "yellowwizard"
	item_state = "yellowwizrobe"

/obj/item/clothing/suit/wizrobe/black
	name = "czarna szata czarodzieja"
	desc = "Niepokojąca czarna szata wysadzana klejnotami, cuchnąca śmiercią i rozkładem."
	icon_state = "blackwizard"
	item_state = "blackwizrobe"

/obj/item/clothing/suit/wizrobe/marisa
	name = "szata wiedźmy"
	desc = "W magii chodzi tylko o moc zaklęć, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"

/obj/item/clothing/suit/wizrobe/magusblue
	name = "\improper szata Maga"
	desc = "Opancerzone szaty, które zdają się promieniować mroczną mocą."
	icon_state = "magusblue"
	item_state = "magusblue"

/obj/item/clothing/suit/wizrobe/magusred
	name = "\improper szata Maga"
	desc = "Opancerzone szaty, które zdają się promieniować mroczną mocą."
	icon_state = "magusred"
	item_state = "magusred"


/obj/item/clothing/suit/wizrobe/santa
	name = "strój Świętego Mikołaja"
	desc = "Świątecznie!"
	icon_state = "santa"
	item_state = "santa"

/obj/item/clothing/suit/wizrobe/fake
	name = "szata czarodzieja"
	desc = "Dość nijaka niebieska szata, która ma naśladować prawdziwe szaty czarodzieja."
	icon_state = "wizard-fake"
	item_state = "wizrobe"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)
	resistance_flags = FLAMMABLE
	clothing_flags = NONE

/obj/item/clothing/head/wizard/marisa/fake
	name = "kapelusz wiedźmy"
	desc = "Dziwnie wyglądające nakrycie głowy, przez które masz ochotę rzucać kule ognia."
	icon_state = "marisa"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)
	resistance_flags = FLAMMABLE
	clothing_flags = NONE

/obj/item/clothing/suit/wizrobe/marisa/fake
	name = "szata wiedźmy"
	desc = "W magii chodzi tylko o moc zaklęć, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)
	resistance_flags = FLAMMABLE
	clothing_flags = NONE

/obj/item/clothing/suit/wizrobe/paper
	name = "szata z masy papierowej" // no non-latin characters!
	desc = "Szata trzymająca się dzięki kawałkom przezroczystej taśmy i klajstrowi."
	icon_state = "wizard-paper"
	item_state = "wizard-paper"
	var/robe_charge = TRUE
	actions_types = list(/datum/action/item_action/stickmen)
	clothing_flags = NONE


/obj/item/clothing/suit/wizrobe/paper/ui_action_click(mob/user, action)
	stickmen()


/obj/item/clothing/suit/wizrobe/paper/verb/stickmen()
	set category = "Object"
	set name = "Summon Stick Minions"
	set src in usr
	if(!isliving(usr))
		return
	if(!robe_charge)
		to_chat(usr, "<span class='warning'>Wewnętrzny zapas magii szaty wciąż się odnawia!</span>")
		return

	usr.say("Powstań, moje dzieło! Zejdź ze swej stronicy do tego świata!", forced = "stickman summoning")
	playsound(src.loc, 'sound/magic/summon_magic.ogg', 50, 1, 1)
	var/mob/living/M = new /mob/living/simple_animal/hostile/stickman(get_turf(usr))
	var/list/factions = usr.faction
	M.faction = factions
	src.robe_charge = FALSE
	sleep(30)
	src.robe_charge = TRUE
	to_chat(usr, "<span class='notice'>Szata szumi, a jej wewnętrzny zapas magii zostaje przywrócony.</span>")


//Shielded Armour

/obj/item/clothing/suit/space/hardsuit/shielded/wizard
	name = "zbroja maga bitewnego"
	desc = "Nie każdy czarodziej boi się walki w zwarciu."
	icon_state = "battlemage"
	item_state = "battlemage"
	recharge_delay = 0 // no auto-recharge
	max_charges = 15
	shield_icon = "shield-red"
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100, "stamina" = 70, "bleed" = 70)
	slowdown = 0
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard
	name = "hełm maga bitewnego"
	desc = "Odpowiednio imponujący hełm.."
	icon_state = "battlemage"
	item_state = "battlemage"
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100, "stamina" = 70, "bleed" = 70)
	actions_types = null //No inbuilt light
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard/attack_self(mob/user)
	return

// The actual code for this is handled in the shielded component, see [/datum/component/shielded/proc/check_recharge_rune]
/obj/item/wizard_armour_charge
	name = "ładunki tarczy maga bitewnego"
	desc = "Potężna runa, która zwiększa liczbę trafień, jakie zbroja maga bitewnego wytrzyma, zanim zawiedzie.."
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"
	/// How many charges get restored
	var/restored_charges = 8
