/datum/design/nanites
	name = "Brak"
	desc = "Jeśli to widzisz, zgłoś to koderowi."
	id = "default_nanites"
	build_type = NANITE_COMPILER
	construction_time = 50
	category = list()
	research_icon = 'icons/obj/device.dmi'
	research_icon_state = "nanite_program"
	var/program_type = /datum/nanite_program

////////////////////UTILITY NANITES//////////////////////////////////////

/datum/design/nanites/metabolic_synthesis
	name = "Synteza metaboliczna"
	desc = "Nanity wykorzystują cykl metaboliczny nosiciela, by przyspieszyć replikację, zużywając jego nadmiar składników odżywczych jako paliwo."
	id = "metabolic_nanites"
	program_type = /datum/nanite_program/metabolic_synthesis
	category = list("Utility Nanites")

/datum/design/nanites/viral
	name = "Wirusowa replika"
	desc = "Nanity nieustannie wysyłają zaszyfrowane sygnały, próbując siłą skopiować swoje oprogramowanie do innych skupisk nanitów."
	id = "viral_nanites"
	program_type = /datum/nanite_program/viral
	category = list("Utility Nanites")

/datum/design/nanites/research
	name = "Obliczenia rozproszone"
	desc = "Nanity wspomagają serwery badawcze, wykonując część ich obliczeń, co zwiększa przyrost punktów badań."
	id = "research_nanites"
	program_type = /datum/nanite_program/research
	category = list("Utility Nanites")

/datum/design/nanites/researchplus
	name = "Sieć neuronowa"
	desc = "Nanity łączą mózgi nosicieli w neuronową sieć badawczą, która działa tym wydajniej, im więcej jest nosicieli. Można ją przeciążyć, by zwiększyć wydajność badań."
	id = "researchplus_nanites"
	program_type = /datum/nanite_program/researchplus
	category = list("Utility Nanites")

/datum/design/nanites/monitoring
	name = "Monitorowanie"
	desc = "Nanity monitorują funkcje życiowe i położenie nosiciela, przesyłając je do sieci czujników kombinezonów."
	id = "monitoring_nanites"
	program_type = /datum/nanite_program/monitoring
	category = list("Utility Nanites")

/datum/design/nanites/self_scan
	name = "Skan nosiciela"
	desc = "Nanity wyświetlają nosicielowi szczegółowy odczyt skanu ciała."
	id = "selfscan_nanites"
	program_type = /datum/nanite_program/self_scan
	category = list("Utility Nanites")

/datum/design/nanites/dermal_button
	name = "Przycisk skórny"
	desc = "Wyświetla na skórze nosiciela przycisk, którym można wysłać sygnał do nanitów."
	id = "dermal_button_nanites"
	program_type = /datum/nanite_program/dermal_button
	category = list("Utility Nanites")

/datum/design/nanites/stealth
	name = "Kamuflaż"
	desc = "Nanity ukrywają swoją aktywność i oprogramowanie przed pobieżnymi skanami."
	id = "stealth_nanites"
	program_type = /datum/nanite_program/stealth
	category = list("Utility Nanites")

/datum/design/nanites/reduced_diagnostics
	name = "Ograniczona diagnostyka"
	desc = "Wyłącza część kosztownej diagnostyki nanitów, przez co nie przekazują listy programów przenośnym skanerom. \
	Oszczędza to nieco energii i lekko przyspiesza replikację."
	id = "red_diag_nanites"
	program_type = /datum/nanite_program/reduced_diagnostics
	category = list("Utility Nanites")

/datum/design/nanites/access
	name = "Podskórny identyfikator"
	desc = "Nanity zapisują uprawnienia dostępu z identyfikatora nosiciela na podskórnym pasku magnetycznym. Po aktywacji aktualizują je, kopiując obecny dostęp nosiciela."
	id = "access_nanites"
	program_type = /datum/nanite_program/access
	category = list("Utility Nanites")

/datum/design/nanites/relay
	name = "Przekaźnik"
	desc = "Nanity odbierają i przekazują dalekosiężne sygnały nanitów."
	id = "relay_nanites"
	program_type = /datum/nanite_program/relay
	category = list("Utility Nanites")

