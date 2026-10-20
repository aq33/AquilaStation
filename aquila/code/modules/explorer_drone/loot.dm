// AQUILA - drony eksploracyjne (port z tgstation, code/modules/explorer_drone/loot.dm)
// Unikalny łup z tg (okulary geist gazers i psych, firelance) zastąpiony podobnymi przedmiotami, które już mamy.

GLOBAL_LIST_INIT(adventure_loot_generator_index, generate_generator_index())

/// Creates generator__id => type map.
/proc/generate_generator_index()
	. = list()
	for(var/type in typesof(/datum/adventure_loot_generator))
		var/datum/adventure_loot_generator/generator = type
		if(!initial(generator.id))
			continue
		.[initial(generator.id)] = type

/// Adventure loot category identified by ID
/datum/adventure_loot_generator
	var/id

/datum/adventure_loot_generator/proc/generate()
	return

/// Helper to transfer loot while respecting cargo space
/datum/adventure_loot_generator/proc/transfer_loot(obj/item/exodrone/drone)
	for(var/obj/loot in generate())
		drone.try_transfer(loot)

/// Uses manintenance loot generators
/datum/adventure_loot_generator/maintenance
	id = "maint"
	var/amount = 1

/datum/adventure_loot_generator/maintenance/generate()
	var/list/all_loot = list()
	for(var/i in 1 to amount)
		var/lootspawn = pickweight(GLOB.maintenance_loot)
		while(islist(lootspawn))
			lootspawn = pickweight(lootspawn)
		var/atom/movable/loot = new lootspawn()
		all_loot += loot
	return all_loot

/// Unlocks special cargo crates
/datum/adventure_loot_generator/cargo
	id = "trade_contract"
	var/static/list/unlockable_packs = list(/datum/supply_pack/exploration/scrapyard, /datum/supply_pack/exploration/catering, /datum/supply_pack/exploration/shrubbery)

/datum/adventure_loot_generator/cargo/generate()
	var/list/still_locked_packs = list()
	for(var/pack_type in unlockable_packs)
		var/datum/supply_pack/pack_singleton = SSshuttle.supply_packs[pack_type]
		if(!pack_singleton.special_enabled)
			still_locked_packs += pack_type
	if(!length(still_locked_packs)) // Just give out some cash instead.
		var/datum/adventure_loot_generator/simple/cash/replacement = new
		return replacement.generate()
	var/chosen_pack_type = pick(still_locked_packs)
	return list(new /obj/item/trade_chip(null, chosen_pack_type))

/// Just picks and instatiates the path from the list
/datum/adventure_loot_generator/simple
	var/loot_list

/datum/adventure_loot_generator/simple/generate()
	var/loot_type = pick(loot_list)
	return list(new loot_type())

/// Unique exploration-only rewards - this is contextless
/datum/adventure_loot_generator/simple/unique
	id = "unique"
	// tg: geist gazers (widać duchy), psych glasses (kolorowe), firelance (topi ściany)
	loot_list = list(/obj/item/clothing/glasses/welding/ghostbuster, /obj/item/clothing/glasses/prism_glasses, /obj/item/pickaxe/drill/jackhammer)

/// Valuables
/datum/adventure_loot_generator/simple/cash
	id = "cash"
	loot_list = list(/obj/item/storage/bag/money, /obj/item/antique, /obj/item/stack/spacecash/c1000, /obj/item/stack/spacecash/c500)

/// Drugs
/datum/adventure_loot_generator/simple/drugs
	id = "drugs"
	loot_list = list(/obj/item/storage/pill_bottle/happy, /obj/item/storage/pill_bottle/lsd, /obj/item/storage/pill_bottle/penacid, /obj/item/storage/pill_bottle/stimulant)

/// Rare minerals/materials
/datum/adventure_loot_generator/simple/materials
	id = "materials"
	loot_list = list(/obj/item/stack/sheet/iron/fifty, /obj/item/stack/sheet/plasteel/twenty)

/// Assorted weaponry
/datum/adventure_loot_generator/simple/weapons
	id = "weapons"
	loot_list = list(/obj/item/gun/energy/laser, /obj/item/melee/baton/loaded)

/// Rare fish! Of the syndicate variety
/datum/adventure_loot_generator/simple/syndicate_fish
	id = "syndicate_fish"
	loot_list = list(/obj/item/storage/fish_case/random) // u nas nie ma ryb Syndykatu

/// Pets and pet accesories in carriers
/datum/adventure_loot_generator/pet
	id = "pets"
	var/carrier_type = /obj/item/pet_carrier
	var/list/possible_pets = list(
		/mob/living/simple_animal/pet/cat/space,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/dog/pug,
		/mob/living/simple_animal/pet/penguin/baby,
	)

/datum/adventure_loot_generator/pet/generate()
	var/obj/item/pet_carrier/carrier = new carrier_type()
	var/chosen_pet_type = pick(possible_pets)
	var/mob/living/simple_animal/pet/pet = new chosen_pet_type()
	carrier.add_occupant(pet)
	return list(carrier)

/obj/item/antique
	name = "antyk"
	desc = "Cenny i zupełnie niezrozumiały."
	icon = 'aquila/icons/obj/exploration.dmi'
	icon_state = "antique"

/// Supply pack unlocker chip
/obj/item/trade_chip
	name = "chip z kontraktem handlowym"
	desc = "Łączy się przez sieć cargo z dostawcą z czarnego rynku. Użyj go na konsoli cargo, żeby odblokować nową paczkę do zamówienia."
	icon = 'aquila/icons/obj/exploration.dmi'
	icon_state = "trade_chip"
	/// Supply pack type enabled by this chip
	var/unlocked_pack_type

/obj/item/trade_chip/Initialize(mapload, pack_type)
	. = ..()
	if(pack_type)
		unlocked_pack_type = pack_type
		var/datum/supply_pack/typed_pack_type = pack_type
		name += " - [initial(typed_pack_type.name)]"

/obj/item/trade_chip/proc/try_to_unlock_contract(mob/user)
	var/datum/supply_pack/pack_singleton = SSshuttle.supply_packs[unlocked_pack_type]
	if(!unlocked_pack_type || !pack_singleton || !pack_singleton.special)
		to_chat(user, "<span class='danger'>Ten chip jest nieważny!</span>")
		return
	pack_singleton.special_enabled = TRUE
	to_chat(user, "<span class='notice'>Kontrakt przyjęty do bazy dostaw Nanotrasenu.</span>")
	qdel(src)

/obj/machinery/computer/cargo/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/trade_chip))
		var/obj/item/trade_chip/contract = weapon
		contract.try_to_unlock_contract(user)
		return TRUE
	return ..()
