// AQUILA - reagenty z przeglądu 246 kodów (raport/reagenty_02_plan_portu.md), grupa narzedzia.
// Narzędzia i chemia użytkowa: superklej (Goon, /vg/), krzemian (Goon), beton (tg), dekonstruktor materii (Eris),
// trawo-gro (Goon), serum genezy (Shiptest), azotan srebra (Goon), odciskowe nanoboty (Eris), sól święcona (/vg/).
// Działanie według planu, nie według oryginałów; receptury własne z naszych składników.

/// Superklej: jak długo trzyma przedmiot w dłoni, przedmiot na podłodze i zaklejoną ranę
#define AQ_SUPERGLUE_TIME (3 MINUTES)
/// Ból zaklejonej rany (pain/pain.dm, krytyczna rana to 30)
#define AQ_SUPERGLUE_PAIN 45
/// Zarazki, które klej zamyka w ranie (medical/germs.dm, zakażenie od 30); z szansą drugie tyle
#define AQ_SUPERGLUE_GERMS 20
#define AQ_SUPERGLUE_GERMS_EXTRA_CHANCE 50
/// Źródło traitu TRAIT_NODROP od superkleju
#define SUPERGLUE_TRAIT "aq_superglue"
/// Krzemian: wytrzymałość okna za jednostkę i limit jako wielokrotność wytrzymałości bazowej
#define AQ_SILICATE_PER_UNIT 4
#define AQ_SILICATE_MAX_MULT 2
/// Beton: ile trzeba na podłogę i na ścianę, czas zastygania ściany
#define AQ_CONCRETE_FLOOR_VOLUME 5
#define AQ_CONCRETE_WALL_VOLUME 10
#define AQ_CONCRETE_CURE_TIME (30 SECONDS)
#define TRAIT_AQ_CONCRETE_CURING "aq_concrete_curing"
/// Dekonstruktor materii: zwrot materiałów
#define AQ_DECONSTRUCTOR_RETURN 0.75
/// Azotan srebra: jak długo widać odciski
#define AQ_SILVER_NITRATE_TIME (2 MINUTES)

// --- Superklej ---

/obj/item
	/// Do kiedy trzyma superklej (w dłoni albo na podłodze)
	var/aq_superglue_until = 0
	/// Superklej przykleił go do podłogi (anchored od kleju, nie od mapy)
	var/aq_glued_down = FALSE

/obj/item/bodypart
	/// Do kiedy rana na tej kończynie jest zaklejona superklejem: nie krwawi, nie otwiera się, bardzo boli
	var/aq_glued_wound_until = 0

/datum/reagent/superglue
	name = "Superklej"
	description = "Przemysłowy klej cyjanoakrylowy, który klei wszystko. Przedmiot polany w dłoni przykleja się do niej, a na podłodze do podłogi. Zakleja krwawiącą ranę, ale okropnie przy tym boli i zamyka w niej brud. Rozpuszcza go aceton."
	reagent_state = LIQUID
	color = "#E8E8D8"
	taste_description = "plastik"
	chem_flags = CHEMICAL_RNG_GENERAL

/datum/reagent/superglue/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(reac_volume >= 1 && isitem(O))
		aq_superglue_item(O)

/// Przykleja przedmiot do dłoni, która go trzyma, albo do podłogi. Zwraca TRUE, jeśli się przykleił.
/proc/aq_superglue_item(obj/item/I)
	if(I.item_flags & ABSTRACT)
		return FALSE
	var/mob/living/holder_mob = I.loc
	if(istype(holder_mob) && holder_mob.is_holding(I))
		ADD_TRAIT(I, TRAIT_NODROP, SUPERGLUE_TRAIT)
		to_chat(holder_mob, "<span class='userdanger'>[I] przykleja ci się do dłoni!</span>")
	else if(isturf(I.loc))
		if(I.anchored && !I.aq_glued_down)
			return FALSE
		I.anchored = TRUE
		I.aq_glued_down = TRUE
		I.visible_message("<span class='warning'>[I] przykleja się do podłogi.</span>")
	else
		return FALSE
	I.aq_superglue_until = world.time + AQ_SUPERGLUE_TIME
	addtimer(CALLBACK(I, TYPE_PROC_REF(/obj/item, aq_superglue_expire)), AQ_SUPERGLUE_TIME)
	return TRUE

