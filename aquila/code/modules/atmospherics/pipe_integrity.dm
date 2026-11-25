// AQUILA - wytrzymałość rur (plan maszynowni, etap E1).
// Rura pęka, gdy ciśnienie albo temperatura w jej sieci rażąco przekroczy próg. Pęknięta rura zostaje na miejscu
// i przecieka na swój kafelek, dopóki ktoś jej nie zespawa (wzór: goonstation). Rurę można wzmocnić plastalą
// (próg ×10), a na mapach helperem /obj/effect/mapping_helpers/pipe_reinforce.
// Sprawdzanie idzie raz na sieć rur (jedna mieszanina auxmos), nie raz na rurę: hook w /datum/pipeline/process().

/// Próg ciśnienia zwykłej rury (kPa). Pompy dają do 4500 kPa, pompa objętościowa staje przy 9000 kPa.
#define AQ_PIPE_PRESSURE_LIMIT 50000
/// Próg temperatury zwykłej rury (K).
#define AQ_PIPE_TEMPERATURE_LIMIT 10000
/// Ile razy wytrzymalsza jest rura wzmocniona plastalą.
#define AQ_PIPE_REINFORCED_MULT 10
/// Arkusze plastali potrzebne do wzmocnienia rury (i oddawane przy jej rozkręceniu).
#define AQ_PIPE_REINFORCE_SHEETS 5
/// Co ile sieć sprawdza obciążenie.
#define AQ_PIPE_CHECK_INTERVAL (5 SECONDS)
/// Od jakiego obciążenia (część progu) rury jęczą i pokazują ostrzeżenie.
#define AQ_PIPE_WARN_STRESS 0.8
/// Jaka część gazu sieci ucieka co cykl przez jedną pękniętą rurę.
#define AQ_PIPE_LEAK_RATIO 0.02

/obj/machinery/atmospherics/pipe
	/// Rura wzmocniona plastalą (próg ×AQ_PIPE_REINFORCED_MULT)
	var/aq_reinforced = FALSE
	/// Rura pękła i przecieka do zespawania
	var/aq_ruptured = FALSE
	/// Próg ciśnienia rury niewzmocnionej (kPa)
	var/aq_pressure_limit = AQ_PIPE_PRESSURE_LIMIT
	/// Próg temperatury rury niewzmocnionej (K)
	var/aq_temperature_limit = AQ_PIPE_TEMPERATURE_LIMIT

/datum/pipeline
	/// Kiedy sieć następny raz sprawdzi obciążenie
	var/aq_next_integrity_check = 0
	/// Do kiedy sieć nie pęknie ponownie (ochrona po pęknięciu, jak u Goona)
	var/aq_rupture_cooldown = 0
	/// Liczba członków, dla której policzono progi i listę przecieków (sieć przebudowana = inna liczba)
	var/aq_cached_members = -1
	/// Najniższy próg ciśnienia wśród rur sieci
	var/aq_min_pressure_limit = AQ_PIPE_PRESSURE_LIMIT
	/// Najniższy próg temperatury wśród rur sieci
	var/aq_min_temperature_limit = AQ_PIPE_TEMPERATURE_LIMIT
	/// Pęknięte rury tej sieci
	var/list/obj/machinery/atmospherics/pipe/aq_leaks

/particles/smoke/steam/aq_pipe_leak
	spawning = 1
	velocity = list(0, 0.3, 0)
	friction = 0.25

/// Próg ciśnienia tej rury (kPa), z wzmocnieniem
/obj/machinery/atmospherics/pipe/proc/aq_get_pressure_limit()
	return aq_pressure_limit * (aq_reinforced ? AQ_PIPE_REINFORCED_MULT : 1)

/// Próg temperatury tej rury (K), z wzmocnieniem
/obj/machinery/atmospherics/pipe/proc/aq_get_temperature_limit()
	return aq_temperature_limit * (aq_reinforced ? AQ_PIPE_REINFORCED_MULT : 1)

/// Obciążenie rury przez gaz jej sieci: 1 = próg
/obj/machinery/atmospherics/pipe/proc/aq_get_stress()
	var/datum/gas_mixture/air = return_air()
	if(!air)
		return 0
	return max(air.return_pressure() / aq_get_pressure_limit(), air.return_temperature() / aq_get_temperature_limit())

/// Zmiana progów albo pęknięcia: sieć przeliczy je w następnym cyklu
/obj/machinery/atmospherics/pipe/proc/aq_invalidate_parent()
	if(parent)
		parent.aq_cached_members = -1

/obj/machinery/atmospherics/pipe/proc/aq_reinforce()
	if(aq_reinforced)
		return FALSE
	aq_reinforced = TRUE
	add_filter("aq_reinforced", 1, outline_filter(1, "#3a3f47"))
	aq_invalidate_parent()
	return TRUE

