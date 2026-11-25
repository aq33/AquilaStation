// AQUILA - moduły pancerza mechów (źródła w opisach). Tarcza balistyczna i dron-tarcza działają z kierunkowym pancerzem (armor_facing.dm).

/obj/item/mecha_parts/mecha_equipment/aq_armor
	name = "moduł pancerza egzoszkieletu"
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_equip"
	selectable = FALSE
	aq_slot = AQ_MECHA_ARMOR
	mech_flags = EXOSUIT_MODULE_COMBAT | EXOSUIT_MODULE_RIPLEY | EXOSUIT_MODULE_MEDICAL

/obj/item/mecha_parts/mecha_equipment/aq_ballistic_shield
	name = "tarcza balistyczna egzoszkieletu"
	desc = "Fizyczna tarcza w ramieniu (Baystation, CEV Eris): od przodu odbija część ciosów i pocisków i dodatkowo wzmacnia pancerz kierunkowy. Z boku i z tyłu nie pomaga."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_ballistic_shield"
	selectable = FALSE
	aq_slot = AQ_MECHA_SLOT_ARM
	mech_flags = EXOSUIT_MODULE_COMBAT | EXOSUIT_MODULE_RIPLEY
	/// Dodatkowy mnożnik pancerza od przodu
	var/front_bonus = 1.5
	/// Dodatkowa szansa odbicia ataku od przodu
	var/deflect_bonus = 15

/obj/item/mecha_parts/mecha_equipment/aq_shield_droid
	name = "dron-tarcza egzoszkieletu"
	desc = "Dron na plecach mecha (Baystation, Aurora) rozpinający pole siłowe: pochłania połowę obrażeń, płacąc za każdy punkt energią z ogniwa."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_shield_droid"
	selectable = FALSE
	aq_slot = AQ_MECHA_ARMOR
	mech_flags = EXOSUIT_MODULE_COMBAT
	/// Ile energii kosztuje punkt pochłoniętych obrażeń
	var/energy_per_point = 20
	/// Maksimum pochłonięte z jednego trafienia
	var/max_absorb = 30

/// Zwraca obrażenia po pochłonięciu przez pole
/obj/item/mecha_parts/mecha_equipment/aq_shield_droid/proc/absorb(damage)
	if(!chassis || chassis.equipment_disabled || damage <= 0)
		return damage
	var/absorbed = min(damage * 0.5, max_absorb, chassis.get_charge() / energy_per_point)
	if(absorbed <= 0)
		return damage
	chassis.use_power(absorbed * energy_per_point)
	new /obj/effect/temp_visual/impact_effect/ion(get_turf(chassis))
	return damage - absorbed

/obj/item/mecha_parts/mecha_equipment/aq_armor/dampener
	name = "moduł tłumienia pocisków"
	desc = "Pole spowalniające pociski wokół mecha (Nova Sector): każdy pocisk traci jedną czwartą siły, zanim trafi w kadłub. Zużywa prąd przy każdym trafieniu. Sprzęt ERT i Syndykatu."
	icon_state = "aq_dampener"
	energy_drain = 50

/obj/mecha/bullet_act(obj/item/projectile/Proj)
	var/obj/item/mecha_parts/mecha_equipment/aq_armor/dampener/D = locate() in equipment
	if(D && !equipment_disabled && has_charge(D.energy_drain))
		use_power(D.energy_drain)
		Proj.damage *= 0.75
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_armor/shocker
	name = "system rażący obrony egzoszkieletu"
	desc = "Siatka pod napięciem w poszyciu (/vg/station, Polaris): razi prądem każdego, kto atakuje mecha wręcz. Obrona przed boarderami bijącymi mecha."
	icon_state = "aq_shocker"
	energy_drain = 100
	COOLDOWN_DECLARE(shock_cd)

/obj/item/mecha_parts/mecha_equipment/aq_armor/shocker/proc/shock(mob/living/attacker)
	if(!chassis || chassis.equipment_disabled || !isliving(attacker) || !chassis.Adjacent(attacker))
		return
	if(!COOLDOWN_FINISHED(src, shock_cd) || !chassis.has_charge(energy_drain))
		return
	COOLDOWN_START(src, shock_cd, 1 SECONDS)
	chassis.use_power(energy_drain)
	attacker.electrocute_act(15, chassis, 1)
	chassis.spark_system.start()

/obj/mecha/proc/aq_shock_attacker(mob/living/attacker)
	for(var/obj/item/mecha_parts/mecha_equipment/aq_armor/shocker/S in equipment)
		S.shock(attacker)

/obj/mecha/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	aq_shock_attacker(user)

/obj/mecha/attack_hand(mob/living/user)
	. = ..()
	aq_shock_attacker(user)

/obj/mecha/attack_alien(mob/living/user)
	. = ..()
	aq_shock_attacker(user)

/obj/mecha/attack_animal(mob/living/simple_animal/user)
	. = ..()
	aq_shock_attacker(user)

/obj/item/mecha_parts/mecha_equipment/aq_armor/ablative
	name = "izolacja ablacyjna egzoszkieletu"
	desc = "Warstwa izolacji (tg, Hypatia) chroniąca elektronikę mecha przed EMP: połowa impulsów nie robi nic, reszta jest słabsza. Ochrona przed działami jonowymi Syndykatu."
	icon_state = "mecha_abooster_emp"

/obj/mecha/emp_act(severity)
	if(locate(/obj/item/mecha_parts/mecha_equipment/aq_armor/ablative) in equipment)
		if(prob(50))
			occupant_message("<span class='notice'>Izolacja ablacyjna pochłania impuls.</span>")
			return
		severity = min(severity + 1, EMP_LIGHT)
	return ..()