/// Timer kleju: odkleja, jeśli w międzyczasie nikt nie polał przedmiotu ponownie
/obj/item/proc/aq_superglue_expire()
	aq_superglue_release(src)

/// Krwawiąca rana polana superklejem: koniec krwawienia z tej kończyny, za to ogromny ból i zarazki
/datum/reagent/superglue/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(method != TOUCH || reac_volume < 1 || !ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/bodypart/limb = affecting
	if(!istype(limb) || limb.owner != H || !H.is_bleeding(limb.body_zone))
		limb = null
		var/list/bleeds = H.aq_get_limb_bleeds()
		var/worst = 0
		for(var/zone in bleeds)
			var/obj/item/bodypart/candidate = H.get_bodypart(zone)
			if(candidate && IS_ORGANIC_LIMB(candidate) && bleeds[zone] > worst)
				worst = bleeds[zone]
				limb = candidate
	if(!limb || !IS_ORGANIC_LIMB(limb))
		return
	H.aq_superglue_wound(limb)

/// Zakleja ranę na kończynie: zatrzymuje krwawienie z niej, daje ból i zarazki
/mob/living/carbon/human/proc/aq_superglue_wound(obj/item/bodypart/limb)
	cauterise_wounds(INFINITY, limb.body_zone)
	limb.aq_glued_wound_until = world.time + AQ_SUPERGLUE_TIME
	limb.aq_add_germs(AQ_SUPERGLUE_GERMS + (prob(AQ_SUPERGLUE_GERMS_EXTRA_CHANCE) ? AQ_SUPERGLUE_GERMS : 0))
	visible_message("<span class='warning'>Klej zasycha na ranie ([limb.name]) [src].</span>", "<span class='userdanger'>Klej wżera się w ranę ([limb.name])! Piecze jak ogień, ale krew przestaje lecieć.</span>")
	if(!HAS_TRAIT(src, TRAIT_ANALGESIA))
		emote("scream")

/// Zaklejona kończyna boli (pain/pain.dm)
/mob/living/carbon/human/aq_limb_pain(obj/item/bodypart/limb)
	. = ..()
	if(limb.aq_glued_wound_until > world.time && aq_limb_feels_pain(limb))
		. += AQ_SUPERGLUE_PAIN

/// Zaklejona rana cięta nie otwiera się na nowo
/datum/wound/slash/wound_effects(delta_time)
	if(limb?.aq_glued_wound_until > world.time)
		reopen_progress = 0
		return
	return ..()

/// Odkleja przedmiot, gdy minął czas kleju albo od razu (force, np. aceton)
/proc/aq_superglue_release(obj/item/I, force = FALSE)
	if(QDELETED(I) || !I.aq_superglue_until)
		return FALSE
	if(!force && world.time < I.aq_superglue_until)
		return FALSE
	I.aq_superglue_until = 0
	REMOVE_TRAIT(I, TRAIT_NODROP, SUPERGLUE_TRAIT)
	if(I.aq_glued_down)
		I.aq_glued_down = FALSE
		I.anchored = FALSE
	return TRUE

/// Aceton rozpuszcza superklej
/datum/reagent/acetone/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(reac_volume >= 1 && isitem(O) && aq_superglue_release(O, TRUE))
		O.visible_message("<span class='notice'>Klej na [O] rozpuszcza się.</span>")

/datum/reagent/acetone/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if((method == TOUCH || method == VAPOR) && reac_volume >= 1 && istype(M))
		for(var/obj/item/held in M.held_items)
			if(aq_superglue_release(held, TRUE))
				to_chat(M, "<span class='notice'>Klej puszcza i [held] odkleja się od dłoni.</span>")

/datum/chemical_reaction/superglue
	name = "Superklej"
	id = /datum/reagent/superglue
	results = list(/datum/reagent/superglue = 3)
	required_reagents = list(/datum/reagent/acetone = 1, /datum/reagent/phenol = 1, /datum/reagent/carbon = 1)
	mix_message = "Roztwór gęstnieje w lepką, przezroczystą maź."

// --- Krzemian ---

/datum/reagent/silicate
	name = "Krzemian"
	description = "Związek wzmacniający szkło. Polane nim okno staje się wytrzymalsze, najwyżej dwa razy."
	reagent_state = LIQUID
	color = "#A5F2F3"
	taste_description = "szkło"
	chem_flags = CHEMICAL_RNG_GENERAL

/datum/reagent/silicate/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(reac_volume >= 1 && istype(O, /obj/structure/window))
		O.aq_silicate_reinforce(reac_volume)

/// Wzmacnia okno o tyle jednostek krzemianu, do limitu. Zwraca, o ile wzrosła wytrzymałość.
/obj/proc/aq_silicate_reinforce(reac_volume)
	var/limit = initial(max_integrity) * AQ_SILICATE_MAX_MULT
	if(max_integrity >= limit)
		return 0
	var/added = min(reac_volume * AQ_SILICATE_PER_UNIT, limit - max_integrity)
	max_integrity += added
	obj_integrity = min(obj_integrity + added, max_integrity)
	add_atom_colour(rgb(165, 242, 243), FIXED_COLOUR_PRIORITY)
	visible_message("<span class='notice'>Krzemian wsiąka w [src] i szkło lekko błękitnieje.</span>")
	return added

/datum/chemical_reaction/silicate
	name = "Krzemian"
	id = /datum/reagent/silicate
	results = list(/datum/reagent/silicate = 3)
	required_reagents = list(/datum/reagent/aluminium = 1, /datum/reagent/silicon = 1, /datum/reagent/oxygen = 1)
	mix_message = "Mieszanina zmienia się w przezroczysty, gęsty płyn."

// --- Beton ---

/turf/open/floor/aq_concrete
	name = "betonowa podłoga"
	desc = "Gładka wylewka z betonu. Łomem jej nie podważysz."
	icon_state = "plating"
	base_icon_state = "plating"
	color = "#B4B0A6"
	floor_tile = null
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW

/turf/open/floor/aq_concrete/crowbar_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='warning'>Beton nie daje się podważyć łomem.</span>")
	return TRUE

/turf/closed/wall/aq_concrete
	name = "betonowa ściana"
	desc = "Ściana z betonu wylanego na dźwigar. Twardsza od zwykłej."
	color = "#A8A49A"
	hardness = 25
	explosion_block = 2
	slicing_duration = 150
	sheet_amount = 1

/datum/reagent/concrete
	name = "Beton"
	description = "Mieszanka cementu i kruszywa. Wylany na podłogę z płyt robi z niej betonową wylewkę, a na dźwigar albo kratę zastyga w betonową ścianę."
	reagent_state = LIQUID
	color = "#8C8C84"
	taste_description = "żwir"
	chem_flags = CHEMICAL_RNG_GENERAL

/datum/reagent/concrete/reaction_turf(turf/T, reac_volume)
	. = ..()
	if(reac_volume >= AQ_CONCRETE_FLOOR_VOLUME && istype(T, /turf/open/floor/plasteel))
		T.ChangeTurf(/turf/open/floor/aq_concrete, flags = CHANGETURF_INHERIT_AIR)

/datum/reagent/concrete/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(reac_volume < AQ_CONCRETE_WALL_VOLUME || !isturf(O.loc) || HAS_TRAIT(O, TRAIT_AQ_CONCRETE_CURING))
		return
	if(!istype(O, /obj/structure/girder) && !istype(O, /obj/structure/grille))
		return
	ADD_TRAIT(O, TRAIT_AQ_CONCRETE_CURING, TRAIT_GENERIC)
	O.add_atom_colour("#8C8C84", FIXED_COLOUR_PRIORITY)
	O.visible_message("<span class='notice'>Beton oblepia [O] i zaczyna zastygać.</span>")
	addtimer(CALLBACK(O, TYPE_PROC_REF(/obj, aq_concrete_cure)), AQ_CONCRETE_CURE_TIME)

/// Zastygnięty beton na dźwigarze albo kracie staje się ścianą
/obj/proc/aq_concrete_cure()
	if(QDELETED(src) || !HAS_TRAIT(src, TRAIT_AQ_CONCRETE_CURING))
		return FALSE
	var/turf/T = loc
	if(!isopenturf(T))
		return FALSE
	qdel(src)
	T.PlaceOnTop(/turf/closed/wall/aq_concrete)
	return TRUE

/datum/chemical_reaction/concrete
	name = "Beton"
	id = /datum/reagent/concrete
	results = list(/datum/reagent/concrete = 4)
	required_reagents = list(/datum/reagent/silicon = 2, /datum/reagent/ash = 1, /datum/reagent/water = 1)
	mix_message = "Mieszanina gęstnieje w szarą, ciężką breję."

// --- Dekonstruktor materii ---

/datum/reagent/matter_deconstructor
	name = "Dekonstruktor materii"
	description = "Związek na bazie celulozy, który rozkłada przedmioty na materiały, z których je zrobiono. Odzyskuje około trzech czwartych."
	reagent_state = LIQUID
	color = "#C8B48C"
	taste_description = "trociny"
	chem_flags = CHEMICAL_RNG_GENERAL

/datum/reagent/matter_deconstructor/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(reac_volume >= 1 && isitem(O))
		aq_deconstruct_matter(O)

/// Rozkłada przedmiot na arkusze materiałów (AQ_DECONSTRUCTOR_RETURN). Zwraca liczbę arkuszy albo FALSE, gdy się nie da.
/proc/aq_deconstruct_matter(obj/item/I)
	if(QDELETED(I) || !length(I.custom_materials) || (I.item_flags & ABSTRACT) || (I.resistance_flags & INDESTRUCTIBLE))
		return FALSE
	if(istype(I, /obj/item/stack/sheet))
		return FALSE
	var/turf/T = get_turf(I)
	if(!T)
		return FALSE
	// Najpierw uzysk: przedmiot, z którego nie powstałby ani jeden arkusz (np. pojedynczy pręt), zostaje cały
	var/list/yield = list()
	var/total = 0
	for(var/key in I.custom_materials)
		var/datum/material/mat = istype(key, /datum/material) ? key : SSmaterials.GetMaterialRef(key)
		if(!mat?.sheet_type)
			continue
		var/sheets = round(I.custom_materials[key] * AQ_DECONSTRUCTOR_RETURN / MINERAL_MATERIAL_AMOUNT)
		if(sheets < 1)
			continue
		yield[mat.sheet_type] += sheets
		total += sheets
	if(!total)
		return FALSE
	SEND_SIGNAL(I, COMSIG_TRY_STORAGE_QUICK_EMPTY, T)
	for(var/obj/item/stack/stack_type as anything in yield)
		var/sheets = yield[stack_type]
		var/max_stack = initial(stack_type.max_amount)
		while(sheets > 0)
			var/amount = min(sheets, max_stack)
			new stack_type(T, amount)
			sheets -= amount
	I.visible_message("<span class='warning'>[I] rozpada się na materiały.</span>")
	qdel(I)
	return total

/datum/chemical_reaction/matter_deconstructor
	name = "Dekonstruktor materii"
	id = /datum/reagent/matter_deconstructor
	results = list(/datum/reagent/matter_deconstructor = 3)
	required_reagents = list(/datum/reagent/cellulose = 3, /datum/reagent/toxin/acid = 1, /datum/reagent/bluespace = 1)
	mix_message = "Mieszanina syczy i drobnieje w płowy, ziarnisty płyn."

// --- Trawo-gro ---

/datum/reagent/grassgro
	name = "Trawo-gro"
	description = "Skoncentrowana płynna trawa. Polana podłoga zarasta trawą."
	reagent_state = LIQUID
	color = "#00FF00"
	taste_description = "skoszony trawnik"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY

/datum/reagent/grassgro/reaction_turf(turf/T, reac_volume)
	. = ..()
	if(reac_volume < 5 || !istype(T, /turf/open/floor) || istype(T, /turf/open/floor/grass) || istype(T, /turf/open/floor/engine))
		return
	T.ChangeTurf(/turf/open/floor/grass, flags = CHANGETURF_INHERIT_AIR)

/datum/chemical_reaction/grassgro
	name = "Trawo-gro"
	id = /datum/reagent/grassgro
	results = list(/datum/reagent/grassgro = 3)
	required_reagents = list(/datum/reagent/plantnutriment/eznutriment = 1, /datum/reagent/plantnutriment/robustharvestnutriment = 1, /datum/reagent/water = 1)
	mix_message = "Roztwór zielenieje i pachnie świeżo skoszoną trawą."

// --- Serum genezy ---

/datum/reagent/genesis
	name = "Serum genezy"
	description = "Tajemnicza substancja, z której na gołej ziemi, piasku albo trawie same wyrastają rośliny."
	reagent_state = LIQUID
	color = "#328242"
	taste_description = "pierwotna esencja"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY

/datum/reagent/genesis/reaction_turf(turf/T, reac_volume)
	. = ..()
	if(reac_volume >= 5)
		aq_genesis_grow(T)

/// Na gołym podłożu wyrasta losowa roślina. Zwraca ją albo null.
/proc/aq_genesis_grow(turf/T)
	if(!istype(T, /turf/open/floor/grass) && !istype(T, /turf/open/floor/plating/dirt) && !istype(T, /turf/open/floor/plating/asteroid))
		return null
	if(locate(/obj/structure/flora) in T)
		return null
	for(var/atom/movable/AM in T)
		if(AM.density)
			return null
	var/static/list/weeds = list(
		/obj/structure/flora/ausbushes/sparsegrass, /obj/structure/flora/ausbushes/fullgrass,
		/obj/structure/flora/ausbushes/lavendergrass, /obj/structure/flora/ausbushes/ywflowers,
		/obj/structure/flora/ausbushes/brflowers, /obj/structure/flora/ausbushes/ppflowers,
		/obj/structure/flora/ausbushes/reedbush, /obj/structure/flora/ausbushes/leafybush,
		/obj/structure/flora/ausbushes/grassybush, /obj/structure/flora/ausbushes/fernybush,
		/obj/structure/flora/ausbushes/genericbush, /obj/structure/flora/ausbushes,
	)
	var/plant_type = pick(weeds)
	var/obj/structure/flora/plant = new plant_type(T)
	T.visible_message("<span class='notice'>Z ziemi wyrasta [plant].</span>")
	return plant

/datum/chemical_reaction/genesis
	name = "Serum genezy"
	id = /datum/reagent/genesis
	results = list(/datum/reagent/genesis = 10)
	required_reagents = list(/datum/reagent/diethylamine = 10, /datum/reagent/medicine/strange_reagent = 1, /datum/reagent/stable_plasma = 1)
	mix_message = "Dietyloamina iskrzy i nabiera intensywnie zielonej barwy."

// --- Azotan srebra ---

/datum/component/forensics
	/// Do kiedy azotan srebra odsłania odciski palców
	var/aq_silver_until = 0

/datum/reagent/silver_nitrate
	name = "Azotan srebra"
	description = "Sól srebra używana w kryminalistyce. Ciemnieje na liniach papilarnych i odsłania odciski palców na przedmiotach i podłodze, tak że widać je gołym okiem."
	reagent_state = LIQUID
	color = "#D0D0D8"
	taste_description = "gorzki metal"
	chem_flags = CHEMICAL_RNG_GENERAL

/datum/reagent/silver_nitrate/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(reac_volume >= 1 && O.aq_silver_nitrate_act())
		O.visible_message("<span class='notice'>Na [O] ciemnieją linie odcisków palców.</span>")

/datum/reagent/silver_nitrate/reaction_turf(turf/T, reac_volume)
	. = ..()
	if(reac_volume < 1)
		return
	T.aq_silver_nitrate_act()
	for(var/obj/item/I in T)
		I.aq_silver_nitrate_act()

/// Azotan srebra: odsłania odciski palców na AQ_SILVER_NITRATE_TIME. Zwraca TRUE, jeśli jakieś były.
/atom/proc/aq_silver_nitrate_act()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(!D || !length(D.fingerprints))
		return FALSE
	D.aq_silver_until = world.time + AQ_SILVER_NITRATE_TIME
	return TRUE

/// Odciski odsłonięte azotanem srebra, null gdy nie działa
/atom/proc/aq_revealed_fingerprints()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D && D.aq_silver_until > world.time && length(D.fingerprints))
		return D.fingerprints