/obj/machinery/atmospherics/pipe/proc/aq_rupture()
	if(aq_ruptured)
		return FALSE
	var/datum/gas_mixture/air = return_air()
	var/pressure = air ? round(air.return_pressure()) : 0
	var/temperature = air ? round(air.return_temperature()) : 0
	aq_ruptured = TRUE
	particles = new /particles/smoke/steam/aq_pipe_leak
	visible_message("<span class='danger'>[src] pęka z hukiem i zaczyna syczeć!</span>", null, "<span class='hear'>Słyszysz huk pękającego metalu i syk gazu.</span>")
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	investigate_log("ruptured at [pressure] kPa and [temperature] K.", INVESTIGATE_ATMOS)
	message_admins("Rura pękła pod obciążeniem ([pressure] kPa, [temperature] K) w [ADMIN_VERBOSEJMP(src)].")
	if(parent)
		LAZYOR(parent.aq_leaks, src)
	return TRUE

/obj/machinery/atmospherics/pipe/proc/aq_repair()
	if(!aq_ruptured)
		return FALSE
	aq_ruptured = FALSE
	QDEL_NULL(particles)
	if(parent)
		LAZYREMOVE(parent.aq_leaks, src)
	return TRUE

/obj/machinery/atmospherics/pipe/Destroy()
	if(aq_ruptured)
		QDEL_NULL(particles)
		if(parent)
			LAZYREMOVE(parent.aq_leaks, src)
	return ..()

/obj/machinery/atmospherics/pipe/examine(mob/user)
	. = ..()
	if(aq_reinforced)
		. += "<span class='notice'>Rura jest wzmocniona plastalą.</span>"
	. += "<span class='notice'>Wytrzymuje do [aq_get_pressure_limit()] kPa i [aq_get_temperature_limit()] K.</span>"
	if(aq_ruptured)
		. += "<span class='warning'>Rura jest pęknięta i przecieka! Zespawaj ją.</span>"
		return
	var/stress = aq_get_stress()
	if(stress >= AQ_PIPE_WARN_STRESS)
		. += "<span class='warning'>Rura jęczy pod obciążeniem ([round(stress * 100)]% wytrzymałości)!</span>"

/obj/machinery/atmospherics/pipe/welder_act(mob/living/user, obj/item/tool)
	if(!aq_ruptured)
		return ..()
	if(!tool.tool_start_check(user, amount = 1))
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz spawać pęknięcie w [src]...</span>")
	if(!tool.use_tool(src, user, 3 SECONDS, amount = 1, volume = 50))
		return TRUE
	if(aq_repair())
		user.visible_message("<span class='notice'>[user] spawa pęknięcie w [src].</span>", "<span class='notice'>Spawasz pęknięcie w [src].</span>")
		investigate_log("was repaired by [key_name(user)].", INVESTIGATE_ATMOS)
	return TRUE

/obj/machinery/atmospherics/pipe/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/stack/sheet/plasteel))
		return ..()
	var/obj/item/stack/sheet/plasteel/sheets = W
	if(aq_reinforced)
		to_chat(user, "<span class='warning'>[src] jest już wzmocniona.</span>")
		return TRUE
	if(sheets.get_amount() < AQ_PIPE_REINFORCE_SHEETS)
		to_chat(user, "<span class='warning'>Do wzmocnienia rury potrzeba [AQ_PIPE_REINFORCE_SHEETS] arkuszy plastali.</span>")
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz obkładać [src] plastalą...</span>")
	if(!do_after(user, 3 SECONDS, src) || aq_reinforced || !sheets.use(AQ_PIPE_REINFORCE_SHEETS))
		return TRUE
	aq_reinforce()
	user.visible_message("<span class='notice'>[user] wzmacnia [src] plastalą.</span>", "<span class='notice'>Wzmacniasz [src] plastalą.</span>")
	return TRUE

/obj/machinery/atmospherics/pipe/deconstruct(disassembled = TRUE)
	if(aq_reinforced && disassembled && !(flags_1 & NODECONSTRUCT_1) && loc)
		new /obj/item/stack/sheet/plasteel(loc, AQ_PIPE_REINFORCE_SHEETS)
	return ..()

/// Progi i lista przecieków po przebudowie sieci albo zmianie rury
/datum/pipeline/proc/aq_refresh_integrity_cache()
	aq_cached_members = length(members)
	aq_min_pressure_limit = INFINITY
	aq_min_temperature_limit = INFINITY
	aq_leaks = null
	for(var/obj/machinery/atmospherics/pipe/member as anything in members)
		if(QDELETED(member))
			continue
		aq_min_pressure_limit = min(aq_min_pressure_limit, member.aq_get_pressure_limit())
		aq_min_temperature_limit = min(aq_min_temperature_limit, member.aq_get_temperature_limit())
		if(member.aq_ruptured)
			LAZYADD(aq_leaks, member)

