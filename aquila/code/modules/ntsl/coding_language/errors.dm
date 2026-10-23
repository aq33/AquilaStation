/datum/scriptError
	///A message describing the problem.
	var/message

/datum/scriptError/New(msg)
	if(msg)
		message = msg

/datum/scriptError/BadToken
	message = "Nieoczekiwany token: "
	var/datum/token/token

/datum/scriptError/BadToken/New(datum/token/token)
	src.token = token

	if(token && token.line)
		message = "[token.line]: [message]"
	if(istype(token))
		message += "[token.value]"
	else
		message += "[token]"

/datum/scriptError/InvalidID
	parent_type = /datum/scriptError/BadToken
	message = "Niepoprawna nazwa identyfikatora: "

/datum/scriptError/ReservedWord
	parent_type = /datum/scriptError/BadToken
	message = "Identyfikator używa słowa zastrzeżonego: "

/datum/scriptError/BadNumber
	parent_type = /datum/scriptError/BadToken
	message = "Błędna liczba: "

/datum/scriptError/BadReturn
	message = "Nieoczekiwane return poza funkcją."
	var/datum/token/token

/datum/scriptError/BadReturn/New(datum/token/token)
	src.token = token

/datum/scriptError/EndOfFile
	message = "Nieoczekiwany koniec pliku."

/datum/scriptError/ExpectedToken
	message = "Oczekiwano: "

/datum/scriptError/ExpectedToken/New(id, datum/token/token)
	if(token)
		message = "[token.line ? token.line : "???"]: [message]'[id]'. Znaleziono '[token.value]'."
	else
		message = "???: [message]'[id]'. Brak tokenu!"

/datum/scriptError/UnterminatedComment
	message = "Niezamknięty komentarz wieloliniowy: oczekiwano */"

/datum/scriptError/DuplicateFunction

/datum/scriptError/DuplicateFunction/New(name, datum/token/token)
	message = "Funkcja '[name]' zdefiniowana dwa razy."

/datum/scriptError/ParameterFunction
	message = "Nie można definiować funkcji w parametrze."

/datum/scriptError/ParameterFunction/New(datum/token/token)
	var/line = "???"
	if(token)
		line = token.line
	message = "[line]: [message]"

/datum/scriptError/InvalidAssignment
	message = "Do lewej strony przypisania nie można nic przypisać."

/datum/scriptError/OutdatedScript
	message = "Skrypt wygląda na pisany pod starszą wersję NTSL (brak funkcji process_signal). Może nie działać, zajrzyj do przewodnika."

/*
 * Runtime Error
 * An error thrown by the interpreter in running the script.
 */
/datum/runtimeError
	var/name
	///A basic description as to what went wrong.
	var/message
	var/datum/scope/scope
	var/datum/token/token

///Returns a description of the error suitable for showing to the user.
/datum/runtimeError/proc/ToString()
	. = "[name]: [message]"
	if(!scope)
		return
	var/last_line
	var/last_col
	if(token)
		last_line = token.line
		last_col = token.column
	var/datum/scope/cur_scope = scope
	while(cur_scope)
		if(cur_scope.function)
			. += "\n\tat [cur_scope.function.func_name]([last_line]:[last_col])"
			if(cur_scope.call_node && cur_scope.call_node.token)
				last_line = cur_scope.call_node.token.line
				last_col = cur_scope.call_node.token.column
			else
				last_line = null
				last_col = null
		cur_scope = cur_scope.parent
	if(last_line)
		. += "\n\tat \[global]([last_line]:[last_col])"
	else
		. += "\n\tat \[internal]"

/datum/runtimeError/TypeMismatch
	name = "TypeMismatchError"

/datum/runtimeError/TypeMismatch/New(op, a, b)
	if(isnull(a))
		a = "NULL"
	if(isnull(b))
		b = "NULL"
	message = "Niezgodne typy: '[a]' [op] '[b]'"

/datum/runtimeError/UnexpectedReturn
	name = "UnexpectedReturnError"
	message = "Nieoczekiwane return."

/datum/runtimeError/UnknownInstruction
	name = "UnknownInstructionError"

/datum/runtimeError/UnknownInstruction/New(datum/node/op)
	message = "Nieznany typ instrukcji '[op.type]'."

/datum/runtimeError/UndefinedVariable
	name = "UndefinedVariableError"

/datum/runtimeError/UndefinedVariable/New(variable)
	message = "Zmienna '[variable]' nie została zadeklarowana."

/datum/runtimeError/IndexOutOfRange
	name = "IndexOutOfRangeError"

/datum/runtimeError/IndexOutOfRange/New(obj, idx)
	message = "Indeks [obj]\[[idx]] jest poza zakresem."

/datum/runtimeError/UndefinedFunction
	name = "UndefinedFunctionError"

/datum/runtimeError/UndefinedFunction/New(function)
	message = "Funkcja '[function]()' nie jest zdefiniowana."

/datum/runtimeError/DuplicateVariableDeclaration
	name = "DuplicateVariableError"

/datum/runtimeError/DuplicateVariableDeclaration/New(variable)
	message = "Zmienna '[variable]' została już zadeklarowana."

/datum/runtimeError/IterationLimitReached
	name = "MaxIterationError"
	message = "Pętla osiągnęła limit iteracji."

/datum/runtimeError/RecursionLimitReached
	name = "MaxRecursionError"
	message = "Osiągnięto limit rekurencji."

/datum/runtimeError/DivisionByZero
	name = "DivideByZeroError"
	message = "Dzielenie przez zero (albo przez NULL)."

/datum/runtimeError/InvalidAssignment
	message = "Do lewej strony przypisania nie można nic przypisać."

/datum/runtimeError/MaxCPU
	name = "MaxComputationalUse"

/datum/runtimeError/MaxCPU/New(maxcycles)
	message = "Osiągnięto limit instrukcji (>= [maxcycles])."

/datum/runtimeError/Internal
	name = "InternalError"

/datum/runtimeError/Internal/New(exception/exception_message)
	message = exception_message.name
