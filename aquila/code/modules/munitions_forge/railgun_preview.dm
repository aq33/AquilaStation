// AQUILA - rework amunicji: podgląd kutego pocisku railguna przed wykuciem.
// Wzór strzału z hybrid_railgun.dm (animate_projectile) przeniesiony tutaj: strzał (hook AQ EDIT), okno kuźni railguna
// i opis pocisku liczą to samo. Zła para materiałów dalej daje słaby pocisk, ale gracz widzi to przed wykuciem.

/// Obrażenia zwykłego i uranowego pocisku z protolathe do porównania w oknie (projectiles_fx.dm)
#define AQ_RAILGUN_PLAIN_DAMAGE 150
#define AQ_RAILGUN_URANIUM_DAMAGE 185

/// Prędkość pocisku: przewodnictwo i wyrównanie szyn (100 = idealne)
/proc/aq_railgun_velocity(conductivity, alignment = 100)
	. = (conductivity * 1.5) - ((100 - alignment) / 100)
	if(. < 0)
		. = 0.1

/// Przebicie z twardości materiału (liniowo po skali Mohsa); bananium robi z pocisku lekki, bez przebicia
/proc/aq_railgun_penetration(hardness, railgun_flags)
	if(railgun_flags & RAIL_BANANA)
		return 0
	switch(hardness)
		if(0 to 5)
			return 0
		if(5 to 6)
			return 5
		if(6 to 7)
			return 10
		if(7 to 8)
			return 15
		if(8 to 9)
			return 20
		if(9 to 10)
			return 25
	return 0

/// Obrażenia kutego pocisku 400 mm
/proc/aq_railgun_slug_damage(density, velocity)
	return max(density * velocity, 0)

/// Obrażenia kanistra 800 mm bez gazu (gaz dodaje swoje w hybrid_railgun.dm)
/proc/aq_railgun_canister_damage(hardness, density, velocity)
	return (((hardness * 0.25) * density) * velocity) * 0.2

/// Flagi pocisku z pary materiałów, jak w forge_slug() i forge_canister()
/proc/aq_railgun_material_flags(material_a, material_b)
	. = 0
	if(material_a == "Bananium" || material_b == "Bananium")
		. |= RAIL_BANANA
	if(material_a == "Bluespace" || material_b == "Bluespace")
		. |= RAIL_BLUESPACE
	if(material_a == "Plasma" || material_b == "Plasma")
		. |= RAIL_BURN

/// Liczby do okna i opisu: obrażenia, przebicie, prędkość, podpalenie
/proc/aq_railgun_preview(conductivity, density, hardness, railgun_flags, canister = FALSE)
	var/velocity = aq_railgun_velocity(conductivity)
	var/damage = canister ? aq_railgun_canister_damage(hardness, density, velocity) : aq_railgun_slug_damage(density, velocity)
	return list(
		"damage" = round(damage, 1),
		"penetration" = aq_railgun_penetration(hardness, railgun_flags),
		"velocity" = round(velocity, 0.1),
		"burn" = !canister && (railgun_flags & RAIL_BURN) ? 20 : 0,
		"light" = !!(railgun_flags & RAIL_BANANA),
	)

/// Opis do examine: porównanie ze zwykłym pociskiem
/proc/aq_railgun_preview_text(list/preview, canister = FALSE)
	. = "Przy pełnym wyrównaniu szyn: [preview["damage"]] obrażeń[canister ? " bez gazu (gaz w kanistrze dodaje swoje)" : ""], przebicie [preview["penetration"]], prędkość [preview["velocity"]]."
	if(!canister)
		if(preview["damage"] < AQ_RAILGUN_PLAIN_DAMAGE)
			. += " Słabszy niż zwykły pocisk ([AQ_RAILGUN_PLAIN_DAMAGE])."
		else if(preview["damage"] >= AQ_RAILGUN_URANIUM_DAMAGE)
			. += " Mocniejszy niż pocisk uranowy ([AQ_RAILGUN_URANIUM_DAMAGE])."

/obj/machinery/railgun_forge/ui_data(mob/user)
	. = ..()
	var/list/mats = get_tank_materials()
	if(!mats)
		.["preview"] = null
		return
	var/flags = aq_railgun_material_flags(T1.material_selection, T2.material_selection)
	.["preview"] = list(
		"slug" = aq_railgun_preview(getConductivity("slug"), getDensity("slug"), getHardness("slug"), flags),
		"canister" = aq_railgun_preview(getConductivity("canister"), getDensity("canister"), getHardness("canister"), flags, TRUE),
		"plain_damage" = AQ_RAILGUN_PLAIN_DAMAGE,
		"uranium_damage" = AQ_RAILGUN_URANIUM_DAMAGE,
	)

/obj/item/ship_weapon/ammunition/railgun_ammo/forged/examine(mob/user)
	. = ..()
	if(material_density)
		. += "<span class='notice'>[aq_railgun_preview_text(aq_railgun_preview(material_conductivity, material_density, material_hardness, railgun_flags))]</span>"

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/examine(mob/user)
	. = ..()
	if(material_density)
		. += "<span class='notice'>[aq_railgun_preview_text(aq_railgun_preview(material_conductivity, material_density, material_hardness, railgun_flags, TRUE), TRUE)]</span>"

#undef AQ_RAILGUN_PLAIN_DAMAGE
#undef AQ_RAILGUN_URANIUM_DAMAGE