/datum/design/nanites/repeater
	name = "Powtarzacz sygnału"
	desc = "Po aktywacji wysyła nanitom kolejny sygnał, opcjonalnie z opóźnieniem."
	id = "repeater_nanites"
	program_type = /datum/nanite_program/sensor/repeat
	category = list("Utility Nanites")

/datum/design/nanites/relay_repeater
	name = "Powtarzacz sygnału przekaźnika"
	desc = "Po aktywacji wysyła kolejny sygnał na kanał przekaźnika, opcjonalnie z opóźnieniem."
	id = "relay_repeater_nanites"
	program_type = /datum/nanite_program/sensor/relay_repeat
	category = list("Utility Nanites")

/datum/design/nanites/emp
	name = "Rezonans elektromagnetyczny"
	desc = "Po aktywacji nanity wywołują wokół nosiciela impuls elektromagnetyczny. Uszkodzi to inne programy nanitów!"
	id = "emp_nanites"
	program_type = /datum/nanite_program/emp
	category = list("Utility Nanites")

/datum/design/nanites/spreading
	name = "Zakaźna egzolokomocja"
	desc = "Nanity zyskują zdolność krótkiego przetrwania poza ludzkim ciałem oraz zakładania nowych kolonii bez procesu integracji, \
			co daje skrajnie zakaźny szczep nanitów."
	id = "spreading_nanites"
	program_type = /datum/nanite_program/spreading
	category = list("Utility Nanites")

/datum/design/nanites/nanite_sting
	name = "Żądło nanitów"
	desc = "Po aktywacji wystrzeliwuje niemal niewidoczny kolec nanitów, który próbuje zarazić pobliską osobę bez nanitów kopią skupiska nanitów nosiciela."
	id = "nanite_sting_nanites"
	program_type = /datum/nanite_program/nanite_sting
	category = list("Utility Nanites")

/datum/design/nanites/mitosis
	name = "Mitoza"
	desc = "Nanity zyskują zdolność samoreplikacji zasilanej bluespace zamiast kopiowania z wzorca. To gwałtownie przyspiesza replikację, \
			ale wadliwe kopie wywołują od czasu do czasu błędy oprogramowania. Niezgodne z synchronizacją z chmurą."
	id = "mitosis_nanites"
	program_type = /datum/nanite_program/mitosis
	category = list("Utility Nanites")

////////////////////MEDICAL NANITES//////////////////////////////////////
/datum/design/nanites/regenerative
	name = "Przyspieszona regeneracja"
	desc = "Nanity wzmacniają naturalną regenerację nosiciela, przyspieszając gojenie."
	id = "regenerative_nanites"
	program_type = /datum/nanite_program/regenerative
	category = list("Medical Nanites")

/datum/design/nanites/regenerative_advanced
	name = "Biorekonstrukcja"
	desc = "Nanity ręcznie naprawiają i wymieniają komórki organiczne, działając znacznie szybciej niż zwykła regeneracja. \
			Program nie odróżnia jednak tkanek uszkodzonych od zdrowych, więc zużywa nanity nawet wtedy, gdy nic nie daje."
	id = "regenerative_plus_nanites"
	program_type = /datum/nanite_program/regenerative_advanced
	category = list("Medical Nanites")

/datum/design/nanites/temperature
	name = "Regulacja temperatury"
	desc = "Nanity ustawiają temperaturę wewnętrzną nosiciela na idealnym poziomie."
	id = "temperature_nanites"
	program_type = /datum/nanite_program/temperature
	category = list("Medical Nanites")

/datum/design/nanites/purging
	name = "Oczyszczanie krwi"
	desc = "Nanity usuwają toksyny i chemikalia z krwiobiegu nosiciela."
	id = "purging_nanites"
	program_type = /datum/nanite_program/purging
	category = list("Medical Nanites")

/datum/design/nanites/purging_advanced
	name = "Wybiórcze oczyszczanie krwi"
	desc = "Nanity usuwają toksyny i niebezpieczne chemikalia z krwiobiegu nosiciela, pomijając te korzystne. \
			Dodatkowa moc obliczeniowa potrzebna do analizy chemikaliów znacznie zwiększa zużycie nanitów."
	id = "purging_plus_nanites"
	program_type = /datum/nanite_program/purging_advanced
	category = list("Medical Nanites")

