/datum/test_chamber_kit/pr_447
	name = "MULEboty i poczta rurowa"
	pr = "aq33/AquilaStation#447"
	description = "PR zmienia mapy (Atlas, Serendipity, Snake), więc komora daje tylko model poczty: zsyp z rurą sortującą po tagu „Kaplica” i dwoma wylotami (rury leżą pod podłogą, widać zsyp i wyloty). Mapowe zsypy i windy MULE sprawdź na prawdziwej mapie. \
		1) Zapakuj pluszaka w papier paczkowy i ustaw na znakowniku cel „Kaplica”, oznacz paczkę, wrzuć do zsypu i pociągnij za dźwignię w jego panelu → oczekiwane: paczka wylatuje z wylotu południowego (od sortera). \
		2) Wrzuć do zsypu nieopakowanego pluszaka i spłucz → oczekiwane: leci prosto do wylotu na końcu, nie skręca do sortera (jak śmieci do utylizacji). \
		3) Zapakuj paczkę bez tagu albo z innym celem niż „Kaplica” → oczekiwane: wylot na końcu, nigdy południowy. \
		4) Dotknij sortera znakownikiem ustawionym na inny cel → oczekiwane: sorter dopisuje albo usuwa ten tag (examine pokazuje listę), paczki z nowym tagiem skręcają. \
		5) MULEbot z zestawu (komora jest poza statkiem, więc jazda i windy tu nie zadziałają): otwórz jego panel i wybierz cel → oczekiwane: brak runtime'u (poprawka get_nav poza statkiem), bot nie zawiesza się; jeśli lista celów jest pusta, to dlatego, że w komorze nie ma radiolatarni."
	items = list(
		/obj/item/dest_tagger = 1,
		/obj/item/stack/package_wrap = 1,
		/obj/item/stack/wrapping_paper = 1,
		/obj/item/toy/plush/carpplushie = 3,
		/mob/living/simple_animal/bot/mulebot = 1
	)

/datum/test_chamber_kit/pr_447/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Szukamy wolnego rzędu 5 pól na linię zsypu i pola pod sorterem na drugi wylot
	var/turf/start
	for(var/turf/open/candidate in turfs)
		if(is_mail_line_free(candidate))
			start = candidate
			break
	if(!start)
		to_chat(user, "<span class='warning'>Na arenie nie ma miejsca na linię pocztową, zresetuj komorę i zrzuć zestaw jeszcze raz.</span>")
		return
	var/turf/bin_turf = start
	var/turf/pipe_turf = locate(start.x + 1, start.y, start.z)
	var/turf/sorter_turf = locate(start.x + 2, start.y, start.z)
	var/turf/pipe2_turf = locate(start.x + 3, start.y, start.z)
	var/turf/outlet_turf = locate(start.x + 4, start.y, start.z)
	var/turf/side_outlet_turf = locate(start.x + 2, start.y - 1, start.z)
	// Najpierw przyłącze, potem zsyp i wyloty, bo szukają swojego przyłącza przy tworzeniu.
	// Rury liczą kierunki w Initialize, więc po ustawieniu dir podajemy dpdir ręcznie.
	add_mail_trunk(bin_turf, EAST)
	new /obj/machinery/disposal/bin(bin_turf)
	var/obj/structure/disposalpipe/segment/first = new(pipe_turf)
	first.setDir(EAST)
	first.dpdir = EAST | WEST
	var/obj/structure/disposalpipe/sorting/mail/sorter = new(sorter_turf)
	sorter.setDir(EAST)
	sorter.dpdir = EAST | WEST | SOUTH
	sorter.sortTypes |= 17 // Kaplica
	var/obj/structure/disposalpipe/segment/second = new(pipe2_turf)
	second.setDir(EAST)
	second.dpdir = EAST | WEST
	add_mail_trunk(outlet_turf, WEST)
	add_mail_outlet(outlet_turf, EAST)
	add_mail_trunk(side_outlet_turf, NORTH)
	add_mail_outlet(side_outlet_turf, SOUTH)

/datum/test_chamber_kit/pr_447/proc/add_mail_trunk(turf/T, direction)
	var/obj/structure/disposalpipe/trunk/trunk = new(T)
	trunk.setDir(direction)
	trunk.dpdir = direction

/datum/test_chamber_kit/pr_447/proc/add_mail_outlet(turf/T, direction)
	var/obj/structure/disposaloutlet/outlet = new(T)
	outlet.setDir(direction)
	outlet.target = get_ranged_target_turf(outlet, direction, 10)

/// Czy od tego pola da się ułożyć linię pocztową (5 pól w prawo i pole pod trzecim)
/datum/test_chamber_kit/pr_447/proc/is_mail_line_free(turf/start)
	var/list/needed = list()
	for(var/offset in 0 to 4)
		needed += locate(start.x + offset, start.y, start.z)
	needed += locate(start.x + 2, start.y - 1, start.z)
	for(var/turf/T in needed)
		if(!istype(T, /turf/open) || !istype(T.loc, /area/test_chamber/arena) || is_blocked_turf(T, TRUE))
			return FALSE
	return length(needed) == 6