/atom/examine(mob/user)
	. = ..()
	var/list/prints = aq_revealed_fingerprints()
	if(length(prints))
		var/list/shown = list()
		for(var/print in prints)
			shown += "<font color='#555555'>[print]</font>"
		. += "<span class='notice'>Azotan srebra odsłania odciski palców: [jointext(shown, ", ")].</span>"

/datum/chemical_reaction/silver_nitrate
	name = "Azotan srebra"
	id = /datum/reagent/silver_nitrate
	results = list(/datum/reagent/silver_nitrate = 2)
	required_reagents = list(/datum/reagent/silver = 1, /datum/reagent/nitrogen = 1, /datum/reagent/oxygen = 1)
	mix_message = "Srebro rozpuszcza się w bezbarwnym roztworze."

// --- Odciskowe nanoboty ---

/mob/living/carbon/human
	/// Odcisk palca podmieniony nanobotami, null = prawdziwy z DNA
	var/aq_fake_fingerprint

/// Odcisk palca, który ten człowiek zostawia i który widzi skaner
/mob/living/carbon/human/proc/aq_fingerprint()
	if(aq_fake_fingerprint)
		return aq_fake_fingerprint
	return rustg_hash_string(RUSTG_HASH_MD5, dna.uni_identity)

/// Podmieniony odcisk zamiast prawdziwego (wzór: niewidzialne odciski w datums/mutations/monke/_compat.dm)
/datum/component/forensics/add_fingerprint(mob/living/M, ignoregloves = FALSE)
	var/mob/living/carbon/human/H = M
	if(!istype(H) || !H.aq_fake_fingerprint || !H.dna)
		return ..()
	var/real_print = rustg_hash_string(RUSTG_HASH_MD5, H.dna.uni_identity)
	// Stary prawdziwy odcisk z dotyku sprzed nanobotów zostaje, ale bazowy zapis tego dotyku idzie pod nowy odcisk,
	// także gdy stary już tu jest (rękawice sprawdza ..(): bez zapisu prawdziwego nie ma też podmienionego)
	var/had_print = LAZYACCESS(fingerprints, real_print)
	if(had_print)
		LAZYREMOVE(fingerprints, real_print)
	. = ..()
	if(LAZYACCESS(fingerprints, real_print))
		LAZYREMOVE(fingerprints, real_print)
		LAZYSET(fingerprints, H.aq_fake_fingerprint, H.aq_fake_fingerprint)
	if(had_print)
		LAZYSET(fingerprints, real_print, real_print)