/datum/design/nanites/brain_heal
	name = "Regeneracja neuronów"
	desc = "Nanity naprawiają połączenia nerwowe w mózgu nosiciela, cofając uszkodzenia mózgu i drobne urazy."
	id = "brainheal_nanites"
	program_type = /datum/nanite_program/brain_heal
	category = list("Medical Nanites")

/datum/design/nanites/brain_heal_advanced
	name = "Odtwarzanie połączeń nerwowych"
	desc = "Nanity potrafią zapisać kopię połączeń nerwowych nosiciela i je odtworzyć, zastępując nawet całe fragmenty brakującej lub uszkodzonej tkanki mózgowej."
	id = "brainheal_plus_nanites"
	program_type = /datum/nanite_program/brain_heal_advanced
	category = list("Medical Nanites")

/datum/design/nanites/blood_restoring
	name = "Regeneracja krwi"
	desc = "Nanity pobudzają i wzmacniają wytwarzanie krwinek u nosiciela."
	id = "bloodheal_nanites"
	program_type = /datum/nanite_program/blood_restoring
	category = list("Medical Nanites")

/datum/design/nanites/repairing
	name = "Naprawa mechaniczna"
	desc = "Nanity naprawiają uszkodzenia mechanicznych kończyn nosiciela."
	id = "repairing_nanites"
	program_type = /datum/nanite_program/repairing
	category = list("Medical Nanites")

/datum/design/nanites/defib
	name = "Defibrylacja"
	desc = "Po aktywacji nanity wysyłają do serca nosiciela impuls defibrylujący."
	id = "defib_nanites"
	program_type = /datum/nanite_program/defib
	category = list("Medical Nanites")


////////////////////AUGMENTATION NANITES//////////////////////////////////////

/datum/design/nanites/nervous
	name = "Wsparcie nerwów"
	desc = "Nanity działają jak drugi układ nerwowy, skracając czas ogłuszenia nosiciela."
	id = "nervous_nanites"
	program_type = /datum/nanite_program/nervous
	category = list("Augmentation Nanites")

/datum/design/nanites/hardening
	name = "Utwardzenie skóry"
	desc = "Nanity tworzą pod skórą nosiciela siatkę, która chroni go przed ciosami i pociskami."
	id = "hardening_nanites"
	program_type = /datum/nanite_program/hardening
	category = list("Augmentation Nanites")

/datum/design/nanites/refractive
	name = "Refrakcyjna powłoka skóry"
	desc = "Nanity tworzą na skórze nosiciela błonę, która osłabia trafienia laserów i broni energetycznej."
	id = "refractive_nanites"
	program_type = /datum/nanite_program/refractive
	category = list("Augmentation Nanites")

/datum/design/nanites/coagulating
	name = "Szybkie krzepnięcie"
	desc = "Gdy nosiciel jest ranny, nanity wywołują szybkie krzepnięcie, drastycznie ograniczając krwawienie."
	id = "coagulating_nanites"
	program_type = /datum/nanite_program/coagulating
	category = list("Augmentation Nanites")

/datum/design/nanites/conductive
	name = "Przewodnictwo elektryczne"
	desc = "Nanity działają jak uziemienie dla porażeń prądem, chroniąc nosiciela. Porażenia wciąż mogą uszkodzić same nanity."
	id = "conductive_nanites"
	program_type = /datum/nanite_program/conductive
	category = list("Augmentation Nanites")

/datum/design/nanites/mindshield
	name = "Bariera umysłowa"
	desc = "Póki są aktywne, nanity tworzą wokół mózgu nosiciela ochronną błonę, która osłania go przed nienaturalnymi wpływami."
	id = "mindshield_nanites"
	program_type = /datum/nanite_program/mindshield
	category = list("Augmentation Nanites")

/datum/design/nanites/adrenaline
	name = "Zastrzyk adrenaliny"
	desc = "Po aktywacji nanity wywołują wyrzut adrenaliny, który wybudza nosiciela z ogłuszenia i chwilowo go przyspiesza."
	id = "adrenaline_nanites"
	program_type = /datum/nanite_program/adrenaline
	category = list("Augmentation Nanites")

