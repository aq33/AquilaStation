/datum/design/component/list
	category = list(WIREMOD_CIRCUITRY, WIREMOD_LIST_COMPONENTS)

/datum/design/component/list/format
	name = "Komponent: formatowanie listy"
	id = "comp_format"
	build_path = /obj/item/circuit_component/format

/datum/design/component/list/format_assoc
	name = "Komponent: formatowanie listy asocjacyjnej"
	id = "comp_format_assoc"
	build_path = /obj/item/circuit_component/format/assoc

/datum/design/component/list/index
	name = "Komponent: indeks listy"
	id = "comp_index"
	build_path = /obj/item/circuit_component/index

/datum/design/component/list/index_assoc
	name = "Komponent: indeks listy asocjacyjnej"
	id = "comp_index_assoc"
	build_path = /obj/item/circuit_component/index/assoc_string

/datum/design/component/list/index_table
	name = "Komponent: indeks tabeli"
	id = "comp_index_table"
	build_path = /obj/item/circuit_component/index_table

/datum/design/component/list/get_column
	name = "Komponent: pobierz kolumnę"
	id = "comp_get_column"
	build_path = /obj/item/circuit_component/get_column

/datum/design/component/list/select_query
	name = "Komponent: zapytanie SELECT"
	id = "comp_select_query"
	build_path = /obj/item/circuit_component/select

/datum/design/component/list/concat
	name = "Komponent: konkatenacja listy"
	id = "comp_concat_list"
	build_path = /obj/item/circuit_component/concat_list

/datum/design/component/list/add
	name = "Komponent: dodawanie do listy"
	id = "comp_append"
	build_path = /obj/item/circuit_component/variable/list/listadd

/datum/design/component/list/remove
	name = "Komponent: usuwanie z listy"
	id = "comp_remove"
	build_path = /obj/item/circuit_component/variable/list/listremove

/datum/design/component/list/assoc_list_set
	name = "Komponent: zapis do listy asocjacyjnej"
	id = "comp_assoc_list_set"
	build_path = /obj/item/circuit_component/variable/assoc_list/list_set

/datum/design/component/list/assoc_list_remove
	name = "Komponent: usuwanie z listy asocjacyjnej"
	id = "comp_assoc_list_remove"
	build_path = /obj/item/circuit_component/variable/assoc_list/list_remove

/datum/design/component/list/clear
	name = "Komponent: czyszczenie listy"
	id = "comp_clear"
	build_path = /obj/item/circuit_component/variable/list/listclear

/datum/design/component/list/find
	name = "Komponent: wyszukiwanie elementu"
	id = "comp_find"
	build_path = /obj/item/circuit_component/listin

/datum/design/component/list/literal
	name = "Komponent: literał listy"
	id = "comp_list_constructor"
	build_path = /obj/item/circuit_component/list_literal

/datum/design/component/list/assoc_literal
	name = "Komponent: literał listy asocjacyjnej"
	id = "comp_assoc_literal"
	build_path = /obj/item/circuit_component/assoc_literal

/datum/design/component/list/filter
	name = "Komponent: filtrowanie listy"
	id = "comp_filter"
	build_path = /obj/item/circuit_component/filter_list

/datum/design/component/list/pick
	name = "Komponent: wybór z listy"
	id = "comp_pick"
	build_path = /obj/item/circuit_component/list_pick

/datum/design/component/list/pick_assoc
	name = "Komponent: wybór z listy asocjacyjnej"
	id = "comp_pick_assoc"
	build_path = /obj/item/circuit_component/list_pick/assoc

/datum/design/component/list/foreach
	name = "Komponent: dla każdego"
	id = "comp_foreach"
	build_path = /obj/item/circuit_component/foreach

/datum/design/component/list/split
	name = "Komponent: podział tekstu"
	id = "comp_split"
	build_path = /obj/item/circuit_component/split
