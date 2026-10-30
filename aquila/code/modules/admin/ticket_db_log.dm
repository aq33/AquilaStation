// Zapis ticketów (ahelpów) do bazy, tabela ticket (SQL/database_changelog.txt, wersja 6.7). Czyta to historia ticketów gracza.
// Core miał LogAhelp() zakomentowane i bez wywołań; tu jest wersja z tg z wywołaniami w tych samych miejscach.

/// Czy tabela ticketów istnieje (sprawdzane raz na rundę)
GLOBAL_VAR_INIT(ticket_table_ready, FALSE)

/// Tworzy tabelę ticketów, jeśli jej nie ma (schemat jest też w SQL/beestation_schema.sql)
/proc/ticket_db_ready()
	if(!SSdbcore.Connect())
		return FALSE
	if(GLOB.ticket_table_ready)
		return TRUE
	var/datum/DBQuery/query_create = SSdbcore.NewQuery({"
		CREATE TABLE IF NOT EXISTS [format_table_name("ticket")] (
			`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
			`server_ip` INT(10) UNSIGNED NOT NULL,
			`server_port` SMALLINT(5) UNSIGNED NOT NULL,
			`round_id` INT(11) UNSIGNED NULL,
			`ticket` SMALLINT(11) UNSIGNED NOT NULL,
			`action` VARCHAR(20) NOT NULL DEFAULT 'Message',
			`message` TEXT NOT NULL,
			`timestamp` DATETIME NOT NULL,
			`recipient` VARCHAR(32) DEFAULT NULL,
			`sender` VARCHAR(32) DEFAULT NULL,
			PRIMARY KEY (`id`),
			KEY `idx_ticket_act_recip` (`action`, `recipient`),
			KEY `idx_ticket_act_send` (`action`, `sender`),
			KEY `idx_ticket_tic_rid` (`ticket`, `round_id`),
			KEY `idx_ticket_act_time_rid` (`action`, `timestamp`, `round_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
	"})
	GLOB.ticket_table_ready = query_create.Execute()
	qdel(query_create)
	return GLOB.ticket_table_ready

/// Zapisuje jedną akcję na tickecie w bazie
/datum/controller/subsystem/blackbox/proc/LogAhelp(ticket, action, message, recipient, sender)
	set waitfor = FALSE
	if(!ticket_db_ready())
		return
	var/datum/DBQuery/query_log_ahelp = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("ticket")] (ticket, action, message, recipient, sender, server_ip, server_port, round_id, timestamp)
		VALUES (:ticket, :action, :message, :recipient, :sender, INET_ATON(:server_ip), :server_port, :round_id, :time)
	"}, list(
		"ticket" = ticket,
		"action" = action,
		"message" = message,
		"recipient" = recipient,
		"sender" = sender,
		"server_ip" = world.internet_address || "0",
		"server_port" = world.port,
		"round_id" = GLOB.round_id,
		"time" = SQLtime(),
	))
	query_log_ahelp.warn_execute()
	qdel(query_log_ahelp)

/datum/admin_help
	/// Czy pierwsza wiadomość gracza poszła już do bazy jako "Ticket Opened"
	var/db_logged_open = FALSE

// Wiadomości gracza w tickecie (pierwsza otwiera ticket)
/datum/admin_help/MessageNoRecipient(msg)
	. = ..()
	SSblackbox.LogAhelp(id, db_logged_open ? "Interaction" : "Ticket Opened", msg, null, initiator_ckey)
	db_logged_open = TRUE

/datum/admin_help/Reopen()
	var/old_state = state
	. = ..()
	if(state != old_state)
		SSblackbox.LogAhelp(id, "Reopened", "Reopened by [usr?.key]", initiator_ckey, usr?.ckey)

// Ciche zamknięcie i rozwiązanie wołają Reject, MHelpThis i ICIssue, które zapisują własną akcję
/datum/admin_help/Close(key_name = key_name_admin(usr), silent = FALSE)
	var/old_state = state
	. = ..()
	if(!silent && state != old_state)
		SSblackbox.LogAhelp(id, "Closed", "Closed by [usr?.key]", initiator_ckey, usr?.ckey)

/datum/admin_help/Resolve(key_name = key_name_admin(usr), silent = FALSE)
	var/old_state = state
	. = ..()
	if(!silent && state != old_state)
		SSblackbox.LogAhelp(id, "Resolved", "Resolved by [usr?.key]", initiator_ckey, usr?.ckey)

/datum/admin_help/Reject(key_name = key_name_admin(usr))
	var/old_state = state
	. = ..()
	if(state != old_state)
		SSblackbox.LogAhelp(id, "Rejected", "Rejected by [usr?.key]", initiator_ckey, usr?.ckey)

/datum/admin_help/ICIssue(key_name = key_name_admin(usr))
	var/old_state = state
	. = ..()
	if(state != old_state)
		SSblackbox.LogAhelp(id, "IC Issue", "Marked as IC issue by [usr?.key]", initiator_ckey, usr?.ckey)

/datum/admin_help/MHelpThis(key_name = key_name_admin(usr))
	var/old_state = state
	. = ..()
	if(state != old_state)
		SSblackbox.LogAhelp(id, "Mentorhelp", "Moved to mentorhelp by [usr?.key]", initiator_ckey, usr?.ckey)

/// Admin PM w tickecie (odpowiedź admina albo gracza), wołane z cmd_admin_pm()
/client/proc/log_ahelp_pm(client/recipient, message)
	var/datum/admin_help/ticket = recipient?.current_ticket || current_ticket
	if(!ticket)
		return
	SSblackbox.LogAhelp(ticket.id, "Reply", message, recipient.ckey, ckey)