////////////////////DEFECTIVE NANITES//////////////////////////////////////

/datum/design/nanites/glitch
	name = "Usterka"
	desc = "Poważne uszkodzenie oprogramowania, przez które nanity stopniowo się rozpadają."
	id = "glitch_nanites"
	program_type = /datum/nanite_program/glitch
	category = list("Defective Nanites")

/datum/design/nanites/necrotic
	name = "Martwica"
	desc = "Nanity bez różnicy atakują tkanki wewnętrzne, wywołując rozległe uszkodzenia."
	id = "necrotic_nanites"
	program_type = /datum/nanite_program/necrotic
	category = list("Defective Nanites")

/datum/design/nanites/toxic
	name = "Kumulacja toksyn"
	desc = "Nanity powodują powolne, ale stałe gromadzenie się toksyn w nosicielu."
	id = "toxic_nanites"
	program_type = /datum/nanite_program/toxic
	category = list("Defective Nanites")

/datum/design/nanites/suffocating
	name = "Hipoksemia"
	desc = "Nanity utrudniają krwi nosiciela skuteczne wchłanianie tlenu."
	id = "suffocating_nanites"
	program_type = /datum/nanite_program/suffocating
	category = list("Defective Nanites")

/datum/design/nanites/brain_misfire
	name = "Zakłócenia mózgowe"
	desc = "Nanity zakłócają szlaki nerwowe, wywołując drobne zaburzenia psychiczne."
	id = "brainmisfire_nanites"
	program_type = /datum/nanite_program/brain_misfire
	category = list("Defective Nanites")

/datum/design/nanites/skin_decay
	name = "Dermaliza"
	desc = "Nanity atakują komórki skóry, wywołując podrażnienia, wysypki i drobne obrażenia."
	id = "skindecay_nanites"
	program_type = /datum/nanite_program/skin_decay
	category = list("Defective Nanites")

/datum/design/nanites/nerve_decay
	name = "Rozpad nerwów"
	desc = "Nanity atakują nerwy nosiciela, wywołując brak koordynacji i krótkie napady paraliżu."
	id = "nervedecay_nanites"
	program_type = /datum/nanite_program/nerve_decay
	category = list("Defective Nanites")

/datum/design/nanites/brain_decay
	name = "Nanity zjadające mózg"
	desc = "Uszkadza komórki mózgowe, stopniowo osłabiając funkcje poznawcze nosiciela."
	id = "braindecay_nanites"
	program_type = /datum/nanite_program/brain_decay
	category = list("Defective Nanites")

////////////////////WEAPONIZED NANITES/////////////////////////////////////

/datum/design/nanites/flesh_eating
	name = "Rozpad komórkowy"
	desc = "Nanity niszczą struktury komórkowe w ciele nosiciela, zadając obrażenia fizyczne."
	id = "flesheating_nanites"
	program_type = /datum/nanite_program/flesh_eating
	category = list("Weaponized Nanites")

/datum/design/nanites/poison
	name = "Zatrucie"
	desc = "Nanity dostarczają trujące chemikalia do organów wewnętrznych nosiciela, wywołując zatrucie i wymioty."
	id = "poison_nanites"
	program_type = /datum/nanite_program/poison
	category = list("Weaponized Nanites")

/datum/design/nanites/memory_leak
	name = "Wyciek pamięci"
	desc = "Ten program wdziera się w przestrzeń pamięci innych programów, wywołując częste uszkodzenia i błędy."
	id = "memleak_nanites"
	program_type = /datum/nanite_program/memory_leak
	category = list("Weaponized Nanites")

/datum/design/nanites/aggressive_replication
	name = "Agresywna replikacja"
	desc = "Nanity pochłaniają materię organiczną, by szybciej się replikować, raniąc przy tym nosiciela."
	id = "aggressive_nanites"
	program_type = /datum/nanite_program/aggressive_replication
	category = list("Weaponized Nanites")

