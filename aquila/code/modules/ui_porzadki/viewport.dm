// AQ - porządki w UI: widok gry dopasowuje się do okna.
// Skin (interface/skin.dmf, mainwindow on-size) woła .auto_fit_viewport przy każdej zmianie
// rozmiaru okna - bez tego po poszerzeniu okna mapa dostawała czarne pasy zamiast rosnąć.

/// Przy przeciąganiu krawędzi okna on-size leci wiele razy - dopasowujemy dopiero po chwili spokoju
#define AUTO_FIT_VIEWPORT_DELAY (0.3 SECONDS)

/client/verb/auto_fit_viewport()
	set name = ".auto_fit_viewport"
	set hidden = TRUE
	if(!prefs || !(prefs.toggles2 & PREFTOGGLE_2_AUTO_FIT_VIEWPORT))
		return
	addtimer(CALLBACK(src, TYPE_VERB_REF(/client, fit_viewport)), AUTO_FIT_VIEWPORT_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)

#undef AUTO_FIT_VIEWPORT_DELAY

/// Pełny ekran z ustawień włącza się od razu po wejściu, a nie dopiero po F11
/client/proc/apply_fullscreen_pref()
	set waitfor = FALSE
	// Jak menu pod Esc: chwila na załadowanie skinu, inaczej okno nie wchodzi w pełny ekran
	sleep(2 SECONDS)
	if(!src || !prefs || !(prefs.toggles2 & PREFTOGGLE_2_FULLSCREEN))
		return
	toggle_fullscreen(TRUE)
