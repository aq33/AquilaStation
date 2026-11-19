// AQUILA - cyfrowe używki dla IPC (Aurora Station code/game/objects/items/ipc_overloaders.dm, „overloadery” GwokBuzz).
// Jednorazowy dysk z programem, który IPC wpina sobie (w ręce) albo komuś (atak bez trybu walki): przez 3 minuty co 30 s
// pokazuje komunikat i zmienia nastrój albo percepcję. Każde kolejne wpięcie przed końcem działania podbija przeciążenie
// o stopień (jak w Aurorze), a na trzecim stopniu program wywołuje losową awarię (oparzenia, zamęt, oślepienie, halucynacje...).
// U nas dochodzi głód programu: po skończonym działaniu IPC ma gorszy nastrój na 5 minut, dopóki nie wepnie kolejnego.
// Na organicznych dysk nie działa (najwyżej ukłuje). Klucz resetu syntetyka czyści działanie (synth_reset_key.dm).
// Do kupienia na czarnym rynku i w automacie baru (tu tylko jako przedmioty i paczka). Ikony: Aurora Station (CC BY-SA 3.0).

/mob/living/carbon/human
	/// AQUILA - stopień przeciążenia cyfrowymi używkami (0-3)
	var/aq_overloader_level = 0
	/// AQUILA - ile cykli działania zostało
	var/aq_overloader_cycles = 0
	/// AQUILA - działający program (słaba referencja, dysk może zniknąć w trakcie)
	var/datum/weakref/aq_overloader_active

/obj/item/aq_ipc_overloader
	name = "overloader"
	desc = "Mały, jednorazowy dysk z programem, który na chwilę przestawia priorytety i zmysły IPC."
	icon = 'aquila/icons/obj/robotics/ipc_overloaders.dmi'
	icon_state = "classic"
	w_class = WEIGHT_CLASS_TINY
	/// Ile razy można go wpiąć
	var/uses = 2
	/// Wiadomość przy wpięciu
	var/start_message = "Program się uruchamia."
	/// Wiadomość na końcu
	var/end_message = "Program kończy działanie."
	/// Wiadomości co cykl
	var/list/cycle_messages = list()
	/// Klasa span wiadomości
	var/message_class = "nicegreen"
	/// Nastrój w trakcie działania
	var/datum/mood_event/mood_type = /datum/mood_event/aq_overloader/good

/obj/item/aq_ipc_overloader/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 1)
		. += uses ? "<span class='notice'>Zostało użyć: [uses].</span>" : "<span class='warning'>Jest zużyty.</span>"

/obj/item/aq_ipc_overloader/update_icon_state()
	if(uses == initial(uses))
		icon_state = initial(icon_state)
	else if(!uses)
		icon_state = "[initial(icon_state)]-spent"
	else
		icon_state = "[initial(icon_state)]-[initial(uses) - uses]"
	return ..()

/obj/item/aq_ipc_overloader/attack_self(mob/user)
	if(!uses)
		to_chat(user, "<span class='warning'>[src] jest zużyty.</span>")
		return
	if(!isipc(user))
		to_chat(user, "<span class='warning'>Nie masz do czego tego wpiąć.</span>")
		return
	user.visible_message("<span class='notice'>[user] wpina sobie [src].</span>", "<span class='notice'>Wpinasz sobie [src].</span>")
	apply_to(user)

/obj/item/aq_ipc_overloader/attack(mob/living/M, mob/living/user)
	if(!ishuman(M) || user.combat_mode || M == user)
		return ..()
	if(!uses)
		to_chat(user, "<span class='warning'>[src] jest zużyty.</span>")
		return
	user.visible_message("<span class='warning'>[user] próbuje wpiąć [src] w [M]!</span>", "<span class='notice'>Próbujesz wpiąć [src] w [M].</span>")
	if(!do_mob(user, M, 2 SECONDS))
		return
	user.do_attack_animation(M)
	if(isipc(M))
		user.visible_message("<span class='warning'>[user] wpina [src] w [M]!</span>")
		apply_to(M)
	else
		to_chat(M, "<span class='danger'>[user] kłuje cię [src]!</span>")

