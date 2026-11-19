// Cechy charakteru: z gruntu zły (tg), ekstrawertyk i introwertyk (Monkestation), snob (Monkestation), niechęć do dotyku (tg/Monkestation),
// nerwowy (Goon + Tau Ceti), afekt pseudobulbarny (Skyrat) i kleptomania (Monkestation).

// --- Z gruntu zły ---

/datum/quirk/evil
	name = "Z Gruntu Zły"
	desc = "Tam, gdzie powinna być dusza, jest tylko czarna jak atrament pustka. Dbasz o swoją pozycję, ale kto zbyt długo patrzy w twoje zimne, obojętne oczy, pozna prawdę. Jesteś naprawdę zły. Nic ci nie dolega: sam wybrałeś zło i jesteś mu wierny. Twoje ambicje są ponad wszystkim."
	icon = "hand-middle-finger"
	value = 0
	mob_trait = TRAIT_EVIL
	gain_text = "<span class='notice'>Pozbywasz się resztek człowieczeństwa. Masz robotę do zrobienia.</span>"
	lose_text = "<span class='notice'>Nagle bardziej przejmujesz się innymi i ich potrzebami.</span>"
	medical_record_text = "Pacjent celująco zdał wszystkie testy przystosowania społecznego, ale miał kłopot z testami empatii."

/datum/quirk/evil/add()
	RegisterSignal(quirk_holder, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/quirk/evil/remove()
	UnregisterSignal(quirk_holder, COMSIG_PARENT_EXAMINE)

/datum/quirk/evil/post_add()
	to_chat(quirk_holder, "<span class='big info'>Pamiętaj: zło z wyboru NIE daje ci żadnego dodatkowego prawa do atakowania ludzi ani siania chaosu.</span>")

/// Empata widzi zło w oczach (tg: /datum/component/empathy, EMPATH_SEE_EVIL)
/datum/quirk/evil/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(user == quirk_holder || !HAS_TRAIT(user, TRAIT_EMPATH))
		return
	examine_list += "<span class='warning'>Z oczu bije zimny, obojętny dystans. W duszy tej osoby jest tylko ciemność.</span>"

// --- Ekstrawertyk i introwertyk ---
// Monkestation daje nastrój z baru tylko ekstrawertykom, a z biblioteki tylko introwertykom.
// U nas bar cieszy wszystkich, więc ekstrawertyk dostaje w barze dodatkowy nastrój, a introwertyk traci bonus z baru.

/datum/quirk/extrovert
	name = "Ekstrawertyk"
	desc = "Rozmowy z innymi dodają ci energii, a wolny czas najchętniej spędzasz w barze."
	icon = "users"
	value = 0
	mob_trait = TRAIT_EXTROVERT
	mood_quirk = TRUE
	gain_text = "<span class='notice'>Masz ochotę spędzić czas wśród ludzi.</span>"
	lose_text = "<span class='danger'>Masz już dość barów.</span>"
	medical_record_text = "Pacjent nie potrafi się zamknąć."

/datum/quirk/extrovert/add()
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_ENTERED_AREA, PROC_REF(on_enter_area))
	on_enter_area(quirk_holder, get_area(quirk_holder))

/datum/quirk/extrovert/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOVABLE_ENTERED_AREA)
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "extrovert_area")

/datum/quirk/extrovert/proc/on_enter_area(datum/source, area/new_area)
	SIGNAL_HANDLER
	if(new_area && (new_area in GLOB.bar_areas))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "extrovert_area", /datum/mood_event/extrovert_bar)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "extrovert_area")

/datum/quirk/introvert
	name = "Introwertyk"
	desc = "Energii dodaje ci czas spędzony w samotności, a wolne chwile najchętniej spędzasz w bibliotece, w kwaterach albo w kaplicy."
	icon = "book-reader"
	value = 0
	mob_trait = TRAIT_INTROVERT
	mood_quirk = TRUE
	gain_text = "<span class='notice'>Masz ochotę poczytać w spokoju dobrą książkę.</span>"
	lose_text = "<span class='danger'>Biblioteki wydają ci się nudne.</span>"
	medical_record_text = "Pacjent niewiele mówi."

/datum/quirk/introvert/add()
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_ENTERED_AREA, PROC_REF(on_enter_area))
	on_enter_area(quirk_holder, get_area(quirk_holder))

/datum/quirk/introvert/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOVABLE_ENTERED_AREA)
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "introvert_area")

/datum/quirk/introvert/proc/on_enter_area(datum/source, area/new_area)
	SIGNAL_HANDLER
	if(new_area && aq_introvert_quiet_area(new_area.type))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "introvert_area", /datum/mood_event/introvert_library)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "introvert_area")

