// AQUILA - brakujące kawałki do mutacji z Yogstation

// --- Zaklęcie strzelające pociskiem: /datum/action/cooldown/spell/pointed/projectile jest w aquila/code/datums/actions/spell_types_tg.dm ---

// --- Odporność na rany (tg TRAIT_HARDLY_WOUNDED) ---

/// Rzadziej łapie rany (tg)
#define TRAIT_HARDLY_WOUNDED "hardly_wounded"
/// Gęste kości z mutacji Bone Densification: trochę mniejsze obrażenia liczone do ran
#define TRAIT_YOG_DENSE_BONES "yog_dense_bones"

// Lekkie rany nie mają pancerza ran, więc odporność zmniejsza obrażenia, od których losuje się rana
/mob/living/carbon/check_wounding(obj/item/bodypart/limb, damage, wound_type)
	if(HAS_TRAIT(src, TRAIT_YOG_DENSE_BONES))
		damage *= 0.9
	if(HAS_TRAIT(src, TRAIT_HARDLY_WOUNDED))
		damage *= 0.85
	return ..()