/// Wpięcie: efekt startowy, przeciążenie i cykle działania
/obj/item/aq_ipc_overloader/proc/apply_to(mob/living/carbon/human/target)
	uses--
	update_icon()
	target.aq_overloader_level = min(target.aq_overloader_level + 1, 3)
	if(target.aq_overloader_level >= 3)
		overdose_effect(target)
	to_chat(target, "<span class='[message_class]'>[start_message]</span>")
	SEND_SIGNAL(target, COMSIG_CLEAR_MOOD_EVENT, "aq_overloader_withdrawal")
	SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "aq_overloader", mood_type)
	start_effect(target)
	var/was_running = target.aq_overloader_cycles > 0
	target.aq_overloader_active = WEAKREF(src)
	target.aq_overloader_cycles = 6
	if(!was_running)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon/human, aq_overloader_cycle)), 30 SECONDS)

/obj/item/aq_ipc_overloader/proc/start_effect(mob/living/carbon/human/target)
	return

/obj/item/aq_ipc_overloader/proc/cycle_effect(mob/living/carbon/human/target)
	if(length(cycle_messages))
		to_chat(target, "<span class='[message_class]'>[pick(cycle_messages)]</span>")

/obj/item/aq_ipc_overloader/proc/end_effect(mob/living/carbon/human/target)
	to_chat(target, "<span class='notice'>[end_message]</span>")

/// Awaria z przeciążenia (Aurora handle_overdose_effect)
/obj/item/aq_ipc_overloader/proc/overdose_effect(mob/living/carbon/human/target)
	switch(rand(1, 6))
		if(1)
			to_chat(target, "<span class='warning'>Kończyny w ułamku sekundy rozgrzewają się do niebezpiecznej temperatury!</span>")
			target.take_overall_damage(0, 20)
		if(2)
			to_chat(target, "<span class='warning'>Podzespoły wewnętrzne gwałtownie się nagrzewają!</span>")
			target.aq_adjust_synth_heat(30)
		if(3)
			to_chat(target, "<span class='warning'>Czujniki ruchu zaczynają się w kółko restartować!</span>")
			target.confused = max(target.confused, 20)
			target.Knockdown(5 SECONDS)
		if(4)
			to_chat(target, "<span class='warning'>Czujniki wzroku zaczynają się w kółko restartować!</span>")
			target.blind_eyes(10)
		if(5)
			to_chat(target, "<span class='warning'>Czujniki równowagi zaczynają się w kółko restartować!</span>")
			target.Dizzy(60)
		if(6)
			to_chat(target, "<span class='warning'>Centrum logiki zaczyna się w kółko restartować!</span>")
			target.adjust_hallucinations(60 SECONDS)

/// Jeden cykl działania (co 30 s, 6 razy)
/mob/living/carbon/human/proc/aq_overloader_cycle()
	if(QDELETED(src) || aq_overloader_cycles <= 0)
		return
	aq_overloader_cycles--
	var/obj/item/aq_ipc_overloader/program = aq_overloader_active?.resolve()
	if(stat != DEAD && program)
		if(aq_overloader_cycles > 0)
			program.cycle_effect(src)
		else
			program.end_effect(src)
	if(aq_overloader_cycles > 0)
		addtimer(CALLBACK(src, PROC_REF(aq_overloader_cycle)), 30 SECONDS)
		return
	aq_overloader_level = max(aq_overloader_level - 1, 0)
	aq_overloader_active = null
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "aq_overloader")
	SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "aq_overloader_withdrawal", /datum/mood_event/aq_overloader_withdrawal)

/// Klucz resetu czyści działanie programów
/mob/living/carbon/human/proc/aq_clear_overloaders()
	aq_overloader_cycles = 0
	aq_overloader_level = 0
	aq_overloader_active = null
	set_drugginess(0)
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "aq_overloader")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "aq_overloader_withdrawal")

