// AQUILA - Krew z krwawienia zbiera się w kałużę (nowe, w Monke krwawienie robi tylko plamy).
// Plamy i krople robi jak dotąd add_splatter_floor(). Utracona krew trafia dodatkowo do pamięci małych rozlań
// kafelka (pool_liquid), więc kilka krwawiących ciał w jednym miejscu robi kałużę po LIQUID_SPILL_THRESHOLD.
// Krwawienie tyka nawet 5 razy na sekundę, dlatego krew zbiera się na mobie i spływa porcjami.
// Do kałuży trafia tylko część utraconej krwi (reszta to plamy i krew w ubraniu): cała krew z jednego ciała
// robiła kałużę na kilkadziesiąt kafelków.

/// Od ilu jednostek uzbieranej krwi mob oddaje ją kafelkowi
#define LIQUID_BLEED_POOL_STEP 5
/// Jaka część utraconej krwi trafia do kałuży (trup z 560 j. krwi to ok. 140 j., czyli około 3 kafelki)
#define LIQUID_BLEED_POOL_FRACTION 0.25

/mob/living/carbon
	/// Utracona krew, której jeszcze nie oddano kafelkowi
	var/unpooled_blood = 0

/mob/living/carbon/bleed(amt)
	var/old_volume = blood_volume
	. = ..()
	var/lost = old_volume - blood_volume
	if(lost <= 0)
		return
	unpooled_blood += lost * LIQUID_BLEED_POOL_FRACTION
	if(unpooled_blood < LIQUID_BLEED_POOL_STEP)
		return
	var/amount = unpooled_blood
	unpooled_blood = 0
	var/blood_id = get_blood_id()
	if(!blood_id || !isturf(loc))
		return
	var/turf/T = loc
	T.pool_liquid(blood_id, amount, bodytemperature)

#undef LIQUID_BLEED_POOL_STEP
#undef LIQUID_BLEED_POOL_FRACTION
