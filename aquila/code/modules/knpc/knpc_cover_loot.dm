// Osłony, zbieranie sprzętu po walce i zakuwanie jeńców przez boarderów KNPC.
// Hook w core: HA.try_cuff() w /datum/ai_goal/human/engage_targets/action() (nsv13/code/modules/overmap/knpc.dm).
// Osłona to tylko to, co naprawdę zatrzymuje pociski: barykada peacekeeper od strony wroga na naszym polu
// albo murek /obj/structure/barricade na polu przed nami (strzelamy przez niego, wróg często trafia w murek).
// Stoły pociski przepuszczają, a leżenie nie chroni przed trafieniem, więc ich nie liczymy.

/// Jak daleko boarder szuka osłony
#define KNPC_COVER_SEARCH_RANGE 5
/// Co ile boarder bez osłony szuka jej ponownie
#define KNPC_COVER_SEARCH_DELAY (3 SECONDS)
/// Osłona ma sens 2–7 pól od wroga
#define KNPC_COVER_MIN_DIST 2
#define KNPC_COVER_MAX_DIST 7
/// Tyle zapasowych magazynów boarder zbiera najwyżej
#define KNPC_SPARE_MAGAZINES 4
/// Zasięg szukania sprzętu i jeńców po walce
#define KNPC_LOOT_RANGE 7
/// Co ile boarder szuka sprzętu do zebrania
#define KNPC_LOOT_SEARCH_DELAY (3 SECONDS)

/datum/component/knpc
	/// Pole osłony, które zajmujemy albo do którego idziemy (turfy nie są usuwane, więc zwykła referencja)
	var/turf/cover_turf
	var/next_cover_search = 0
	/// Przedmiot do zebrania (weakref)
	var/datum/weakref/loot_target
	var/next_loot_search = 0
	/// Trwa zakładanie kajdanek (do_mob usypia)
	var/cuffing = FALSE
	/// Wybrany jeniec (weakref) i kiedy szukać następnego
	var/datum/weakref/prisoner_target
	var/next_prisoner_search = 0

/datum/component/knpc/Destroy(force, silent)
	cover_turf = null
	loot_target = null
	prisoner_target = null
	return ..()

// ---------- Osłony ----------

/// Czy stojąc na T jesteśmy osłonięci przed strzałami od target
/datum/component/knpc/proc/turf_gives_cover(turf/T, atom/target)
	var/turf/target_turf = get_turf(target)
	if(!T || !target_turf || T == target_turf)
		return FALSE
	var/dir_to_target = get_dir(T, target_turf)
	for(var/obj/structure/peacekeeper_barricade/P in T)
		if(P.anchored && !P.closed && (P.dir & dir_to_target))
			return TRUE
	var/obj/structure/barricade/wall = locate() in get_step(T, dir_to_target)
	return wall?.anchored

/// Czy T nadaje się na pozycję: wolne, z ziemią, w zasięgu i z linią strzału, nie zajęte przez innego boardera
/datum/component/knpc/proc/is_good_cover(turf/T, atom/target)
	if(!isopenturf(T) || isgroundlessturf(T) || T.density)
		return FALSE
	var/dist = get_dist(T, target)
	if(dist < KNPC_COVER_MIN_DIST || dist > KNPC_COVER_MAX_DIST)
		return FALSE
	for(var/mob/living/L in T)
		if(L != parent)
			return FALSE
	for(var/obj/O in T)
		if(O.density && !istype(O, /obj/structure/peacekeeper_barricade))
			return FALSE
	for(var/datum/component/knpc/other as anything in GLOB.knpcs)
		if(other == src || other.cover_turf != T)
			continue
		var/mob/living/other_mob = other.parent
		if(!QDELETED(other_mob) && other_mob.stat != DEAD)
			return FALSE
	if(!turf_gives_cover(T, target))
		return FALSE
	return can_see(T, target, dist + 1)

/// Najbliższa dobra osłona przed target w zasięgu KNPC_COVER_SEARCH_RANGE
/datum/component/knpc/proc/find_cover(atom/target)
	var/mob/living/carbon/human/H = parent
	var/turf/target_turf = get_turf(target)
	var/turf/best = null
	var/best_dist = INFINITY
	for(var/obj/structure/S in range(KNPC_COVER_SEARCH_RANGE, H))
		var/turf/candidate = null
		if(istype(S, /obj/structure/peacekeeper_barricade))
			candidate = S.loc
		else if(istype(S, /obj/structure/barricade))
			candidate = get_step(S, get_dir(target_turf, S)) // pole za murkiem patrząc od wroga
		if(!candidate)
			continue
		var/dist = get_dist(H, candidate)
		if(dist >= best_dist || !is_good_cover(candidate, target))
			continue
		best = candidate
		best_dist = dist
	return best

