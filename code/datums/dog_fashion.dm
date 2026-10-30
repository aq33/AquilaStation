/datum/dog_fashion
	var/name
	var/desc
	var/emote_see
	var/emote_hear
	var/speak
	var/speak_emote

	// This isn't applied to the dog, but stores the icon_state of the
	// sprite that the associated item uses
	var/icon_file
	var/obj_icon_state
	var/obj_alpha
	var/obj_color

/datum/dog_fashion/New(mob/M)
	name = replacetext(name, "REAL_NAME", M.real_name)
	desc = replacetext(desc, "NAME", name)

/datum/dog_fashion/proc/apply(mob/living/simple_animal/pet/dog/D)
	if(name)
		D.name = name
	if(desc)
		D.desc = desc
	if(emote_see)
		D.emote_see = emote_see
	if(emote_hear)
		D.emote_hear = emote_hear
	if(speak)
		D.speak = speak
	if(speak_emote)
		D.speak_emote = speak_emote

/datum/dog_fashion/proc/get_overlay(var/dir)
	if(icon_file && obj_icon_state)
		var/image/corgI = image(icon_file, obj_icon_state, dir = dir)
		corgI.alpha = obj_alpha
		corgI.color = obj_color
		return corgI


/datum/dog_fashion/head
	icon_file = 'icons/mob/corgi_head.dmi'

/datum/dog_fashion/back
	icon_file = 'icons/mob/corgi_back.dmi'

/datum/dog_fashion/head/helmet
	name = "Sierżant REAL_NAME"
	desc = "Zawsze lojalny, zawsze czujny."

/datum/dog_fashion/head/chef
	name = "Zastępca szefa kuchni REAL_NAME"
	desc = "Twoje jedzenie zostanie skosztowane. Całe."


/datum/dog_fashion/head/captain
	name = "Kapitan REAL_NAME"
	desc = "Pewnie lepszy niż poprzedni kapitan."

/datum/dog_fashion/head/kitty
	name = "Runtime"
	emote_see = list("wykasłuje kłębek sierści", "przeciąga się")
	emote_hear = list("mruczy")
	speak = list("Mrrr", "Miau!", "MIAUUUUU!", "SSSSSS", "MIAUUUUUU")
	desc = "To słodki mały kotek! ...chwila... co jest, do diabła?"

/datum/dog_fashion/head/rabbit
	name = "Hoppy"
	emote_see = list("porusza noskiem", "trochę skacze dookoła")
	desc = "To Hoppy. To corgi... yyy... króliczek."

/datum/dog_fashion/head/beret
	name = "Yann"
	desc = "Mon dieu! C'est un chien!"
	speak = list("le hau!", "le hau hau!", "JAPPE!!")
	emote_see = list("kuli się ze strachu.", "poddaje się.", "udaje martwego.","wygląda, jakby przed nim była ściana.")


/datum/dog_fashion/head/detective
	name = "Detektyw REAL_NAME"
	desc = "NAME przejrzy twoje kłamstwa..."
	emote_see = list("bada okolicę.","węszy w poszukiwaniu wskazówek.","szuka chrupek Scooby.","wyjmuje cukierka z kapelusza.")


/datum/dog_fashion/head/nurse
	name = "Pielęgniarz REAL_NAME"
	desc = "NAME potrzebuje 100 cm³ suszonej wołowiny... NATYCHMIAST!"

/datum/dog_fashion/head/pirate
	name = "Piracki-tytuł Pirackie-imię"
	desc = "Arrrgh!! Toż to parszywy pies!"
	emote_see = list("poluje na skarby.","patrzy chłodno...","zgrzyta swoimi malutkimi ząbkami!")
	emote_hear = list("warczy zajadle!", "warczy.")
	speak = list("Arrrrgh!!","Grrrrrr!")

/datum/dog_fashion/head/pirate/New(mob/M)
	..()
	name = "[pick("Stary","Parszywy","Czarny","Rumowy","Kulawy","Krwawy","Zgniły","Śmiertelny","Długi John")] [pick("Chrupek","Kulas","Brodacz","Ząbek","Pokładowiec","Threepwood","Le Chuck","Korsarz","Silver","Crusoe")]"

/datum/dog_fashion/head/ushanka
	name = "Komunistyczny-tytuł Imię"
	desc = "Wyznawca Karola Barksa."
	emote_see = list("rozważa wady kapitalistycznego modelu gospodarczego.", "rozmyśla nad zaletami i wadami awangardyzmu.")

/datum/dog_fashion/head/ushanka/New(mob/M)
	..()
	name = "[pick("Towarzysz","Komisarz","Chwalebny Przywódca")] [M.real_name]"

/datum/dog_fashion/head/warden
	name = "Oficer REAL_NAME"
	emote_see = list("ślini się.","szuka pączków.")
	desc = "Stój, przestępcza szumowino!"

/datum/dog_fashion/head/blue_wizard
	name = "Arcymag REAL_NAME"
	speak = list("YAP", "Hau!", "Hau hau!", "AUUUUUU", "EI  NATH!")

/datum/dog_fashion/head/red_wizard
	name = "Piromanta REAL_NAME"
	speak = list("YAP", "Hau!", "Hau hau!", "AUUUUUU", "ONI SOMA!")

/datum/dog_fashion/head/cardborg
	name = "Borgi"
	speak = list("Ping!","Bip!","Hau!")
	emote_see = list("wymyka się spod kontroli.", "wywęszy nieludzi.")
	desc = "Efekt cięć w budżecie robotyki."

/datum/dog_fashion/head/ghost
	name = "\improper Duch"
	speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
	emote_see = list("zatacza się.", "drży.")
	emote_hear = list("wyje!","jęczy.")
	desc = "Straszne!"
	obj_icon_state = "sheet"

/datum/dog_fashion/head/santa
	name = "Pomocnik Mikołaja, corgi"
	emote_hear = list("szczeka kolędy.", "radośnie ujada!")
	emote_see = list("szuka prezentów.", "sprawdza swoją listę.")
	desc = "Uwielbia mleko i ciasteczka."

/datum/dog_fashion/head/cargo_tech
	name = "Technik corgi REAL_NAME"
	desc = "To przez niego twoje żółte rękawice są pogryzione."

/datum/dog_fashion/head/reindeer
	name = "REAL_NAME, czerwononosy corgi"
	emote_hear = list("oświetla drogę!", "świeci.", "ujada!")
	desc = "Ma bardzo błyszczący nos."

/datum/dog_fashion/head/sombrero
	name = "Señor REAL_NAME"
	desc = "Musisz szanować Starszego Psiaka"

/datum/dog_fashion/head/sombrero/New(mob/M)
	..()
	desc = "Musisz szanować Starszego: [M.real_name]."

/datum/dog_fashion/head/hop
	name = "Porucznik REAL_NAME"
	desc = "Można mu zaufać, że sam nie ucieknie."

/datum/dog_fashion/head/deathsquad
	name = "Szturmowiec REAL_NAME"
	desc = "To nie czerwona farba. To prawdziwa krew corgi."

/datum/dog_fashion/head/clown
	name = "REAL_NAME, klaun"
	desc = "Najlepszy przyjaciel Honkmana."
	speak = list("HONK!", "Honk!")
	emote_see = list("płata figle.", "poślizguje się.")

/datum/dog_fashion/back/deathsquad
	name = "Szturmowiec REAL_NAME"
	desc = "To nie czerwona farba. To prawdziwa krew corgi."