/// Gdzie introwertyk odpoczywa. Biblioteka jest tylko na części map, więc spokój dają też kwatery załogi i kaplica.
/proc/aq_introvert_quiet_area(area_type)
	return ispath(area_type, /area/library) || ispath(area_type, /area/crew_quarters/dorms) || ispath(area_type, /area/chapel)

/area/crew_quarters/bar/mood_check(mob/living/carbon/subject)
	if(HAS_TRAIT(subject, TRAIT_INTROVERT))
		return FALSE
	return ..()

/datum/mood_event/extrovert_bar
	description = "<span class='nicegreen'>Uwielbiam towarzystwo w barze!</span>\n"
	mood_change = 3

/datum/mood_event/introvert_library
	description = "<span class='nicegreen'>Uwielbiam spokój w cichym miejscu!</span>\n"
	mood_change = 5

// --- Snob ---
// Monkestation ocenia piękno pomieszczenia (system beauty z tg, którego nie mamy). Tu snob ocenia bałagan wokół siebie.

/datum/quirk/snob
	name = "Snob"
	desc = "Liczą się dla ciebie rzeczy wysokiej klasy. Jeśli pomieszczenie nie wygląda porządnie, to szkoda w nim przebywać, prawda?"
	icon = "user-tie"
	value = 0
	mob_trait = TRAIT_SNOB
	mood_quirk = TRUE
	process = TRUE
	gain_text = "<span class='notice'>Czujesz, że wiesz, jak powinny wyglądać rzeczy.</span>"
	lose_text = "<span class='notice'>A kogo w ogóle obchodzi wystrój?</span>"
	medical_record_text = "Pacjent wydaje się dość zadufany w sobie."
	/// Co ile ticków (sekund) rozglądać się po pomieszczeniu
	var/check_interval = 5
	var/ticks_left = 0

/datum/quirk/snob/remove()
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "area_beauty")

/datum/quirk/snob/on_process(delta_time)
	if(--ticks_left > 0)
		return
	ticks_left = check_interval
	var/mess = count_mess()
	if(mess >= 10)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "area_beauty", /datum/mood_event/horridroom)
	else if(mess >= 5)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "area_beauty", /datum/mood_event/badroom)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "area_beauty")

/// Ile śmieci i brudu widać w pobliżu (poza kosmosem)
/datum/quirk/snob/proc/count_mess()
	if(!isturf(quirk_holder.loc) || isspaceturf(quirk_holder.loc))
		return 0
	var/mess = 0
	for(var/atom/movable/thing in view(4, quirk_holder))
		if(istype(thing, /obj/effect/decal/cleanable) || istype(thing, /obj/item/trash))
			mess++
	return mess

/datum/mood_event/horridroom
	description = "<span class='boldwarning'>To pomieszczenie wygląda okropnie!</span>\n"
	mood_change = -5

/datum/mood_event/badroom
	description = "<span class='warning'>To pomieszczenie wygląda naprawdę źle.</span>\n"
	mood_change = -3

// --- Niechęć do dotyku ---

/datum/quirk/bad_touch
	name = "Niechęć do Dotyku"
	desc = "Nie lubisz przytulania i odruchowo wymykasz się z przytuleń, głaskania i uścisków dłoni. Gdy ktoś cię złapie albo dotknie, kiedy leżysz lub jesteś skrępowany, psuje ci to humor."
	icon = "hand-paper"
	value = -1
	mob_trait = TRAIT_BADTOUCH
	mood_quirk = TRUE
	gain_text = "<span class='danger'>Chcesz tylko, żeby ludzie zostawili cię w spokoju.</span>"
	lose_text = "<span class='notice'>Przydałby ci się porządny przytulas.</span>"
	medical_record_text = "Pacjent nie znosi dotyku. Możliwa niezdiagnozowana hafefobia."

/datum/quirk/bad_touch/remove()
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "bad_touch")

/// Ktoś dotknął osoby, która tego nie znosi
/mob/living/proc/aq_uncomfortable_touch()
	if(stat == DEAD)
		return
	var/datum/component/mood/mood = GetComponent(/datum/component/mood)
	if(!mood)
		return
	if(mood.sanity <= SANITY_NEUTRAL)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "bad_touch", /datum/mood_event/very_bad_touch)
	else
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "bad_touch", /datum/mood_event/bad_touch)

/mob/living/carbon/help_shake_act(mob/living/carbon/M)
	. = ..()
	if(M == src || on_fire || !HAS_TRAIT(src, TRAIT_BADTOUCH))
		return
	// Przytulas i głaskanie nie cieszą, tylko drażnią
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "hug")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "friendly_hug")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "headpat")
	aq_uncomfortable_touch()

