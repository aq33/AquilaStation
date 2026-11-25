// Okna w formie urządzeń (PixelUi): mikrofalówka, młynek, dozowniki baru, blok utylizacyjny, pulpit fabrykatora.
// Wzór: seria Polonium Station (polonium14/polonium-station#1280, #1283, #1287, #1299, #1301).
// Strona TGUI: tgui/packages/tgui/interfaces/PixelUi/ i okna *Device.tsx, grafiki w tgui/packages/tgui/assets/pixelui/.

/// Ikony przedmiotów dla okien urządzeń, klucz "ikona|stan|kolor" -> PNG w base64
GLOBAL_LIST_EMPTY(pixel_device_icon_cache)

/// Sprite przedmiotu (kierunek południe, pierwsza klatka) jako PNG w base64, z pamięcią podręczną.
/// Nakładki (np. dodatki na jedzeniu) się nie liczą, wystarcza sama sylwetka przedmiotu w oknie.
/proc/pixel_device_icon(atom/thing)
	if(!thing?.icon)
		return null
	var/key = "[thing.icon]|[thing.icon_state]|[thing.color]"
	. = GLOB.pixel_device_icon_cache[key]
	if(.)
		return
	var/icon/flat = icon(thing.icon, thing.icon_state, SOUTH, 1)
	if(istext(thing.color))
		flat.Blend(thing.color, ICON_MULTIPLY)
	. = icon2base64(flat)
	GLOB.pixel_device_icon_cache[key] = .

/// Ikona typu przedmiotu (bez instancji), np. projektu w fabrykatorze
/proc/pixel_device_type_icon(atom/thing_type)
	if(!ispath(thing_type, /atom))
		return null
	var/icon_file = initial(thing_type.icon)
	var/icon_state = initial(thing_type.icon_state)
	if(!icon_file)
		return null
	var/key = "[icon_file]|[icon_state]|"
	. = GLOB.pixel_device_icon_cache[key]
	if(.)
		return
	. = icon2base64(icon(icon_file, icon_state, SOUTH, 1))
	GLOB.pixel_device_icon_cache[key] = .

// Klawisz KLASYCZNE: stare okno maszyny (receptury, dyski, opcje kolejki), do jego zamknięcia.
// Po zamknięciu starego okna maszyna znów otwiera okno urządzenia.

/obj/machinery
	/// REF-y graczy, którzy przełączyli tę maszynę na stare okno (lista leniwa)
	var/list/aq_classic_ui_users

/obj/machinery/proc/aq_wants_classic_ui(mob/user)
	return user && LAZYFIND(aq_classic_ui_users, REF(user))

/obj/machinery/proc/aq_forget_classic_ui(mob/user)
	if(user)
		LAZYREMOVE(aq_classic_ui_users, REF(user))

/obj/machinery/proc/aq_open_classic_ui(mob/user)
	if(!user)
		return
	// Najpierw zamknięcie okna urządzenia: jego ui_close() czyści listę
	SStgui.close_user_uis(user, src)
	LAZYOR(aq_classic_ui_users, REF(user))
	ui_interact(user)