/datum/reagent/fingerprint_nanites
	name = "Odciskowe nanoboty"
	description = "Nanoboty, które przebudowują skórę opuszków palców. Wypite zmieniają odciski palców na losowe, a jeśli w mieszance jest czyjaś krew, na odciski tej osoby."
	reagent_state = LIQUID
	color = "#535E66"
	taste_description = "mrowienie"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	chem_flags = CHEMICAL_RNG_GENERAL
	/// Odcisk dawcy krwi z mieszanki w "donor_print": ustalany w pojemniku, gdy krew i nanoboty się spotkają,
	/// i przenoszony z porcją (copy_data), zanim krew zmiesza się z inną w żołądku albo wsiąknie w ciało
	data = list("donor_print" = null)
	/// Czy już przebudowały odciski tego ciała
	var/applied = FALSE

/datum/reagent/fingerprint_nanites/on_new(list/new_data)
	. = ..()
	if(!aq_donor_print())
		aq_learn_donor()

/// Najnowsza porcja wygrywa: dolane nanoboty z innym dawcą przepisują odcisk
/datum/reagent/fingerprint_nanites/on_merge(list/mix_data, amount)
	. = ..()
	if(islist(mix_data) && mix_data["donor_print"])
		aq_set_donor_print(mix_data["donor_print"])
	else if(!aq_donor_print())
		aq_learn_donor()

