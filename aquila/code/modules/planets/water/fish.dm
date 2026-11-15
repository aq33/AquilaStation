// AQUILA - ryby do łowienia. Złowiona ryba to zwykła ryba akwariowa Bee (/obj/item/fish z generate_fish i zachowaniem
// /datum/aquarium_behaviour/fish), więc pasuje do istniejących akwariów, a w maszynie do mięsa daje filet. Doszło:
// dane do minigry (trudność, sposób poruszania się, ikona w minigrze) i krojenie nożem na filety. Nowe gatunki z tg
// (code/modules/fishing/fish/types/*.dm, ikony icons/obj/aquarium/fish.dmi, CC BY-SA 3.0), bez cech, ewolucji
// i hodowli z nowego tg.

/datum/aquarium_behaviour/fish
	/// Dodatek do trudności minigry
	var/fishing_difficulty_modifier = 0
	/// Jak ryba porusza się w minigrze
	var/fish_movement_type = /datum/fish_movement
	/// Stan ikony ryby w minigrze (aquila/icons/planets/water/fishing_hud.dmi)
	var/fishing_hud_icon = "fish"

/obj/item/fish/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/fishmeat, 2, 3 SECONDS, FALSE, "Wyfiletuj")

// Trudności i ruchy dla gatunków Bee, które da się złowić (wartości z tg)
/datum/aquarium_behaviour/fish/greenchromis
	fishing_difficulty_modifier = 5

/datum/aquarium_behaviour/fish/firefish
	fish_movement_type = /datum/fish_movement/zippy

/datum/aquarium_behaviour/fish/pufferfish
	fishing_hud_icon = "chunky"

/datum/aquarium_behaviour/fish/gunner_jellyfish
	fishing_hud_icon = "jellyfish"
	fish_movement_type = /datum/fish_movement/slow

/datum/aquarium_behaviour/fish/needlefish
	fish_movement_type = /datum/fish_movement/zippy

/datum/aquarium_behaviour/fish/armorfish
	fishing_difficulty_modifier = 5
	fish_movement_type = /datum/fish_movement/slow

/datum/aquarium_behaviour/fish/catfish
	fishing_difficulty_modifier = 5

// Nowe gatunki z tg (ikony w aquila/icons/planets/water/fish.dmi)

/datum/aquarium_behaviour/fish/planet
	icon = 'aquila/icons/planets/water/fish.dmi'
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	sprite_width = 8
	sprite_height = 5
	stable_population = 3
	availible_in_random_cases = FALSE

/datum/aquarium_behaviour/fish/planet/perch
	name = "okoń"
	desc = "Pospolita ryba słodkowodna w paski. Łatwo ją złowić i dobrze smakuje."
	icon_state = "perch"
	aquarium_vc_color = "#9D8C64"

/datum/aquarium_behaviour/fish/planet/arctic_char
	name = "golec arktyczny"
	desc = "Ryba zimnych wód, spokrewniona z łososiem. Znosi temperatury, w których inne ryby zamarzają."
	icon_state = "arctic_char"
	aquarium_vc_color = "#C27C55"

/datum/aquarium_behaviour/fish/planet/sockeye
	name = "nerka"
	desc = "Czerwony łosoś, który całe życie wraca do miejsca, w którym się wykluł."
	icon_state = "sockeye"
	aquarium_vc_color = "#B4403C"
	fishing_difficulty_modifier = 5

/datum/aquarium_behaviour/fish/planet/plaice
	name = "gładzica"
	desc = "Płaska ryba denna. Leży na dnie i udaje piasek."
	icon_state = "plaice"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	aquarium_vc_color = "#B89A6C"
	fish_movement_type = /datum/fish_movement/slow

/datum/aquarium_behaviour/fish/planet/stingray
	name = "płaszczka"
	desc = "Płaska ryba z kolcem jadowym na ogonie. Lepiej nie nadepnąć."
	icon_state = "stingray"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	aquarium_vc_color = "#6F6E89"
	fishing_difficulty_modifier = 10

/datum/aquarium_behaviour/fish/planet/squid
	name = "kałamarnica"
	desc = "Głowonóg z dziesięcioma ramionami. Przy zagrożeniu wypuszcza chmurę atramentu."
	icon_state = "squid"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	aquarium_vc_color = "#C9A0C4"
	fishing_difficulty_modifier = 5
	fish_movement_type = /datum/fish_movement/zippy

/datum/aquarium_behaviour/fish/planet/monkfish
	name = "żabnica"
	desc = "Brzydka ryba głębinowa z wielką paszczą. Mięso ma za to wyśmienite."
	icon_state = "monkfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	aquarium_vc_color = "#7D6B55"
	fishing_difficulty_modifier = 10
	fishing_hud_icon = "chunky"

/datum/aquarium_behaviour/fish/planet/crab
	name = "krab"
	desc = "Skorupiak chodzący bokiem. Szczypce ma mocniejsze, niż wygląda."
	icon_state = "crab"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	aquarium_vc_color = "#C4543A"
	fishing_hud_icon = "crab"
	fish_movement_type = /datum/fish_movement/slow

/datum/aquarium_behaviour/fish/planet/lavaloop
	name = "pętlica lawowa"
	desc = "Ryba, która żyje w lawie i ma krew gorętszą od niej. Złowić ją może tylko wędka z żyłką odporną na żar."
	icon_state = "lava_loop"
	aquarium_vc_color = "#E2611C"
	required_temperature_min = 400
	required_temperature_max = 2000
	fishing_difficulty_modifier = 10
	fish_movement_type = /datum/fish_movement/zippy
