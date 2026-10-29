// Port BeeStation/BeeStation-Hornet#14750 („Goon Combat”): każdy przedmiot ma koszt zamachu i obrażenia staminy.
// Koszt pobiera /obj/item/proc/attack() (stamina_swing), obrażenia staminy apply_item_stamina_damage() po trafieniu.
// Wartości przedmiotów jak w PR, bez zmian force (decyzja użytkownika).

/obj/item
	///Ile staminy kosztuje zamach
	var/stamina_cost = STAMINA_SWING_COST_ITEM
	///Ile staminy zabiera trafienie
	var/stamina_damage = STAMINA_DAMAGE_ITEM
	///Szansa (%) na krytyk, który mnoży obrażenia staminy
	var/stamina_critical_chance = STAMINA_CRITICAL_RATE_ITEM
	///Mnożnik obrażeń staminy przy krytyku
	var/stamina_critical_modifier = STAMINA_CRITICAL_MODIFIER

///Obrażenia staminy z trafienia przedmiotem (bez pancerza, jak w Bee)
/mob/living/proc/apply_item_stamina_damage(obj/item/I)
	if(!stamina || !I.force || !I.stamina_damage || I.damtype == STAMINA)
		return
	stamina.adjust(-(I.stamina_damage * (prob(I.stamina_critical_chance) ? I.stamina_critical_modifier : 1)))

/obj/item/extinguisher
	stamina_damage = 25
	stamina_cost = 20
	stamina_critical_chance = 35

/obj/item/grenade
	stamina_damage = 0
	stamina_cost = 0
	stamina_critical_chance = 0

/obj/item/kitchen/rollingpin
	stamina_damage = 40
	stamina_cost = 15
	stamina_critical_chance = 2

/obj/item/club
	stamina_damage = 0

/obj/item/stack/medical
	stamina_damage = 0
	stamina_cost = 0
	stamina_critical_chance = 0

/obj/item/stack/sheet
	stamina_damage = 42
	stamina_cost = 23
	stamina_critical_chance = 10

/obj/item/stack/sheet/mineral/wood
	stamina_damage = 50
	stamina_cost = 25
	stamina_critical_chance = 10

/obj/item/storage/backpack
	stamina_damage = 0
	stamina_cost = 0

/obj/item/storage/belt
	stamina_damage = 10
	stamina_cost = 5
	stamina_critical_chance = 5

/obj/item/storage/briefcase
	stamina_damage = 40
	stamina_cost = 17
	stamina_critical_chance = 10

/obj/item/storage/toolbox
	stamina_damage = 47
	stamina_cost = 20
	stamina_critical_chance = 10

/obj/item/tank
	stamina_damage = 55
	stamina_cost = 23
	stamina_critical_chance = 10

/obj/item/tank/internals/emergency_oxygen
	stamina_damage = 20
	stamina_cost = 8

/obj/item/crowbar
	stamina_damage = 35
	stamina_cost = 12
	stamina_critical_chance = 10

/obj/item/screwdriver
	stamina_damage = 10
	stamina_cost = 5
	stamina_critical_chance = 30

/obj/item/wirecutters
	stamina_damage = 15
	stamina_cost = 10
	stamina_critical_chance = 30

/obj/item/wrench
	stamina_damage = 40
	stamina_cost = 14
	stamina_critical_chance = 15

/obj/item/stack/cable_coil
	stamina_damage = 5
	stamina_cost = 5
	stamina_critical_chance = 10

/obj/item/clothing
	stamina_damage = 0
	stamina_cost = 0
	stamina_critical_chance = 0

/obj/item/bodypart
	stamina_damage = 40
	stamina_cost = 23
	stamina_critical_chance = 5

/obj/item/pen
	stamina_damage = 0

/obj/item/scalpel
	stamina_damage = 5
	stamina_cost = 5
	stamina_critical_chance = 35

/obj/item/circular_saw
	stamina_damage = 5
	stamina_cost = 5
	stamina_critical_chance = 35

// Pałki mają własne obrażenia staminy przy ogłuszeniu (charged_stamina_damage)
/obj/item/melee/baton
	stamina_damage = 0

/obj/item/melee/classic_baton
	stamina_damage = 0