/// Strzelec idzie do osłony albo w niej zostaje. TRUE, gdy osłona przejęła ruch.
/datum/component/knpc/proc/try_take_cover(atom/target)
	var/mob/living/carbon/human/H = parent
	var/turf/here = get_turf(H)
	if(cover_turf && !is_good_cover(cover_turf, target))
		cover_turf = null
	// Już stoimy w osłonie (wybranej albo przypadkiem): zostajemy i strzelamy
	if(here == cover_turf || (!cover_turf && is_good_cover(here, target)))
		cover_turf = here
		path = list()
		dest = null
		return TRUE
	if(!cover_turf && world.time >= next_cover_search)
		next_cover_search = world.time + KNPC_COVER_SEARCH_DELAY
		cover_turf = find_cover(target)
	if(!cover_turf)
		return FALSE
	if(pathfind_to(cover_turf) == KNPC_PATHFIND_FAIL)
		cover_turf = null
		return FALSE
	return TRUE

// ---------- Kajdanki ----------

/// Kajdanki lub opaski przy sobie albo w plecaku (bez tych, które sami mamy na rękach)
/datum/component/knpc/proc/find_cuffs()
	var/mob/living/carbon/human/H = parent
	for(var/obj/item/restraints/handcuffs/cuffs in carried_items())
		if(cuffs != H.handcuffed)
			return cuffs

/// Zakuwa obezwładnionego wroga, jeśli mamy czym. TRUE, gdy boarder się tym zajmuje (zamiast judo i dobijania).
/datum/component/knpc/proc/try_cuff(mob/living/carbon/target)
	if(cuffing)
		return TRUE
	if(!iscarbon(target) || target.handcuffed || target.stat == DEAD)
		return FALSE
	if(target.get_num_arms(FALSE) < 2 && !target.get_arm_ignore())
		return FALSE
	var/obj/item/restraints/handcuffs/cuffs = find_cuffs()
	if(!cuffs)
		return FALSE
	var/mob/living/carbon/human/H = parent
	if(get_dist(H, target) > 1)
		// Nieosiągalny (za szybą, za zamkniętymi drzwiami): zostawiamy go zwykłej walce
		return pathfind_to(target) != KNPC_PATHFIND_FAIL
	path = list() // inaczej next_path_step() wchodzi na pole leżącego i przerywa do_mob
	dest = null
	INVOKE_ASYNC(src, PROC_REF(do_cuff), cuffs, target)
	return TRUE

/datum/component/knpc/proc/do_cuff(obj/item/restraints/handcuffs/cuffs, mob/living/carbon/target)
	cuffing = TRUE
	var/mob/living/carbon/human/H = parent
	if(!H.is_holding(cuffs))
		if(isitem(cuffs.loc) && cuffs.loc != H)
			SEND_SIGNAL(cuffs.loc, COMSIG_TRY_STORAGE_TAKE, cuffs, H.drop_location(), TRUE)
		else
			H.temporarilyRemoveItemFromInventory(cuffs)
		if(!H.put_in_hands(cuffs))
			cuffing = FALSE
			return
	H.say(pick("Leżeć! Ręce za plecy!", "Masz prawo zachować milczenie!", "Mam jeńca!"), forced = "knpc AI")
	cuffs.attack(target, H)
	if(!QDELETED(cuffs) && H.is_holding(cuffs) && H.back) // nie wyszło: kajdanki wracają do plecaka
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_INSERT, cuffs, H, TRUE)
	cuffing = FALSE

/// Zakuty wróg nie jest już zagrożeniem
/datum/ai_goal/get_aggressors(datum/component/knpc/HA)
	var/list/found = ..()
	. = list()
	for(var/atom/movable/A as anything in found)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(C.handcuffed)
				continue
		. += A

/// Po walce boarder z kajdankami zakuwa nieprzytomnego albo obezwładnionego wroga
/datum/ai_goal/human/secure_prisoner
	name = "Secure prisoner"
	score = AI_SCORE_DEFAULT + 5
	required_ai_flags = null

/datum/ai_goal/human/secure_prisoner/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	if(H.incapacitated() || length(get_aggressors(HA)) || !HA.find_cuffs())
		return 0
	return get_prisoner(HA) ? score : 0