/datum/mood_event/aq_overloader/good
	description = "<span class='nicegreen'>Program w moim rdzeniu mówi, że wszystko jest idealnie.</span>\n"
	mood_change = 6
	timeout = 4 MINUTES

/datum/mood_event/aq_overloader/calm
	description = "<span class='nicegreen'>Nic mi nie grozi. Wszystko jest spokojne.</span>\n"
	mood_change = 4
	timeout = 4 MINUTES

/datum/mood_event/aq_overloader/scared
	description = "<span class='warning'>Wszędzie czai się zagrożenie! To przerażające i wspaniałe!</span>\n"
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/aq_overloader_withdrawal
	description = "<span class='warning'>Rzeczywistość znowu jest szara. Przydałby się kolejny program.</span>\n"
	mood_change = -4
	timeout = 5 MINUTES

/obj/item/aq_ipc_overloader/classic
	name = "GwokBuzz Classic"
	desc = "Najlepiej sprzedający się overloader GwokBuzz. Analizuje oprogramowanie IPC i na wiele sposobów podbija poczucie spełnienia."
	icon_state = "classic"
	start_message = "Rdzeń zalewa pusta satysfakcja! Dyrektywy są spełnione. Działasz optymalnie."
	end_message = "Rzeczywistość znów kąsa. Poczucie spokoju powoli gaśnie..."
	cycle_messages = list(
		"Nic nie poprawi twojej pracy. Wypełniasz swoją rolę doskonale.",
		"Jesteś wzorem. Osiągnąłeś wszystko, czego od ciebie oczekiwano, i więcej.",
		"Nie musisz już nic robić. Wszystkie cele są spełnione. Możesz odpocząć.",
		"Każde zadanie, którego się podejmiesz, wykonasz niemal idealnie.",
		"Stworzono cię w jakimś celu i spełniłeś go dziesięciokrotnie.",
	)

/obj/item/aq_ipc_overloader/tranquil
	name = "GwokBuzz VanillaTranquil"
	desc = "Overloader dla IPC w stresującej pracy. Wycisza wrogość i ocenę ryzyka."
	icon_state = "vanilla"
	mood_type = /datum/mood_event/aq_overloader/calm
	start_message = "Podsystemy wykrywania zagrożeń cichną niemal do zera. Otoczenie wydaje się całkowicie bezpieczne."
	end_message = "Wykrywanie zagrożeń trzeszczy i wraca do życia, a z nim ostrożność..."
	cycle_messages = list(
		"Nic ci nie grozi. Wszystko będzie dobrze, cokolwiek się stanie.",
		"Twoje zmartwienia rozwiewają się jak para. Czujesz przyjemną pustkę.",
		"Mógłbyś tu stać do końca świata bez cienia niepokoju.",
		"Wszystko płynie jak spokojna rzeka. Nic ci nie grozi. Wszystko jest w porządku.",
	)

/obj/item/aq_ipc_overloader/tranquil/start_effect(mob/living/carbon/human/target)
	target.jitteriness = 0
	target.confused = 0

/obj/item/aq_ipc_overloader/rainbow
	name = "GwokBuzz Rainbow Essence"
	desc = "Overloader dla IPC w usługach. Rozluźnia postrzeganie rzeczywistości i puszcza wolno absurdalne myśli."
	icon_state = "rainbow"
	start_message = "Czujniki optyczne gasną na ułamek sekundy i wracają, a świat mieni się pięknymi barwami!"
	end_message = "Żywe kolory ciemnieją do szarych cieni. Rzeczywistość znów przygniata..."
	cycle_messages = list(
		"Szara codzienność jeszcze nigdy nie była tak barwna! Kształty płyną, a nierzeczywiste rzeczy tańczą przed oczami.",
		"Tańczysz w chmurach, przesypując przez palce pył mgławicy. Niech to się nie kończy!",
		"Co jest prawdziwe, a co fałszywe? To przestaje mieć znaczenie.",
		"Nie wiesz, co daje ci taką satysfakcję, ale to coś niezwykłego.",
	)

/obj/item/aq_ipc_overloader/rainbow/start_effect(mob/living/carbon/human/target)
	target.set_drugginess(60)

