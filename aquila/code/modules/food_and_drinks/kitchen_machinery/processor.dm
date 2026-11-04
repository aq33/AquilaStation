// Malakser jak mielarka (aquila/code/modules/reagents/chemistry/machinery/reagentgrinder.dm): przy pracy zostaje
// nowy sprite z resprite'u, bo stary "processor1_animated" z NSV13 do niego nie pasuje. Pracę widać po trzęsieniu.
/obj/machinery/processor/update_icon()
	. = ..()
	icon_state = "processor1"
