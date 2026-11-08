// AQUILA - port BeeStation/BeeStation-Hornet#14340: skutki przedmiotów ukrytych w jedzeniu (food_storage, on_accidental_consumption()).
// Materiały twarde ranią w głowę, chemiczne dodają swój reagent ofierze i reszcie jedzenia. Pigułka zostaje połknięta,
// strzykawka wstrzykuje część zawartości, nabój wypala proch, dysku nuklearnego nie da się zjeść niechcący.
// Bee ma też drewno, adamantyt i runit: u nas nie ma tych materiałów.

/datum/material/iron/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
	return TRUE

/datum/material/glass/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD) //cronch
	return TRUE

/datum/material/silver/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
	return TRUE

/datum/material/gold/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
	return TRUE

/datum/material/diamond/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(15, BRUTE, BODY_ZONE_HEAD)
	return TRUE

/datum/material/titanium/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(15, BRUTE, BODY_ZONE_HEAD)
	return TRUE

/datum/material/copper/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
	return TRUE

/datum/material/uranium/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents?.add_reagent(/datum/reagent/uranium, rand(4, 6))
	S?.reagents?.add_reagent(/datum/reagent/uranium, S.reagents.total_volume * (2/5))
	return TRUE

/datum/material/plasma/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents?.add_reagent(/datum/reagent/toxin/plasma, rand(6, 8))
	S?.reagents?.add_reagent(/datum/reagent/toxin/plasma, S.reagents.total_volume * (2/5))
	return TRUE

/datum/material/bluespace/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents?.add_reagent(/datum/reagent/bluespace, rand(5, 8))
	S?.reagents?.add_reagent(/datum/reagent/bluespace, S.reagents.total_volume * (2/5))
	return TRUE

/datum/material/bananium/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents?.add_reagent(/datum/reagent/consumable/banana, rand(8, 12))
	S?.reagents?.add_reagent(/datum/reagent/consumable/banana, S.reagents.total_volume * (2/5))
	return TRUE

/datum/material/plastic/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.adjust_disgust(17)
	return TRUE

/// Dysku nuklearnego nie da się zjeść niechcący
/obj/item/disk/nuclear/on_accidental_consumption(mob/living/carbon/victim, mob/living/carbon/user, obj/item/source_item, discover_after = TRUE)
	victim.visible_message(
		span_warning("[victim] wygląda, jakby właśnie ugryzł coś ważnego."),
		span_warning("Chwila, czy to dysk nuklearny?"))
	return discover_after

/// Nabój wypala się w zębach: proch trafia do ofiary i reszty jedzenia
/obj/item/ammo_casing/on_accidental_consumption(mob/living/carbon/victim, mob/living/carbon/user, obj/item/source_item, discover_after = TRUE)
	if(BB)
		QDEL_NULL(BB)
		update_icon()
		victim.reagents?.add_reagent(/datum/reagent/blackpowder, 3)
		source_item?.reagents?.add_reagent(/datum/reagent/blackpowder, source_item.reagents.total_volume * (2/3))
	return ..()

/// Pigułka zostaje połknięta i trafia do żołądka jak każda inna
/obj/item/reagent_containers/pill/on_accidental_consumption(mob/living/carbon/victim, mob/living/carbon/user, obj/item/source_item, discover_after = FALSE)
	to_chat(victim, span_warning("Połykasz coś małego. [source_item ? "Czy to było w [source_item]?" : ""]"))
	reagents?.trans_to(victim, reagents.total_volume, transfered_by = user, method = INGEST)
	qdel(src)
	return discover_after

/// Strzykawka wbija się w podniebienie i wstrzykuje 2/3 zawartości
/obj/item/reagent_containers/syringe/on_accidental_consumption(mob/living/carbon/victim, mob/living/carbon/user, obj/item/source_item, discover_after = TRUE)
	if(source_item)
		to_chat(victim, span_boldwarning("W [source_item] jest ukryta strzykawka!"))
	else
		to_chat(victim, span_boldwarning("Strzykawka wbija ci się w podniebienie!"))
	victim.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
	reagents?.trans_to(victim, round(reagents.total_volume * (2/3)), transfered_by = user, method = INJECT)
	return discover_after