/datum/reagent/fingerprint_nanites/on_mob_add(mob/living/L)
	. = ..()
	if(!aq_donor_print())
		aq_learn_donor()

/datum/reagent/fingerprint_nanites/on_mob_life(mob/living/carbon/M)
	if(!applied && ishuman(M))
		if(!aq_donor_print())
			aq_learn_donor()
		if(current_cycle >= 3)
			applied = TRUE
			var/mob/living/carbon/human/H = M
			H.aq_rewrite_fingerprints(aq_donor_print())
	..()

/datum/reagent/fingerprint_nanites/proc/aq_donor_print()
	return islist(data) ? data["donor_print"] : null

/datum/reagent/fingerprint_nanites/proc/aq_set_donor_print(print)
	if(!islist(data))
		data = list()
	data["donor_print"] = print

/// Dawca z krwi w tym samym pojemniku
/datum/reagent/fingerprint_nanites/proc/aq_learn_donor()
	var/datum/reagent/blood/B = holder?.has_reagent(/datum/reagent/blood)
	var/print = aq_blood_donor_print(B?.data, holder)
	if(print)
		aq_set_donor_print(print)

/// Krew dolana do nanobotów: jej dawca jest teraz dawcą odcisku
/datum/reagent/blood/on_new(list/new_data)
	. = ..()
	aq_teach_fingerprint_nanites(new_data)