/// Unik przed przytuleniem, głaskaniem i uściskiem dłoni (dawniej osobna cecha Przestrzeń Osobista z VOREStation).
/// Nie da się uniknąć, gdy leżysz, jesteś skrępowany albo płoniesz: wtedy dotyk dochodzi do skutku i psuje humor.
/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(M != src && HAS_TRAIT(src, TRAIT_BADTOUCH) && stat == CONSCIOUS && (mobility_flags & MOBILITY_STAND) && !restrained() && !on_fire)
		visible_message("<span class='notice'>[src] zręcznie unika dotyku [M].</span>", \
			"<span class='notice'>Zręcznie unikasz dotyku [M].</span>")
		return
	return ..()

/mob/living/start_pulling(atom/movable/AM, state, force = pull_force, supress_message = FALSE)
	. = ..()
	if(pulling != AM || !isliving(AM) || AM == src || !HAS_TRAIT(AM, TRAIT_BADTOUCH))
		return
	var/mob/living/pulled = AM
	pulled.aq_uncomfortable_touch()

/datum/mood_event/bad_touch
	description = "<span class='warning'>Nie lubię, kiedy ktoś mnie dotyka.</span>\n"
	mood_change = -3
	timeout = 4 MINUTES

/datum/mood_event/very_bad_touch
	description = "<span class='boldwarning'>Naprawdę nie znoszę, kiedy ktoś mnie dotyka.</span>\n"
	mood_change = -5
	timeout = 4 MINUTES

// --- Nerwowy ---
// Goon: widok ran i przemocy czasem wywołuje atak paniki. Tau Ceti: nerwowe jąkanie.

/datum/quirk/nervous
	name = "Nerwowy"
	desc = "Ciągle jesteś zdenerwowany. Widok ran albo przemocy czasem wywołuje u ciebie atak paniki."
	icon = "grimace"
	value = -1
	mob_trait = TRAIT_NERVOUS
	process = TRUE
	gain_text = "<span class='danger'>Jesteś kłębkiem nerwów.</span>"
	lose_text = "<span class='notice'>Już tak się nie denerwujesz.</span>"
	medical_record_text = "Pacjent jest stale zdenerwowany."
	/// Zdrowie widzianych istot przy poprzednim ticku (klucz: REF)
	var/list/last_health = list()

/datum/quirk/nervous/remove()
	last_health = null

/datum/quirk/nervous/on_process(delta_time)
	if(quirk_holder.stat != CONSCIOUS)
		return
	if(DT_PROB(5, delta_time))
		quirk_holder.stuttering = max(quirk_holder.stuttering, 10)

	var/witnessed_violence = FALSE
	var/list/new_health = list()
	for(var/mob/living/witnessed in oview(6, quirk_holder))
		var/key = REF(witnessed)
		var/old_health = last_health[key]
		if(!isnull(old_health) && old_health - witnessed.health >= 5)
			witnessed_violence = TRUE
		new_health[key] = witnessed.health
	last_health = new_health

	if(witnessed_violence && prob(10))
		freak_out()

/// Atak paniki na widok przemocy
/datum/quirk/nervous/proc/freak_out()
	if(quirk_holder.reagents?.has_reagent(/datum/reagent/medicine/psicodine))
		return
	INVOKE_ASYNC(quirk_holder, TYPE_PROC_REF(/mob, emote), "scream")
	quirk_holder.Stun(2 SECONDS)
	quirk_holder.Jitter(10)
	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "nervous", /datum/mood_event/nervous)

// --- Afekt pseudobulbarny ---

/datum/quirk/joker
	name = "Afekt Pseudobulbarny"
	desc = "Co jakiś czas dopadają cię niekontrolowane napady śmiechu."
	icon = "grin-tears"
	value = 0
	process = TRUE
	medical_record_text = "Pacjent cierpi na nagłe, niekontrolowane napady śmiechu."
	/// Kiedy znów może przyjść napad
	var/pcooldown = 0
	var/pcooldown_time = 60 SECONDS

/datum/quirk/joker/on_spawn()
	aq_nastroj_give_item(new /obj/item/paper/joker(get_turf(quirk_holder)))

/datum/quirk/joker/on_process(delta_time)
	if(pcooldown > world.time)
		return
	pcooldown = world.time + pcooldown_time
	if(quirk_holder.stat != CONSCIOUS || !prob(20))
		return
	laugh()
	addtimer(CALLBACK(src, PROC_REF(laugh)), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(laugh)), 10 SECONDS)

/datum/quirk/joker/proc/laugh()
	if(QDELETED(quirk_holder) || quirk_holder.stat != CONSCIOUS)
		return
	quirk_holder.emote("laugh")

