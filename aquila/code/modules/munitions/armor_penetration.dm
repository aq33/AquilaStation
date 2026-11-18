// AQUILA - rework amunicji: grubość pancerza okrętów AI i przebicie pocisków kinetycznych (na wzór Nebulous: Fleet Command).
// Okręt AI ma grubość pancerza zależną od klasy (masy), pocisk kinetyczny ma przebicie. Przy trafieniu:
// - przebicie mniejsze od grubości: pocisk nie przebija, zostają odpryski (AQ_ARMOR_NO_PEN_MULT obrażeń),
// - przebicie większe od grubości o więcej niż AQ_ARMOR_OVERPEN_MARGIN: przelot na wylot (AQ_ARMOR_OVERPEN_MULT obrażeń),
// - w pozostałych przypadkach pełne obrażenia.
// Model zastępuje procentowy pancerz (armor overmap_light/medium/heavy) tylko przy trafieniu pociskiem kinetycznym w okręt AI.
// Okręt gracza, rakiety, torpedy i broń energetyczna zostają na pancerzu procentowym. Płyty ćwiartek działają jak dotąd.

/// Ile obrażeń zostaje, gdy pocisk nie przebije pancerza
#define AQ_ARMOR_NO_PEN_MULT 0.1
/// Ile obrażeń zostaje przy przelocie na wylot
#define AQ_ARMOR_OVERPEN_MULT 0.35
/// O ile przebicie musi przewyższyć grubość, żeby pocisk przeleciał na wylot
#define AQ_ARMOR_OVERPEN_MARGIN 40

/// Klasy pancerza: nazwa, grubość (od najlżejszej)
GLOBAL_LIST_INIT(aq_armor_classes, list(
	list("name" = "myśliwce i promy", "thickness" = 5),
	list("name" = "lekkie okręty", "thickness" = 20),
	list("name" = "średnie okręty", "thickness" = 40),
	list("name" = "ciężkie okręty", "thickness" = 60),
	list("name" = "superciężkie okręty i stacje", "thickness" = 80),
))

// ---------------------------------------------------------------- pocisk

/obj/item/projectile
	/// Przebicie w modelu grubości pancerza; null = pocisk poza modelem (pancerz procentowy)
	var/aq_penetration
	/// Dodatek do przebicia niezależny od typu pocisku (burtówka P i N)
	var/aq_penetration_bonus = 0

/// Przebicie tego pocisku w modelu grubości albo null, gdy pocisk jest poza modelem
/obj/item/projectile/proc/aq_get_penetration()
	if(isnull(aq_penetration))
		return null
	return aq_penetration + aq_penetration_bonus

/obj/item/projectile/bullet/mac_round
	aq_penetration = 40

/obj/item/projectile/bullet/mac_round/magneton
	aq_penetration = 50

/obj/item/projectile/bullet/mac_round/cannonshot
	aq_penetration = 30

/obj/item/projectile/bullet/railgun_slug
	aq_penetration = 60

/obj/item/projectile/bullet/railgun_slug/uranium
	aq_penetration = 75

/obj/item/projectile/bullet/railgun_forged
	aq_penetration = 30

/// Kuty pocisk railguna: przebicie z twardości materiału (0-25 w hybrid_railgun.dm) przeliczone na skalę modelu, 30-80
/obj/item/projectile/bullet/railgun_forged/aq_get_penetration()
	return aq_penetration + aq_penetration_bonus + 2 * armour_penetration

/obj/item/projectile/bullet/gauss_slug
	aq_penetration = 50

/obj/item/projectile/bullet/light_cannon_round
	aq_penetration = 15

/obj/item/projectile/bullet/heavy_cannon_round
	aq_penetration = 35

/obj/item/projectile/bullet/broadside
	aq_penetration = 40

/obj/item/projectile/bullet/broadside/plasma
	aq_penetration_bonus = 10

/obj/item/projectile/bullet/broadside/uranium
	aq_penetration_bonus = 25

