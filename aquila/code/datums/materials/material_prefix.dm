// AQUILA - polskie nazwy materiałów (port BeeStation/BeeStation-Hornet#10135 i #9386)
// `name` materiału zostaje po angielsku, bo porównują go mennica, fabrykatory i TGUI.
// MATERIAL_ADD_PREFIX dopisuje przed nazwą przymiotnik w rodzaju nazwy przedmiotu:
// „złota moneta”, „drewniane krzesło”, „mięsna ściana”.

/atom
	/// Rodzaj gramatyczny nazwy dla przymiotnika materiału: MALE, FEMALE, NEUTER albo PLURAL; null = zgadnij z nazwy
	var/material_name_gender

/datum/material
	/// Polska nazwa materiału w mianowniku (opis „Materiał: …”)
	var/polish_name
	/// Przymiotnik w rodzaju męskim, żeńskim i nijakim (nijaki służy też dla liczby mnogiej)
	var/list/name_adjectives
	/// Gdy materiał nie ma przymiotnika, dopisuje się to po nazwie („krzesło bluespace”)
	var/name_suffix

/// Nazwa materiału do opisu przedmiotu
/datum/material/proc/get_polish_name()
	return polish_name || name

/// Przymiotnik albo pełna nazwa z dopiskiem dla danego atomu
/datum/material/proc/get_prefixed_name(atom/source)
	if(length(name_adjectives) < 3)
		return "[source.name] [name_suffix || get_polish_name()]"
	var/adjective = name_adjectives[1]
	switch(source.material_name_gender || guess_polish_name_gender(source.name))
		if(FEMALE)
			adjective = name_adjectives[2]
		if(NEUTER, PLURAL)
			adjective = name_adjectives[3]
	return "[adjective] [source.name]"

/**
 * Rodzaj gramatyczny polskiej nazwy po końcówce pierwszego słowa. W polskim przymiotnik zgadza się z rzeczownikiem,
 * więc pierwsze słowo („skrzynka narzędziowa”, „eleganckie krzesło”, „długopis”) zwykle wystarcza:
 * -a żeński, -o/-e/-ę/-um nijaki, reszta męski. Końcówki -y/-i nie wystarczą („złoty” to przymiotnik, „okulary” liczba
 * mnoga), więc rzeczowniki tylko w liczbie mnogiej i żeńskie zakończone spółgłoską są na listach niżej.
 * Typy z nietypową nazwą ustawiają material_name_gender.
 */
/proc/guess_polish_name_gender(name)
	// Rzeczowniki używane tylko (albo prawie zawsze) w liczbie mnogiej: „złote okulary”, „złote drzwi”
	var/static/list/plural_nouns = list("okulary", "drzwi", "nożyczki", "nożyce", "rękawice", "rękawiczki", "buty", "spodnie",
		"kajdanki", "słuchawki", "gogle", "szczypce", "obcęgi", "sanki", "skrzypce", "kości", "szelki", "majtki", "bokserki",
		"kapcie", "sandały", "trampki", "klapki", "łyżwy", "narty", "wrotki", "korale", "koraliki", "cymbałki", "dzwonki",
		"skarpety", "skarpetki", "rajstopy", "pończochy", "nogawice", "naramienniki", "nagolenniki", "karwasze", "kalesony")
	// Rzeczowniki żeńskie zakończone spółgłoską: „złota kość”, „miedziana sieć”
	var/static/list/feminine_consonant_nouns = list("kość", "sieć", "nić", "maść", "broń", "sól", "łódź", "mysz", "twarz", "rzecz",
		"odzież", "pościel", "dłoń", "krew", "miedź", "kieszeń", "noc", "pieśń", "rękojeść", "płeć", "postać",
		"przepaść", "jabłoń", "łączność", "paproć", "gałąź", "złość", "pierś", "brew", "uprząż", "kiść", "oś", "ość")
	var/list/words = splittext(lowertext(name), " ")
	var/first_word = length(words) ? words[1] : ""
	if(!length(first_word))
		return MALE
	if(first_word in plural_nouns)
		return PLURAL
	if(first_word in feminine_consonant_nouns)
		return FEMALE
	var/last_letter = copytext_char(first_word, -1)
	if(last_letter == "a")
		return FEMALE
	if(last_letter in list("o", "e", "ę"))
		return NEUTER
	if(length_char(first_word) > 2 && copytext_char(first_word, -2) == "um")
		return NEUTER
	return MALE

/datum/material/iron
	polish_name = "żelazo"
	name_adjectives = list("żelazny", "żelazna", "żelazne")

/datum/material/glass
	polish_name = "szkło"
	name_adjectives = list("szklany", "szklana", "szklane")

/datum/material/silver
	polish_name = "srebro"
	name_adjectives = list("srebrny", "srebrna", "srebrne")

/datum/material/gold
	polish_name = "złoto"
	name_adjectives = list("złoty", "złota", "złote")

/datum/material/diamond
	polish_name = "diament"
	name_adjectives = list("diamentowy", "diamentowa", "diamentowe")

/datum/material/uranium
	polish_name = "uran"
	name_adjectives = list("uranowy", "uranowa", "uranowe")

/datum/material/plasma
	polish_name = "plazma"
	name_adjectives = list("plazmowy", "plazmowa", "plazmowe")

/datum/material/bluespace
	polish_name = "kryształ bluespace"
	name_suffix = "bluespace"

/datum/material/bananium
	polish_name = "bananium"
	name_adjectives = list("bananiumowy", "bananiumowa", "bananiumowe")

/datum/material/titanium
	polish_name = "tytan"
	name_adjectives = list("tytanowy", "tytanowa", "tytanowe")

/datum/material/plastic
	polish_name = "plastik"
	name_adjectives = list("plastikowy", "plastikowa", "plastikowe")

/datum/material/biomass
	polish_name = "biomasa"
	name_adjectives = list("organiczny", "organiczna", "organiczne")

/datum/material/adamantine
	polish_name = "adamantyt"
	name_adjectives = list("adamantytowy", "adamantytowa", "adamantytowe")

/datum/material/copper
	polish_name = "miedź"
	name_adjectives = list("miedziany", "miedziana", "miedziane")

/datum/material/rock
	polish_name = "kamień"
	name_adjectives = list("kamienny", "kamienna", "kamienne")

/datum/material/wood
	polish_name = "drewno"
	name_adjectives = list("drewniany", "drewniana", "drewniane")

/datum/material/meat
	polish_name = "mięso"
	name_adjectives = list("mięsny", "mięsna", "mięsne")
