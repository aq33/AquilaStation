/datum/test_chamber_kit/pr_500
	name = "Szlify map, przezroczyste okna"
	pr = "aq33/AquilaStation#500"
	description = "Zestaw układa 4 wzmocnione okna z kratą w rząd, zwykłe okno bez kraty na gołej podłodze z kablem, okno plazmowe, zegar cyfrowy oraz stół operacyjny z pacjentem i podłączonym monitorem funkcji życiowych. \
	1) Obejrzyj rząd wzmocnionych okien → oczekiwane: szyba jest półprzezroczysta (jak w Paradise), pod nią widać kratę i podłogę, bez ciemnego prostokątnego tła. \
	2) Zwykłe okno bez kraty: pod szybą ma być widoczna naga płyta podłogi i żółty kabel (negatyw: żadnego czarnego wypełnienia pod szkłem, także w oknie plazmowym). \
	3) Rozbij jedno okno z rzędu (dowolnym narzędziem lub przedmiotem) → oczekiwane: sąsiednie okna przeliczają łączenia ramy (krawędzie przy wyłomie), krata pod rozbitym oknem zostaje. Naprawa nie jest wymagana. \
	4) Zegar cyfrowy → oczekiwane: pokazuje czas pokładowy (HH:MM), zgodny ze Statusem rundy, i zmienia się z upływem czasu; examine ma opis zegara. \
	5) Zaawansowany monitor stoi obok stołu operacyjnego → oczekiwane: w examine monitora jest odczyt funkcji życiowych pacjenta leżącego na stole (tętno, obrażenia, chemia); zdejmij pacjenta ze stołu → „Nikt w niej nie leży”. Negatyw: odsuń monitor więcej niż 3 pola od stołu i użyj multitoola → „brak maszyn w pobliżu!”. \
	6) Poza komorą (opcjonalnie, na mapie): obejrzyj zegary na Atlasie i Trawniku, monitor w chirurgii Atlasa (z2 150,104) i traumie Trawnika (z2 112,158), rowery w więzieniach, exodrony u kwatermistrza Trawnika i kuźnię Trawnika; w komorze tego nie da się sprawdzić."
	items = list(
		/obj/structure/window/reinforced/fulltile = 4,
		/obj/structure/window/fulltile = 1,
		/obj/structure/window/plasma/reinforced/fulltile = 1,
		/obj/structure/cable/yellow = 1,
		/obj/machinery/digital_clock = 1,
		/obj/structure/table/optable = 1,
		/obj/machinery/vitals_reader/advanced = 1,
		/obj/item/weldingtool/experimental = 1,
		/mob/living/carbon/human = 1,
	)

/// Cztery wzmocnione okna z kratą w jednym rzędzie, żeby było widać łączenie i szybę na dłuższym odcinku.
/// Spawner okna usuwa się po zrzuceniu (test komory by go nie policzył), więc krata i szyba idą osobno.
/datum/test_chamber_kit/pr_500/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	pr_500_bare_window(spawned)
	pr_500_patient(spawned)
	var/list/windows = list()
	for(var/obj/structure/window/reinforced/fulltile/W in spawned)
		windows += W
	if(!length(windows))
		return
	// Pierwsze cztery sąsiadujące wolne pola areny w poziomie (pole z oknami zestawu też się liczy)
	var/list/row
	for(var/turf/start as anything in turfs)
		var/list/candidate = list()
		for(var/i in 0 to length(windows) - 1)
			var/turf/T = locate(start.x + i, start.y, start.z)
			if(!(T in turfs) || !pr_500_free_turf(T, windows))
				break
			candidate += T
		if(length(candidate) == length(windows))
			row = candidate
			break
	if(!row)
		if(user)
			to_chat(user, span_warning("Na arenie nie ma czterech wolnych pól obok siebie, okna zostały na jednym polu. Zresetuj komorę i zrzuć zestaw jeszcze raz."))
		return
	for(var/i in 1 to length(windows))
		var/turf/T = row[i]
		var/obj/structure/window/W = windows[i]
		W.forceMove(T)
		if(!(locate(/obj/structure/grille) in T))
			new /obj/structure/grille(T)
	for(var/obj/structure/window/W as anything in windows)
		queue_smooth(W)
		queue_smooth_neighbors(W)

/// Zwykłe okno bez kraty stoi na gołej płycie z kablem, żeby było widać, co jest pod szybą
/datum/test_chamber_kit/pr_500/proc/pr_500_bare_window(list/spawned)
	var/obj/structure/window/bare_window
	for(var/obj/structure/window/W in spawned)
		if(W.type == /obj/structure/window/fulltile)
			bare_window = W
			break
	var/obj/structure/cable/cable = locate() in spawned
	if(!bare_window || !cable)
		return
	var/turf/T = get_turf(bare_window)
	T.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	cable.forceMove(T)

/// Pacjent na stole operacyjnym i monitor tuż obok, połączony ze stołem
/datum/test_chamber_kit/pr_500/proc/pr_500_patient(list/spawned)
	var/obj/structure/table/optable/table = locate() in spawned
	var/obj/machinery/vitals_reader/monitor = locate() in spawned
	var/mob/living/carbon/human/patient = locate() in spawned
	if(!table || !monitor || !patient)
		return
	var/turf/table_turf = get_turf(table)
	for(var/direction in GLOB.cardinals)
		var/turf/neighbour = get_step(table_turf, direction)
		if(isopenturf(neighbour))
			monitor.forceMove(neighbour)
			break
	patient.forceMove(table_turf)
	patient.set_resting(TRUE, TRUE)
	patient.name = "pacjent na stole"
	patient.real_name = patient.name
	table.get_patient()
	monitor.find_machine()

/// Pole bez gęstych rzeczy i bez struktur poza oknami zestawu
/datum/test_chamber_kit/pr_500/proc/pr_500_free_turf(turf/T, list/windows)
	if(T.density)
		return FALSE
	for(var/atom/movable/AM in T)
		if(AM in windows)
			continue
		if(AM.density || istype(AM, /obj/structure))
			return FALSE
	return TRUE
