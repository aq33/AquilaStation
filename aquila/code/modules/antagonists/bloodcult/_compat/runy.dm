// AQUILA - warstwa zgodności obszaru „runy” kultu krwi (nowe runy i zaklęcia run z draftu Monkestation#3867 / vgstation).

// ---- kolor krwi run ----
// W Monke GLOB.blood_types[...] miało pola color/glows. U nas /datum/blood_type ma blood_color i glowy,
// a dane krwi w odczynniku trzymają nazwę grupy w data["blood_type"].

/// Kolor krwi, którą wypisano słowo runy
/proc/rune_blood_color(datum/reagent/blood/blood)
	if(!blood || !islist(blood.data))
		return COLOR_BLOOD
	var/datum/blood_type/blood_type = get_blood_type(blood.data["blood_type"])
	return blood_type?.blood_color || COLOR_BLOOD

/// Czy krew, którą wypisano słowo runy, świeci
/proc/rune_blood_glows(datum/reagent/blood/blood)
	if(!blood || !islist(blood.data))
		return FALSE
	var/datum/blood_type/blood_type = get_blood_type(blood.data["blood_type"])
	return blood_type?.glowy