/datum/reagent/blood/on_merge(list/mix_data, amount)
	. = ..()
	aq_teach_fingerprint_nanites(mix_data)

/datum/reagent/blood/proc/aq_teach_fingerprint_nanites(list/blood_data)
	var/datum/reagent/fingerprint_nanites/nanites = holder?.has_reagent(/datum/reagent/fingerprint_nanites)
	if(!nanites)
		return
	var/print = aq_blood_donor_print(blood_data, holder)
	if(print)
		nanites.aq_set_donor_print(print)

/// Odcisk dawcy krwi (szukanego po DNA krwi). Null, gdy danych nie ma albo to krew ciała, w którym jest pojemnik.
/proc/aq_blood_donor_print(list/blood_data, datum/reagents/mix)
	if(!islist(blood_data))
		return null
	var/donor_dna = blood_data["blood_DNA"]
	if(!donor_dna)
		return null
	var/atom/container = mix?.my_atom
	if(istype(container, /obj/item/organ))
		var/obj/item/organ/organ = container
		container = organ.owner
	if(iscarbon(container))
		var/mob/living/carbon/body = container
		if(donor_dna == body.dna?.unique_enzymes)
			return null
	for(var/mob/living/carbon/human/donor in GLOB.carbon_list)
		if(donor.dna?.unique_enzymes == donor_dna)
			return rustg_hash_string(RUSTG_HASH_MD5, donor.dna.uni_identity)