/obj/item/projectile/bullet/pdc_round
	aq_penetration = 10

/obj/item/projectile/bullet/flak
	aq_penetration = 10

/obj/item/projectile/bullet/aa_round
	aq_penetration = 10

/obj/item/projectile/bullet/hailstorm_bullet
	aq_penetration = 10

// ---------------------------------------------------------------- okręt

/obj/structure/overmap
	/// Grubość pancerza w modelu przebicia; null = z klasy masy
	var/aq_armor_thickness

/// Grubość pancerza: ręcznie ustawiona albo z klasy masy okrętu
/obj/structure/overmap/proc/aq_get_armor_thickness()
	if(!isnull(aq_armor_thickness))
		return aq_armor_thickness
	return GLOB.aq_armor_classes[aq_armor_class_index(mass)]["thickness"]

/// Numer klasy pancerza (1-5) dla masy okrętu
/proc/aq_armor_class_index(mass)
	if(mass <= MASS_TINY)
		return 1
	if(mass <= MASS_MEDIUM_SMALL)
		return 2
	if(mass <= MASS_MEDIUM_LARGE)
		return 3
	if(mass <= MASS_LARGE)
		return 4
	return 5

/// Mnożnik obrażeń pocisku o danym przebiciu przy danej grubości pancerza
/proc/aq_penetration_mult(penetration, thickness)
	if(penetration < thickness)
		return AQ_ARMOR_NO_PEN_MULT
	if(penetration - thickness > AQ_ARMOR_OVERPEN_MARGIN)
		return AQ_ARMOR_OVERPEN_MULT
	return 1

/// Czy to trafienie liczy się modelem grubości: pocisk kinetyczny w okręt AI
/obj/structure/overmap/proc/aq_uses_thickness_model(obj/item/projectile/P)
	return ai_controlled && !isnull(P.aq_get_penetration())

/// Wołane z bullet_act (damage.dm) przed pancerzem: liczy obrażenia modelem grubości i wyłącza pancerz procentowy
/// dla tego trafienia (przebicie 100). Pancerz procentowy przy dodatnich wartościach daje wtedy pełne obrażenia.
/obj/structure/overmap/proc/aq_apply_thickness_model(obj/item/projectile/P)
	if(!aq_uses_thickness_model(P))
		return
	P.damage = round(P.damage * aq_penetration_mult(P.aq_get_penetration(), aq_get_armor_thickness()), 0.1)
	P.armour_penetration = 100

/obj/structure/overmap/examine(mob/user)
	. = ..()
	if(ai_controlled)
		var/list/armor_class = GLOB.aq_armor_classes[aq_armor_class_index(mass)]
		. += "<span class='notice'>Pancerz: [isnull(aq_armor_thickness) ? armor_class["name"] : "grubość"] ([aq_get_armor_thickness()]).</span>"

// ---------------------------------------------------------------- opis dla gracza

/// "myśliwce 130%, lekkie 130%, ..." — skuteczność pocisku o danym przebiciu i mnożniku obrażeń przeciw klasom pancerza
/proc/aq_penetration_table(penetration, damage_mult = 1)
	. = list()
	for(var/list/armor_class as anything in GLOB.aq_armor_classes)
		. += list(list("name" = armor_class["name"], "thickness" = armor_class["thickness"], "percent" = round(100 * damage_mult * aq_penetration_mult(penetration, armor_class["thickness"]))))

/proc/aq_penetration_text(penetration, damage_mult = 1)
	var/list/parts = list()
	for(var/list/row as anything in aq_penetration_table(penetration, damage_mult))
		parts += "[row["name"]] [row["percent"]]%"
	return "Przebicie [penetration]. Przeciw okrętom AI: [jointext(parts, ", ")]."

#undef AQ_ARMOR_NO_PEN_MULT
#undef AQ_ARMOR_OVERPEN_MULT
#undef AQ_ARMOR_OVERPEN_MARGIN