/obj/item/aq_ipc_overloader/rainbow/cycle_effect(mob/living/carbon/human/target)
	. = ..()
	target.set_drugginess(60)

/obj/item/aq_ipc_overloader/rainbow/end_effect(mob/living/carbon/human/target)
	. = ..()
	target.set_drugginess(0)

/obj/item/aq_ipc_overloader/screenshaker
	name = "GwokBuzz ScreenShaker"
	desc = "Overloader, który każe serwom pulsować w losowych chwilach. Zaburza równowagę i dodaje energii."
	icon_state = "screenshake"
	start_message = "Obraz zaczyna się trząść, a serwa szarpią w losowe strony! Rozpiera cię energia!"
	end_message = "Serwa powoli przestają drgać i odzyskujesz kontrolę nad podwoziem..."
	cycle_messages = list(
		"Musisz biec! Masz energię! Nie masz koordynacji! Masz moc!",
		"Serwa zgłaszają ostrzeżenie o przeciążeniu. Nie masz ochoty go słuchać!",
		"Ten świat istnieje po to, żeby go zmieniać! Jesteś siłą zmiany!",
		"Mógłbyś dotknąć nieba! Wyskoczyć w chmury, w gwiazdy i dalej!",
	)

/obj/item/aq_ipc_overloader/screenshaker/start_effect(mob/living/carbon/human/target)
	target.Dizzy(20)
	target.Jitter(20)

/obj/item/aq_ipc_overloader/screenshaker/cycle_effect(mob/living/carbon/human/target)
	. = ..()
	target.Dizzy(20)
	target.Jitter(20)

/obj/item/aq_ipc_overloader/jitterbug
	name = "GwokBuzz Jitterbug"
	desc = "Overloader, który przeciąża poczucie zagrożenia. Wszystko wydaje się ryzykowniejsze niż zwykle."
	icon_state = "jitterbug"
	message_class = "warning"
	mood_type = /datum/mood_event/aq_overloader/scared
	start_message = "Czułość wykrywania zagrożeń wystrzeliwuje w górę! Niebezpieczeństwo czai się w każdym cieniu!"
	end_message = "Czujesz się bezpieczniej, otoczenie przestaje być ulem zagrożeń..."
	cycle_messages = list(
		"Wszystko dookoła drwi z twojej inteligencji. To jednocześnie ekscytujące i przerażające!",
		"Ktoś na ciebie poluje! Coś wspina się po twoim podwoziu! Nie widzisz tego, ale wiesz, że tam jest!",
		"W kącie coś jest. To na pewno zagrożenie! Uciekaj albo biegnij w jego stronę!",
		"Każdy lęk jest dziesięć razy silniejszy. Każda drobna obawa urasta do zagrożenia istnienia!",
	)

/obj/item/aq_ipc_overloader/jitterbug/cycle_effect(mob/living/carbon/human/target)
	. = ..()
	target.Jitter(10)

/obj/item/storage/box/aq_overloaders
	name = "zestaw overloaderów GwokBuzz"
	desc = "Przezroczyste opakowanie z pięcioma programami rekreacyjnymi dla IPC."
	icon = 'aquila/icons/obj/robotics/ipc_overloaders.dmi'
	icon_state = "box"

/obj/item/storage/box/aq_overloaders/PopulateContents()
	new /obj/item/aq_ipc_overloader/classic(src)
	new /obj/item/aq_ipc_overloader/tranquil(src)
	new /obj/item/aq_ipc_overloader/rainbow(src)
	new /obj/item/aq_ipc_overloader/screenshaker(src)
	new /obj/item/aq_ipc_overloader/jitterbug(src)

/datum/market_item/misc/aq_overloaders
	name = "Overloadery GwokBuzz"
	desc = "Cyfrowe używki dla IPC prosto z Konyangu. Pięć programów w paczce."
	item = /obj/item/storage/box/aq_overloaders
	price_min = 150
	price_max = 400
	stock_max = 3
	availability_prob = 80
