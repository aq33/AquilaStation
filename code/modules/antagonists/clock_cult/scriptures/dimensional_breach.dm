//==================================//
// !      Dimensional Breach      ! //
//==================================//
/datum/clockcult/scripture/ark_activation
	name = "Ożywienie Arki"
	desc = "Przygotowuje Arkę do aktywacji, ostrzegając załogę o twoim istnieniu. Wymaga 6 przywołujących."
	tip = "Przygotowuje Arkę do aktywacji, ostrzegając załogę o twoim istnieniu."
	button_icon_state = "Spatial Gateway"
	power_cost = 5000
	invokation_time = 140
	invokation_text = list("O wielka Maszyno, weź moją duszę...", "nadszedł czas, byś powstał...", "przez szczeliny przybędziesz...", "by znów powstać wśród gwiazd!")
	invokers_required = 6
	category = SPELLTYPE_SERVITUDE
	recital_sound = 'sound/magic/clockwork/narsie_attack.ogg'

/datum/clockcult/scripture/ark_activation/New()
	. = ..()

/datum/clockcult/scripture/ark_activation/check_special_requirements(mob/user)
	if(!..())
		return FALSE
	if(!is_reebe(get_area(invoker)))
		to_chat(invoker, "<span class='brass'>Musisz być blisko bramy, żeby czerpać jej energię!</span>")
		return FALSE
	return TRUE

/datum/clockcult/scripture/ark_activation/invoke_success()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	if(!gateway)
		to_chat(invoker, "<span class='brass'>Nie znaleziono niebiańskiej bramy, skontaktuj się z adminami.</span>")
		return FALSE
	gateway.open_gateway()
