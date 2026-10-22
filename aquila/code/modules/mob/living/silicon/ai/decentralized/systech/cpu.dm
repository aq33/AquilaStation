#define OVERCLOCK_MIN_POWER_MULT -0.5

/obj/item/ai_cpu
	name = "neuronowa jednostka obliczeniowa"
	desc = "Procesor wyspecjalizowany w zadaniach sieci neuronowych, takich jak SI. Montuje się go tylko w rackach serwerowych."
	icon = 'icons/obj/module.dmi'
	icon_state = "cpuboard"
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/glass = 1000, /datum/material/gold = 500)

	var/speed = 1
	var/max_speed = 10
	var/base_power_usage = AI_BASE_POWER_PER_CPU
	var/power_multiplier = 1
	var/max_power_multiplier = 1

	var/growth_scale = 1

	//Multipliers
	var/minimum_max_power = 1.25
	var/maximum_max_power = 2

	//Lower value means speed and power is more linear
	var/minimum_growth = 0.6
	//High values means its easier to get a high overclock at low power
	var/maximum_growth = 3.5

	var/list/last_overclocking_values = list()

/obj/item/ai_cpu/Initialize(mapload)
	growth_scale = rand(minimum_growth * 100, maximum_growth * 100) / 100
	max_power_multiplier = (rand(minimum_max_power * 100, maximum_max_power * 100) / 100) * power_multiplier
	return ..()

/obj/item/ai_cpu/examine(mob/user)
	. = ..()
	. += span_notice("Taktowanie: [speed] THz, pobór mocy: [get_power_usage()] W.")

/obj/item/ai_cpu/proc/valid_overclock()
	if(power_multiplier == initial(power_multiplier) && speed == initial(speed))
		return SUCCESSFUL_OVERCLOCK

	if((power_multiplier - 1) < OVERCLOCK_MIN_POWER_MULT)
		return FAILED_OVERCLOCK_NO_POWER

	//logistic formula:
	//y = 2/1+e^(-growth_scale*x) where x = power_multiplier - 1. Maximum of 94% faster at 200% power multiplier. Minimum of 34% faster at 200% power multiplier
	var/optimal_speed_mult = 2 / (1 + NUM_E ** (-growth_scale * (power_multiplier - 1)))

	if(power_multiplier > max_power_multiplier)
		return FAILED_OVERCLOCK_POWER

	if(speed >= initial(speed) * optimal_speed_mult)
		return FAILED_OVERCLOCK_SPEED
	return SUCCESSFUL_OVERCLOCK

/obj/item/ai_cpu/proc/get_power_usage()
	return base_power_usage * power_multiplier

/obj/item/ai_cpu/proc/get_efficiency()
	return 1 / (power_multiplier / initial(power_multiplier)) * 100

/obj/item/ai_cpu/advanced
	name = "zaawansowana neuronowa jednostka obliczeniowa"
	desc = "Procesor wyspecjalizowany w zadaniach sieci neuronowych, takich jak SI. Montuje się go tylko w rackach serwerowych. Ma lepsze przewidywanie rozgałęzień i szybszy dostęp do pamięci."
	icon_state = "cpuboard_adv"
	custom_materials = list(/datum/material/glass = 2000, /datum/material/gold = 1000, /datum/material/silver = 1000)

	speed = 2

/obj/item/ai_cpu/advanced/Initialize(mapload)
	base_power_usage = AI_BASE_POWER_PER_CPU * 1.75
	return ..()

/obj/item/ai_cpu/experimental
	name = "eksperymentalna neuronowa jednostka obliczeniowa"
	desc = "Procesor wyspecjalizowany w zadaniach sieci neuronowych, takich jak SI. Montuje się go tylko w rackach serwerowych. Luźna kontrola jakości daje mu bardziej zmienne parametry podkręcania."
	icon_state = "cpuboard_adv"
	custom_materials = list(/datum/material/glass = 2000, /datum/material/gold = 1000, /datum/material/uranium = 1000)

	speed = 2

	minimum_max_power = 1.1
	maximum_max_power = 2.5

	minimum_growth = 0.5 //Basically linear at this point
	maximum_growth = 4.5 //max speed achievable at 2.2x power consumption.

/obj/item/ai_cpu/experimental/Initialize(mapload)
	base_power_usage = AI_BASE_POWER_PER_CPU * 2
	return ..()

/obj/item/ai_cpu/bluespace
	name = "bluespace'owa neuronowa jednostka obliczeniowa"
	desc = "Procesor wyspecjalizowany w zadaniach sieci neuronowych, takich jak SI. Montuje się go tylko w rackach serwerowych. Technologia bluespace jeszcze bardziej zmniejsza podzespoły."
	icon_state = "cpuboard_super"
	custom_materials = list(/datum/material/glass = 2000, /datum/material/gold = 1000, /datum/material/diamond = 500, /datum/material/bluespace = 500)

	speed = 3
	minimum_max_power = 1
	maximum_max_power = 2

/obj/item/ai_cpu/bluespace/Initialize(mapload)
	base_power_usage = AI_BASE_POWER_PER_CPU * 2.5
	return ..()

#undef OVERCLOCK_MIN_POWER_MULT