/// Nowe odciski palców: podane albo losowe
/mob/living/carbon/human/proc/aq_rewrite_fingerprints(new_print)
	if(!new_print)
		new_print = rustg_hash_string(RUSTG_HASH_MD5, "[REF(src)][world.time][rand(1, 1000000000)]")
	if(dna && new_print == rustg_hash_string(RUSTG_HASH_MD5, dna.uni_identity))
		new_print = null
	aq_fake_fingerprint = new_print
	to_chat(src, "<span class='warning'>Opuszki palców swędzą, a skóra na nich układa się w nowe linie.</span>")

/datum/chemical_reaction/fingerprint_nanites
	name = "Odciskowe nanoboty"
	id = /datum/reagent/fingerprint_nanites
	results = list(/datum/reagent/fingerprint_nanites = 2)
	required_reagents = list(/datum/reagent/silver_nitrate = 1, /datum/reagent/medicine/synthflesh = 1, /datum/reagent/toxin/mutagen = 1)
	mix_message = "W roztworze roją się drobne, szare punkciki."

// --- Sól święcona ---

/obj/effect/decal/cleanable/food/salt/holy
	name = "kupka soli święconej"
	desc = "Poświęcona sól. Istoty nadprzyrodzone nie przejdą przez jej linię."
	color = "#FFF6D8"