/datum/design/nanites/meltdown
	name = "Stopienie"
	desc = "Wywołuje wewnętrzne stopienie nanitów, które parzy nosiciela od środka i szybko niszczy populację nanitów. \
			Po aktywacji ustawia próg bezpieczeństwa nanitów na 0."
	id = "meltdown_nanites"
	program_type = /datum/nanite_program/meltdown
	category = list("Weaponized Nanites")

/datum/design/nanites/cryo
	name = "Terapia kriogeniczna"
	desc = "Nanity szybko odprowadzają ciepło przez skórę nosiciela, obniżając jego temperaturę."
	id = "cryo_nanites"
	program_type = /datum/nanite_program/cryo
	category = list("Weaponized Nanites")

/datum/design/nanites/pyro
	name = "Spalanie podskórne"
	desc = "Nanity gromadzą pod skórą nosiciela łatwopalne płyny, a potem je zapalają."
	id = "pyro_nanites"
	program_type = /datum/nanite_program/pyro
	category = list("Weaponized Nanites")

/datum/design/nanites/heart_stop
	name = "Zatrzymanie serca"
	desc = "Po aktywacji zatrzymuje serce nosiciela, a po ponownej aktywacji uruchamia je z powrotem."
	id = "heartstop_nanites"
	program_type = /datum/nanite_program/heart_stop
	category = list("Weaponized Nanites")

/datum/design/nanites/explosive
	name = "Detonacja łańcuchowa"
	desc = "Po aktywacji wysadza w reakcji łańcuchowej wszystkie nanity w nosicielu."
	id = "explosive_nanites"
	program_type = /datum/nanite_program/explosive
	category = list("Weaponized Nanites")

/datum/design/nanites/mind_control
	name = "Kontrola umysłu"
	desc = "Póki są aktywne, nanity wpajają mózgowi nosiciela bezwzględną dyrektywę."
	id = "mindcontrol_nanites"
	program_type = /datum/nanite_program/comm/mind_control
	category = list("Weaponized Nanites")

/datum/design/nanites/haste
	name = "Wstrzyknięcie amfetaminy"
	desc = "Po aktywacji nanity syntetyzują amfetaminę, która chwilowo przyspiesza bieg nosiciela."
	id = "haste_nanites"
	program_type = /datum/nanite_program/haste
	category = list("Weaponized Nanites")

////////////////////SUPPRESSION NANITES//////////////////////////////////////

/datum/design/nanites/shock
	name = "Porażenie prądem"
	desc = "Po aktywacji nanity porażają nosiciela prądem. Niszczy to dużą liczbę nanitów!"
	id = "shock_nanites"
	program_type = /datum/nanite_program/shocking
	category = list("Suppression Nanites")

/datum/design/nanites/stun
	name = "Wstrząs nerwowy"
	desc = "Po aktywacji nanity wysyłają impuls do nerwów nosiciela, na krótko go obezwładniając."
	id = "stun_nanites"
	program_type = /datum/nanite_program/stun
	category = list("Suppression Nanites")

/datum/design/nanites/sleepy
	name = "Indukcja snu"
	desc = "Po aktywacji nanity wywołują nagły atak narkolepsji."
	id = "sleep_nanites"
	program_type = /datum/nanite_program/sleepy
	category = list("Suppression Nanites")

/datum/design/nanites/paralyzing
	name = "Paraliż"
	desc = "Nanity aktywnie tłumią impulsy nerwowe, skutecznie paraliżując nosiciela."
	id = "paralyzing_nanites"
	program_type = /datum/nanite_program/paralyzing
	category = list("Suppression Nanites")

/datum/design/nanites/fake_death
	name = "Symulacja śmierci"
	desc = "Nanity wprowadzają nosiciela w śpiączkę przypominającą śmierć, która zmyli większość skanów medycznych."
	id = "fakedeath_nanites"
	program_type = /datum/nanite_program/fake_death
	category = list("Suppression Nanites")

/datum/design/nanites/pacifying
	name = "Pacyfikacja"
	desc = "Nanity tłumią ośrodek agresji w mózgu, przez co nosiciel nie może bezpośrednio krzywdzić innych."
	id = "pacifying_nanites"
	program_type = /datum/nanite_program/pacifying
	category = list("Suppression Nanites")