/// Zapamiętany jeniec, jeśli nadal się nadaje; nowe szukanie (view) najwyżej co KNPC_LOOT_SEARCH_DELAY
/datum/ai_goal/human/secure_prisoner/proc/get_prisoner(datum/component/knpc/HA)
	var/mob/living/carbon/human/H = HA.parent
	var/mob/living/carbon/human/prisoner = HA.prisoner_target?.resolve()
	if(prisoner && is_valid_prisoner(HA, prisoner) && get_dist(H, prisoner) <= KNPC_LOOT_RANGE)
		return prisoner
	HA.prisoner_target = null
	if(world.time < HA.next_prisoner_search)
		return null
	HA.next_prisoner_search = world.time + KNPC_LOOT_SEARCH_DELAY
	prisoner = find_prisoner(HA)
	if(prisoner)
		HA.prisoner_target = WEAKREF(prisoner)
	return prisoner

/datum/ai_goal/human/secure_prisoner/proc/is_valid_prisoner(datum/component/knpc/HA, mob/living/carbon/human/victim)
	var/mob/living/carbon/human/H = HA.parent
	if(QDELETED(victim) || victim == H || victim.stat == DEAD || victim.handcuffed || istype(victim, /mob/living/carbon/human/ai_boarder))
		return FALSE
	if(WEAKREF(victim) in HA.unreachable_items)
		return FALSE
	if(victim.stat == CONSCIOUS && !victim.incapacitated())
		return FALSE
	return !H.faction_check_mob(victim)

/datum/ai_goal/human/secure_prisoner/proc/find_prisoner(datum/component/knpc/HA)
	var/mob/living/carbon/human/H = HA.parent
	var/mob/living/carbon/human/best = null
	var/best_dist = INFINITY
	for(var/mob/living/carbon/human/victim in view(KNPC_LOOT_RANGE, H))
		if(!is_valid_prisoner(HA, victim))
			continue
		var/dist = get_dist(H, victim)
		if(dist < best_dist)
			best = victim
			best_dist = dist
	return best

/datum/ai_goal/human/secure_prisoner/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/prisoner = get_prisoner(HA)
	if(prisoner && !HA.try_cuff(prisoner))
		// Nie da się dojść: na minutę pomijamy go tak jak nieosiągalne przedmioty
		if(!HA.unreachable_items)
			HA.unreachable_items_reset_at = world.time + 1 MINUTES
		LAZYOR(HA.unreachable_items, WEAKREF(prisoner))
		HA.prisoner_target = null

// ---------- Zbieranie sprzętu ----------