/datum/reagent/holy_salt
	name = "Sól święcona"
	description = "Sól poświęcona wodą święconą. Rozsypana na podłodze tworzy linię, której nie przejdą upiory, projekcje astralne kultystów, demony cieni ani wampiry rozwiane w mgłę."
	reagent_state = SOLID
	color = "#FFF6D8"
	taste_description = "sól i kadzidło"
	chem_flags = CHEMICAL_RNG_GENERAL

/datum/reagent/holy_salt/reaction_turf(turf/T, reac_volume)
	. = ..()
	if(reac_volume >= 1 && isopenturf(T) && !aq_holy_salt_on(T))
		new /obj/effect/decal/cleanable/food/salt/holy(T)

/// Sól święcona na polu, null gdy jej nie ma
/proc/aq_holy_salt_on(turf/T)
	return locate(/obj/effect/decal/cleanable/food/salt/holy) in T

/// Upiór (revenant) zatrzymuje się na każdej soli w Process_Incorpmove (mob_movement.dm), więc też na tej.
/// Projekcja astralna kultu w formie ducha (bloodcult/constructs/astral_shade.dm) przenika ściany, ale nie sól święconą.
/client/Process_Incorpmove(direct)
	if(istype(mob, /mob/living/simple_animal/astral_projection))
		var/turf/next = get_step_multiz(get_turf(mob), direct)
		if(next && aq_holy_salt_on(next))
			to_chat(mob, "<span class='warning'>Sól święcona zagradza ci drogę!</span>")
			return
	return ..()

/// Demon cieni w cieniu (shadow_demon/shadow_demon_powers.dm)
/obj/effect/dummy/phased_mob/shadow_crawl/relaymove(mob/user, direction)
	var/turf/new_loc = get_step(src, direction)
	if(new_loc && aq_holy_salt_on(new_loc))
		to_chat(user, "<span class='warning'>Sól święcona zagradza ci drogę!</span>")
		return
	return ..()

/// Wampir rozwiany w mgłę (Przenikanie, vampire/powers/obfuscate/trespass.dm) nie przeleci nad solą święconą
/datum/action/vampire/targeted/trespass/check_valid_target(atom/target_atom)
	. = ..()
	if(!. || !target_turf)
		return
	if(aq_salt_on_path())
		owner.balloon_alert(owner, "sól święcona zagradza drogę.")
		return FALSE

/// Czy na drodze mgły do target_turf (najwyżej dwa pola, z celem) leży sól święcona. Sprawdzane przy wyborze celu
/// i jeszcze raz tuż przed przeniesieniem (FireTargetedPower w trespass.dm), bo ktoś może ją rozsypać w trakcie.
/datum/action/vampire/targeted/trespass/proc/aq_salt_on_path()
	var/turf/step_turf = get_turf(owner)
	if(!step_turf || !target_turf)
		return FALSE
	for(var/i in 1 to 2)
		if(step_turf == target_turf)
			break
		step_turf = get_step(step_turf, get_dir(step_turf, target_turf))
		if(aq_holy_salt_on(step_turf))
			return TRUE
	return FALSE

/datum/chemical_reaction/holy_salt
	name = "Sól święcona"
	id = /datum/reagent/holy_salt
	results = list(/datum/reagent/holy_salt = 1)
	required_reagents = list(/datum/reagent/consumable/sodiumchloride = 1)
	required_catalysts = list(/datum/reagent/water/holywater = 5)
	mix_message = "Sól przez chwilę lśni ciepłym światłem."

#undef AQ_SUPERGLUE_TIME
#undef AQ_SUPERGLUE_PAIN
#undef AQ_SUPERGLUE_GERMS
#undef AQ_SUPERGLUE_GERMS_EXTRA_CHANCE
#undef SUPERGLUE_TRAIT
#undef AQ_SILICATE_PER_UNIT
#undef AQ_SILICATE_MAX_MULT
#undef AQ_CONCRETE_FLOOR_VOLUME
#undef AQ_CONCRETE_WALL_VOLUME
#undef AQ_CONCRETE_CURE_TIME
#undef TRAIT_AQ_CONCRETE_CURING
#undef AQ_DECONSTRUCTOR_RETURN
#undef AQ_SILVER_NITRATE_TIME
