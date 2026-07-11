class_name BackgroundInputReader
extends RefCounted

const EVENT_PATH = "/dev/input/event7"
const EVENT_SIZE = 24 

var input_thread: Thread
var is_running_thread: bool = false
var is_listening: bool = false
var target_node: Node

# Variabili per gestire il processo OS nativo
var process_info: Dictionary = {}
var pipe_stream: FileAccess = null
var cat_pid: int = -1

func _init(node: Node):
	target_node = node

func set_listening(enabled: bool):
	if enabled == is_listening:
		return
		
	is_listening = enabled
	
	if is_listening:
		_start_thread()
	else:
		_stop_thread()

func _start_thread():
	if is_running_thread: return
	
	ProjectSettings.set_setting("application/run/low_processor_mode", false)
	
	# Usiamo execute_with_pipe: lancia il comando Linux e ci passa lo stream sicuro in Godot
	# 'stdbuf -o0' serve a disattivare il caching di Linux per avere i tasti in tempo reale (zero lag)
	process_info = OS.execute_with_pipe("sh", ["-c", "stdbuf -o0 cat " + EVENT_PATH])
	
	if process_info.is_empty() or not process_info.has("stdio"):
		var err_log = FileAccess.open("user://log_tastiera.txt", FileAccess.WRITE)
		err_log.store_line("[ERRORE OS] Fallito il tunneling nativo di event tramite execute_with_pipe")
		err_log.flush()
		return
		
	pipe_stream = process_info["stdio"] # Questa è la pipe interna nativa accettata da Godot
	cat_pid = process_info["pid"]       # Il PID del comando per poterlo spegnere
	
	is_running_thread = true
	input_thread = Thread.new()
	input_thread.start(_listen_os_events)
	print("Ascolto background nativo: ATTIVATO (PID: ", cat_pid, ")")

func _stop_thread():
	if not is_running_thread: return
	
	is_running_thread = false
	
	# 1. Uccidiamo il processo Linux. Questo interrompe il flusso e sblocca la pipe
	if cat_pid > 0:
		OS.kill(cat_pid)
		cat_pid = -1
	
	# 2. Chiudiamo lo stream nativo
	if pipe_stream:
		pipe_stream = null
	
	# 3. Attendiamo la chiusura sicura del thread
	if input_thread and input_thread.is_started():
		input_thread.wait_to_finish()
		input_thread = null
		
	process_info.clear()
	print("Ascolto background nativo: DISATTIVATO COMPLETAMENTE")

func _listen_os_events():
	# Protezione nel caso in cui lo stream si sia corrotto durante l'avvio
	if not pipe_stream:
		is_running_thread = false
		return

	while is_running_thread:
		# Leggiamo i 24 byte direttamente dalla pipe di sistema interna di Godot.
		# Non usando FileAccess.open(), aggiriamo l'errore 12.
		var buffer = pipe_stream.get_buffer(EVENT_SIZE)
		
		if not is_running_thread:
			break
			
		if buffer.size() < EVENT_SIZE:
			OS.delay_msec(5)
			continue
			
		if not is_listening:
			continue
		
		var type  = buffer.decode_u16(16)
		var code  = buffer.decode_u16(18)
		var value = buffer.decode_s32(20)

		if type == 1: # EV_KEY
			target_node.call_deferred("_on_bg_button_event", code, value)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_stop_thread()