/obj/item/paper/joker
	name = "karta niepełnosprawności"
	desc = "Uśmiechnij się, choć serce boli."
	icon = 'aquila/icons/obj/joker_card.dmi'
	icon_state = "joker"
	show_written_words = FALSE
	default_raw_text = "<i><div style='border-style:solid;text-align:center;border-width:5px;margin: 20px;margin-bottom:0px'><div style='margin-top:20px;margin-bottom:20px;font-size:150%;'>Wybacz mój śmiech:<br>to choroba.</div></div></i><br><i><div style='border-style:solid;text-align:center;border-width:5px;margin: 20px;margin-bottom:0px'><div style='margin-top:20px;margin-bottom:20px;font-size:100%;'><b>To schorzenie wywołuje nagły, częsty<br>i niekontrolowany śmiech,<br>który nie pasuje do moich uczuć.<br>Zdarza się po urazach mózgu<br>i przy niektórych chorobach neurologicznych.</b></div></div></i><br><center><b>PROSZĘ ODDAĆ TĘ KARTĘ</b></center>"

// --- Kleptomania ---

/datum/quirk/kleptomaniac
	name = "Kleptomania"
	desc = "Na statku pełno rzeczy za darmo! Nikt nie zauważy, jak coś... weźmiesz, prawda?"
	icon = "shopping-bag"
	value = -1
	medical_record_text = "Pacjent ma nieświadomą skłonność do podnoszenia przedmiotów z ziemi."

/datum/quirk/kleptomaniac/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.gain_trauma(/datum/brain_trauma/severe/kleptomaniac, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/kleptomaniac/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/kleptomaniac, TRAUMA_RESILIENCE_ABSOLUTE)

/// Kleptomania (Monkestation): odruchowo podnosi drobne przedmioty z ziemi obok. Bez okradania kieszeni innych.
/datum/brain_trauma/severe/kleptomaniac
	name = "Kleptomania"
	desc = "Pacjent ma skłonność do kradzieży."
	scan_desc = "kleptomania"
	gain_text = "<span class='warning'>Nagle masz ochotę to wziąć. Przecież nikt nie zauważy.</span>"
	lose_text = "<span class='notice'>Nie masz już ochoty brać cudzych rzeczy.</span>"
	random_gain = FALSE
	/// Kiedy znów może coś wziąć
	COOLDOWN_DECLARE(steal_cd)

/datum/brain_trauma/severe/kleptomaniac/on_gain()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_taken))

/datum/brain_trauma/severe/kleptomaniac/on_lose(silent)
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
	return ..()

/// W walce albo przy umieraniu głowa jest zajęta czymś innym
/datum/brain_trauma/severe/kleptomaniac/proc/damage_taken(datum/source, damage_amount, damage_type)
	SIGNAL_HANDLER
	if(damage_amount >= 5 && (damage_type == BRUTE || damage_type == BURN || damage_type == STAMINA))
		COOLDOWN_START(src, steal_cd, 12 SECONDS)

/datum/brain_trauma/severe/kleptomaniac/on_life()
	if(owner.stat != CONSCIOUS || owner.incapacitated())
		return
	if(!prob(10) || !COOLDOWN_FINISHED(src, steal_cd))
		return
	if(!length(owner.get_empty_held_indexes()))
		return
	steal_from_ground()
	// Mały odstęp, żeby nie było to przewidywalne
	COOLDOWN_START(src, steal_cd, 8 SECONDS)

/// Podnosi losowy drobny przedmiot leżący obok
/datum/brain_trauma/severe/kleptomaniac/proc/steal_from_ground()
	var/list/stealables = list()
	for(var/obj/item/potential_stealable in oview(1, owner))
		if(!isturf(potential_stealable.loc) || potential_stealable.w_class >= WEIGHT_CLASS_BULKY)
			continue
		if(potential_stealable.anchored || !(potential_stealable.interaction_flags_item & INTERACT_ITEM_ATTACK_HAND_PICKUP))
			continue
		stealables += potential_stealable
	if(!length(stealables))
		return FALSE

	var/obj/item/stealable = pick(stealables)
	var/pre_dir = owner.dir
	var/previous_hand = owner.active_hand_index
	// Pełna ręka: bierze drugą, pustą
	if(owner.get_active_held_item())
		var/list/empty_hands = owner.get_empty_held_indexes()
		owner.swap_hand(empty_hands[1])
	owner.log_message("attempted to pick up [stealable] (kleptomania)", LOG_ATTACK)
	stealable.attack_hand(owner) // bez komunikatu: można nawet nie zauważyć, że coś się wzięło
	if(owner.active_hand_index != previous_hand)
		owner.swap_hand(previous_hand)
	owner.setDir(pre_dir)
	return TRUE