/// Wołane z /datum/pipeline/process() co cykl SSair (AQ EDIT w datum_pipeline.dm)
/datum/pipeline/proc/aq_process_integrity()
	if(building || !air)
		return
	if(aq_cached_members != length(members))
		aq_refresh_integrity_cache()
	if(length(aq_leaks))
		aq_leak_gas()
	if(world.time < aq_next_integrity_check)
		return
	aq_next_integrity_check = world.time + AQ_PIPE_CHECK_INTERVAL
	aq_check_integrity()

/// Pęknięte rury wypuszczają gaz sieci na swoje kafelki
/datum/pipeline/proc/aq_leak_gas()
	for(var/obj/machinery/atmospherics/pipe/leak as anything in aq_leaks.Copy())
		if(QDELETED(leak) || !leak.aq_ruptured || leak.parent != src)
			LAZYREMOVE(aq_leaks, leak)
			continue
		var/turf/leak_turf = get_turf(leak)
		if(!leak_turf || air.total_moles() < MINIMUM_MOLE_COUNT)
			continue
		var/datum/gas_mixture/leaked = air.remove_ratio(AQ_PIPE_LEAK_RATIO)
		if(!leaked)
			continue
		leak_turf.assume_air(leaked)
		leak_turf.air_update_turf()
		update = TRUE

/**
 * Sprawdza obciążenie sieci i może rozerwać jedną rurę.
 * Szansa na cykl: (obciążenie − 1) × 20%, od 1% do 50% (1,1× progu ≈ 2%, 2× ≈ 20%).
 * guaranteed - pęknięcie bez losowania i bez ochrony po poprzednim (dla testów)
 * Zwraca rurę, która pękła, albo null.
 */
/datum/pipeline/proc/aq_check_integrity(guaranteed = FALSE)
	if(aq_cached_members != length(members))
		aq_refresh_integrity_cache()
	if(aq_min_pressure_limit == INFINITY) // sieć bez rur (same urządzenia połączone bezpośrednio)
		return
	var/stress = max(air.return_pressure() / aq_min_pressure_limit, air.return_temperature() / aq_min_temperature_limit)
	if(stress < AQ_PIPE_WARN_STRESS)
		return
	if(!guaranteed && world.time < aq_rupture_cooldown)
		return
	var/list/obj/machinery/atmospherics/pipe/overloaded = list()
	var/list/obj/machinery/atmospherics/pipe/strained = list()
	for(var/obj/machinery/atmospherics/pipe/member as anything in members)
		if(QDELETED(member) || member.aq_ruptured)
			continue
		var/member_stress = member.aq_get_stress()
		if(member_stress > 1)
			overloaded += member
		else if(member_stress >= AQ_PIPE_WARN_STRESS)
			strained += member
	if(!length(overloaded))
		if(length(strained) && prob(30))
			var/obj/machinery/atmospherics/pipe/creaking = pick(strained)
			playsound(creaking, pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg', 'sound/effects/creak3.ogg'), 40, TRUE)
		return
	if(!guaranteed && !prob(clamp((stress - 1) * 20, 1, 50)))
		var/obj/machinery/atmospherics/pipe/groaning = pick(overloaded)
		playsound(groaning, pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg', 'sound/effects/creak3.ogg'), 60, TRUE)
		return
	var/obj/machinery/atmospherics/pipe/victim = pick(overloaded)
	if(!victim.aq_rupture())
		return
	aq_rupture_cooldown = world.time + rand(20 SECONDS, 40 SECONDS)
	return victim

/// Helper mapowy: wzmacnia plastalą wszystkie rury na swoim kafelku (np. gorąca pętla TEG)
/obj/effect/mapping_helpers/pipe_reinforce
	name = "pipe reinforcer"
	icon_state = "pipe-3"
	color = "#3a3f47"
	late = TRUE

/obj/effect/mapping_helpers/pipe_reinforce/LateInitialize()
	for(var/obj/machinery/atmospherics/pipe/pipe in loc)
		pipe.aq_reinforce()
	qdel(src)

#undef AQ_PIPE_PRESSURE_LIMIT
#undef AQ_PIPE_TEMPERATURE_LIMIT
#undef AQ_PIPE_REINFORCED_MULT
#undef AQ_PIPE_REINFORCE_SHEETS
#undef AQ_PIPE_CHECK_INTERVAL
#undef AQ_PIPE_WARN_STRESS
#undef AQ_PIPE_LEAK_RATIO