/datum/design/nanites/blinding
	name = "Ślepota"
	desc = "Póki są aktywne, nanity tłumią nerwy wzrokowe nosiciela, oślepiając go."
	id = "blinding_nanites"
	program_type = /datum/nanite_program/blinding
	category = list("Suppression Nanites")

/datum/design/nanites/mute
	name = "Niemota"
	desc = "Póki są aktywne, nanity tłumią mowę nosiciela, odbierając mu głos."
	id = "mute_nanites"
	program_type = /datum/nanite_program/mute
	category = list("Suppression Nanites")

/datum/design/nanites/voice
	name = "Echo w czaszce"
	desc = "Nanity odtwarzają w czaszce nosiciela syntetyczną wiadomość."
	id = "voice_nanites"
	program_type = /datum/nanite_program/comm/voice
	category = list("Suppression Nanites")

/datum/design/nanites/speech
	name = "Wymuszona mowa"
	desc = "Po aktywacji nanity zmuszają nosiciela do wypowiedzenia zaprogramowanego zdania."
	id = "speech_nanites"
	program_type = /datum/nanite_program/comm/speech
	category = list("Suppression Nanites")

/datum/design/nanites/hallucination
	name = "Halucynacje"
	desc = "Nanity sprawiają, że nosiciel widzi i słyszy rzeczy, których nie ma."
	id = "hallucination_nanites"
	program_type = /datum/nanite_program/comm/hallucination
	category = list("Suppression Nanites")

/datum/design/nanites/good_mood
	name = "Wzmacniacz szczęścia"
	desc = "Nanity syntetyzują serotoninę w mózgu nosiciela, wywołując sztuczne poczucie szczęścia."
	id = "good_mood_nanites"
	program_type = /datum/nanite_program/good_mood
	category = list("Suppression Nanites")

/datum/design/nanites/bad_mood
	name = "Tłumik szczęścia"
	desc = "Nanity tłumią wytwarzanie serotoniny w mózgu nosiciela, wywołując sztuczny stan depresji."
	id = "bad_mood_nanites"
	program_type = /datum/nanite_program/bad_mood
	category = list("Suppression Nanites")

////////////////////SENSOR NANITES//////////////////////////////////////

/datum/design/nanites/sensor_health
	name = "Czujnik zdrowia"
	desc = "Nanity odbierają sygnał, gdy zdrowie nosiciela jest powyżej/poniżej określonego progu procentowego."
	id = "sensor_health_nanites"
	program_type = /datum/nanite_program/sensor/health
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_damage
	name = "Czujnik obrażeń"
	desc = "Nanity odbierają sygnał, gdy określony rodzaj obrażeń nosiciela jest powyżej/poniżej wartości docelowej."
	id = "sensor_damage_nanites"
	program_type = /datum/nanite_program/sensor/damage
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_crit
	name = "Czujnik stanu krytycznego"
	desc = "Nanity odbierają sygnał, gdy nosiciel po raz pierwszy wchodzi w stan krytyczny."
	id = "sensor_crit_nanites"
	program_type = /datum/nanite_program/sensor/crit
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_death
	name = "Czujnik śmierci"
	desc = "Nanity odbierają sygnał, gdy wykryją, że nosiciel nie żyje."
	id = "sensor_death_nanites"
	program_type = /datum/nanite_program/sensor/death
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_voice
	name = "Czujnik głosu"
	desc = "Wysyła sygnał, gdy nanity usłyszą określone słowo lub zdanie."
	id = "sensor_voice_nanites"
	program_type = /datum/nanite_program/sensor/voice
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_nanite_volume
	name = "Czujnik objętości nanitów"
	desc = "Nanity odbierają sygnał, gdy zapas nanitów jest powyżej/poniżej określonego progu procentowego."
	id = "sensor_nanite_volume"
	program_type = /datum/nanite_program/sensor/nanite_volume
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_species
	name = "Czujnik gatunku"
	desc = "Po aktywacji nanity skanują nosiciela, by ustalić jego gatunek, i wysyłają sygnał zależnie od warunków ustawionych w opcjach."
	id = "sensor_species_nanites"
	program_type = /datum/nanite_program/sensor/species
	category = list("Sensor Nanites")