/// Czy boarder chce ten przedmiot: magazyn do swojej broni (do KNPC_SPARE_MAGAZINES), medipen gdy nie ma żadnego, kajdanki gdy nie ma
/datum/component/knpc/proc/wants_item(obj/item/I)
	var/mob/living/carbon/human/H = parent
	if(istype(I, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/M = I
		var/obj/item/gun/ballistic/B = H.get_active_held_item()
		if(!istype(B) || !istype(M, B.mag_type) || !M.ammo_count() || M == B.magazine)
			return FALSE
		return count_spare_magazines(B) < KNPC_SPARE_MAGAZINES
	if(istype(I, /obj/item/reagent_containers/hypospray/medipen/survival))
		return I.reagents?.total_volume && !find_medipen()
	if(istype(I, /obj/item/restraints/handcuffs))
		return !find_cuffs()
	return FALSE

/datum/component/knpc/proc/count_spare_magazines(obj/item/gun/ballistic/B)
	. = 0
	for(var/obj/item/ammo_box/magazine/M in carried_items())
		if(M != B.magazine && istype(M, B.mag_type) && M.ammo_count())
			.++

/// Najbliższy chciany przedmiot leżący na podłodze albo przy martwym ciele w zasięgu wzroku
/datum/component/knpc/proc/find_loot()
	var/mob/living/carbon/human/H = parent
	var/obj/item/best = null
	var/best_dist = INFINITY
	for(var/atom/movable/A in view(KNPC_LOOT_RANGE, H))
		if(A == H)
			continue
		var/list/candidates
		if(isitem(A) && isturf(A.loc))
			candidates = list(A)
		else if(ishuman(A))
			var/mob/living/carbon/human/body = A
			if(body.stat != DEAD)
				continue
			candidates = body.GetAllContents()
		else
			continue
		var/dist = get_dist(H, A)
		if(dist >= best_dist)
			continue
		for(var/obj/item/I in candidates)
			if(WEAKREF(I) in unreachable_items)
				continue
			if(iscarbon(I.loc))
				var/mob/living/carbon/owner = I.loc
				if(I == owner.handcuffed || I == owner.legcuffed)
					continue // nie zdejmujemy kajdanek z rąk zwłok
			if(!wants_item(I))
				continue
			best = I
			best_dist = dist
			break
	return best

/// Czy I nadal leży na podłodze albo przy martwym ciele (żywym nic nie zabieramy)
/datum/component/knpc/proc/loot_available(obj/item/I)
	if(QDELETED(I))
		return FALSE
	if(isturf(I.loc))
		return TRUE
	var/mob/living/carbon/human/holder = loot_holder(I)
	return ishuman(holder) && holder != parent && holder.stat == DEAD // tak jak w find_loot(): tylko martwi ludzie

/// Ciało albo pole, przy którym trzeba stanąć, żeby wziąć I
/datum/component/knpc/proc/loot_holder(obj/item/I)
	var/atom/holder = I
	while(holder && !isturf(holder.loc) && !ismob(holder.loc))
		holder = holder.loc
	return ismob(holder?.loc) ? holder.loc : get_turf(I)

/// Wyjmuje I z ciała, plecaka albo z podłogi i chowa do plecaka (albo do kieszeni)
/datum/component/knpc/proc/take_loot(obj/item/I)
	var/mob/living/carbon/human/H = parent
	var/atom/holder = loot_holder(I)
	if(ismob(I.loc))
		var/mob/body = I.loc
		if(!body.temporarilyRemoveItemFromInventory(I))
			return FALSE
		I.forceMove(H.drop_location())
	else if(isitem(I.loc))
		SEND_SIGNAL(I.loc, COMSIG_TRY_STORAGE_TAKE, I, H.drop_location(), TRUE)
	if(!isturf(I.loc) || !H.Adjacent(I))
		return FALSE
	if(ismob(holder))
		H.visible_message("<span class='notice'>[H] przeszukuje [holder] i zabiera [I].</span>")
	if(H.back && SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_INSERT, I, H, TRUE))
		return TRUE
	return H.equip_to_slot_if_possible(I, ITEM_SLOT_LPOCKET, disable_warning = TRUE) || H.equip_to_slot_if_possible(I, ITEM_SLOT_RPOCKET, disable_warning = TRUE)

/// Po walce boarder zbiera magazyny do swojej broni, medipen i kajdanki z podłogi i z ciał
/datum/ai_goal/human/scavenge
	name = "Scavenge"
	score = AI_SCORE_DEFAULT
	required_ai_flags = null

/datum/ai_goal/human/scavenge/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	if(H.incapacitated() || length(get_aggressors(HA)))
		return 0
	var/obj/item/I = HA.loot_target?.resolve()
	if(!I || !HA.loot_available(I) || !HA.wants_item(I))
		HA.loot_target = null
		if(world.time < HA.next_loot_search)
			return 0
		HA.next_loot_search = world.time + KNPC_LOOT_SEARCH_DELAY
		I = HA.find_loot()
		if(!I)
			return 0
		HA.loot_target = WEAKREF(I)
	return score

/datum/ai_goal/human/scavenge/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/H = HA.parent
	var/obj/item/I = HA.loot_target?.resolve()
	if(!I || !HA.loot_available(I))
		HA.loot_target = null
		return
	var/atom/holder = HA.loot_holder(I)
	if(get_dist(H, holder) > 1)
		if(HA.pathfind_to(holder) == KNPC_PATHFIND_FAIL)
			if(!HA.unreachable_items)
				HA.unreachable_items_reset_at = world.time + 1 MINUTES
			LAZYOR(HA.unreachable_items, WEAKREF(I))
			HA.loot_target = null
		return
	if(!HA.take_loot(I))
		// Nie dało się schować (pełny plecak): nie wracamy do tego przedmiotu
		if(!HA.unreachable_items)
			HA.unreachable_items_reset_at = world.time + 1 MINUTES
		LAZYOR(HA.unreachable_items, WEAKREF(I))
	HA.loot_target = null

#undef KNPC_COVER_SEARCH_RANGE
#undef KNPC_COVER_SEARCH_DELAY
#undef KNPC_COVER_MIN_DIST
#undef KNPC_COVER_MAX_DIST
#undef KNPC_SPARE_MAGAZINES
#undef KNPC_LOOT_RANGE
#undef KNPC_LOOT_SEARCH_DELAY
