extends Control

@onready var container_verticale = $VBoxContainer
var layoutAttuale: String = "base" 
const SOCKET_PATH = "/tmp/vtk.sock"
var separatore: float = 5.0

var socket = StreamPeerTCP.new()
var connesso = false
var sensibility:int = 1
var isDoubleTap:bool = true
var isTouchabs:bool = false
# Arguments
var canVertical:bool = false
var appID:String = ""

var mouse_inizializzato : bool = false

# Serve ad Intercettare i tasti del controller
var bg_reader: BackgroundInputReader

# CLOCK
var label_orario: Label

func _process(delta: float) -> void:
		pass

func _ready():
	# Recupera tutti gli argomenti personalizzati passati da riga di comando
	var argomenti: PackedStringArray = OS.get_cmdline_args()
	if argomenti.has("canVertical"):
		self.canVertical = true
	if argomenti.has("appID"):
		for i in range(argomenti.size()):
			if argomenti[i] == "appID" and i + 1 < argomenti.size():
				appID = argomenti[i + 1]
				break
	
	KeyboardHelper.hideMouseCursor()
	# 1. Spegne il server audio (se l'app non deve emettere suoni)
	# Il server audio di Linux consuma CPU fissa ad ogni frame per mixare i canali vuoti
	AudioServer.set_bus_mute(0, true)
	# 2. Riduciamo il polling degli input di sistema a 30Hz
	# Di default Godot interroga l'hardware di Rocknix alla massima velocità possibile
	Input.set_use_accumulated_input(true)
	
	#questo offset è un pò casuale e si basa sull'Anbernic RG DS
	container_verticale.offset_left = 5
	container_verticale.offset_right = -5
	container_verticale.offset_bottom = -5
	
	# Lanciamo la connessione all'avvio
	var err = socket.connect_to_host("127.0.0.1", 65432)
	if err != OK:
		print("Errore configurazione iniziale TCP: ", err)
	
	container_verticale.add_theme_constant_override("separation", separatore)
	
	#self.drawKeyboard()
	self.drawClock()
	
	#Istanzio il lettore passando 'self' (questo script riceverà i dati)
	bg_reader = BackgroundInputReader.new(self)

func _exit_tree():
	if bg_reader:
		bg_reader.set_listening(false)

func _input(event: InputEvent) -> void:
	# Se l'input proviene dal mouse (clic o movimento)
	if OS.get_name() == "macOS":
		# Se sono su mac permetto l0input
		return
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		### Blocca l'evento immediatamente: non arriverà mai ai pulsanti sotto
		if isTouchabs == false:
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and not mouse_inizializzato:
		if checkIfMouseIsInWindow():
			moveMouseInWindow()
		

func _notification(what: int) -> void:
	# Controlla anche se il mouse "entra" o "esce" dalla finestra di gioco
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		mouse_inizializzato = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		# Se l'utente riesce a portare il mouse fuori, lo riportiamo al centro
		moveMouseInWindow()

func checkIfMouseIsInWindow() -> bool:
	var dimensione_finestra = DisplayServer.window_get_size()
	var pos_mouse = get_viewport().get_mouse_position()
	if pos_mouse.x < 0 or pos_mouse.y < 0 or pos_mouse.x > dimensione_finestra.x or pos_mouse.y > dimensione_finestra.y:
		return false
	else:
		mouse_inizializzato = true
		return true
		
func moveMouseInWindow():
	# sposta il cursore del mouse di sistema nel mezzo della finestra dell'app con lo scopo di non far apparire 2 cursori del mouse
	if isTouchabs == false and OS.get_name() != "macOS":
		var centro = DisplayServer.window_get_size() / 2
		get_viewport().warp_mouse(centro)
		Input.warp_mouse(centro)
	mouse_inizializzato = true

func cleanKeyboard():
	for figlio in container_verticale.get_children():
		figlio.queue_free()
func drawKeyboard():
	# Otteniamo la larghezza reale dello schermo (es. 640)
	var wSize = get_viewport().get_visible_rect().size.x
	# LA TUA FORMULA: Calcoliamo la larghezza esatta in pixel di un tasto standard di riferimento (10 colonne totali)
	var hb: float = ((wSize - (11 * separatore)) / 10)
	
	var layout = KeyboardHelper.layouts[layoutAttuale]
	
	for riga in layout:
		var hbox_riga = HBoxContainer.new()
		hbox_riga.add_theme_constant_override("separation", separatore)
		# Disattiviamo l'espansione automatica di HBox: comandiamo noi con i pixel esatti
		hbox_riga.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		
		for tasto in riga:
			if(tasto.code == "TOUCHPAD"):
				hbox_riga.add_child(KeyboardHelper.getTouchPad(tasto, size, hb, separatore))
			elif (tasto.code == "TOUCHABS"):
				hbox_riga.add_child(KeyboardHelper.getTouchABS(tasto, size, hb, separatore))
			else:
				if(layoutAttuale == "touchabs"):
					var buttPanel = Panel.new()
					var altezza_touchpad = size.y - 10
					buttPanel.custom_minimum_size = Vector2(62, altezza_touchpad)
					
					var pos:int = 0
					for t in KeyboardHelper.getButtonsForPanel():
						var tb = KeyboardHelper.createButtonFromPanel(t, hb, separatore, sensibility, layoutAttuale, pos)
						tb.pressed.connect(_on_tasto_premuto.bind(t, tb))
						buttPanel.add_child(tb)
						pos += 1
					
					hbox_riga.add_child(buttPanel)
				else:
					var butt = KeyboardHelper.createButton(tasto, hb, separatore, sensibility, layoutAttuale, isDoubleTap)
					butt.pressed.connect(_on_tasto_premuto.bind(tasto, butt))
					hbox_riga.add_child(butt)
		container_verticale.add_child(hbox_riga)
		
func _on_tasto_premuto(tasto: KeyboardHelper.Tasto, button:Button):
	if tasto.code == "KEY 1001":
		print("Hai premuto T/K")
		if layoutAttuale == "base" or layoutAttuale == "baseShift":
			if isTouchabs == false:
				layoutAttuale = "touchpad"
			else:
				self.changeTouchScreenMap(true)
				layoutAttuale = "touchabs"
			self.cleanKeyboard()	
			self.drawKeyboard()
		else:
			if layoutAttuale == "touchabs":
				self.changeTouchScreenMap(false)
			layoutAttuale = "base"
			self.cleanKeyboard()
			self.drawKeyboard()
	elif tasto.code == "KEY 1002":
		print("Hai premuto SHIFT")
		if layoutAttuale == "base":
			layoutAttuale = "baseShift"
			self.cleanKeyboard()
			self.drawKeyboard()
		else:
			layoutAttuale = "base"
			self.cleanKeyboard()
			self.drawKeyboard()
	elif tasto.code == "KEY 1003":
		if button.text == "S1":
			button.text = "S2"
			sensibility = 2
		elif button.text == "S2":
			button.text = "S3"
			sensibility = 3
		elif button.text == "S3":
			button.text = "S1"
			sensibility = 1
	elif tasto.code == "TAP":
		if isDoubleTap == true:
			isDoubleTap = false
			button.text = "ST"
		else:
			isDoubleTap = true
			button.text = "DT"
	elif tasto.code == "KEY 1004":
		layoutAttuale = "touchabs"
		self.isTouchabs = true
		self.changeTouchScreenMap(true)
		self.cleanKeyboard()
		self.drawKeyboard()
	elif tasto.code == "KEY 1006":
		if layoutAttuale == "touchabs":
			self.changeTouchScreenMap(false)
		layoutAttuale = "touchpad"
		self.isTouchabs = false
		self.cleanKeyboard()
		self.drawKeyboard()
	elif tasto.code == "HOME":
		layoutAttuale = "base"
		self.cleanKeyboard()
		self.drawClock()
	else:
		invia_comando(tasto.code)
func _on_mouse_mosso(x: int, y:int):
	invia_comando("MOUSE " + str(x) + " " +str(y))
	
func _gui_input(event: InputEvent) -> void:
	if(layoutAttuale == "touchabs"):
		# var wSize = get_viewport().get_visible_rect().size.x
		# 1. Definiamo dove inizia la striscia a destra (es: se lo schermo è largo 640, parte da 580)
		var limite_striscia_destra = (size.y / 10) + 10
		# 2. Intercettiamo solo il tocco iniziale (Touch)
		if event is InputEventMouseButton:
			# Se il dito si trova dentro la striscia verticale a sinistra
			if event.global_position.x <= limite_striscia_destra:
				var coordinata_virtuale = Vector2(event.global_position.x + size.x - limite_striscia_destra, event.global_position.y)
				for col in container_verticale.get_children():
					for panel in col.get_children():
						for bottone in panel.get_children():
							if bottone is Button:
								print(bottone)
								if bottone.get_global_rect().has_point(coordinata_virtuale):
									print("BOTTONE TROVATO")
									if event.pressed == true:
										bottone.add_theme_stylebox_override("normal", bottone.get_theme_stylebox("pressed"))
									else:
										bottone.add_theme_stylebox_override("normal", bottone.get_theme_stylebox("hover"))
										bottone.pressed.emit()
				
	
func invia_comando(messaggio: String) -> void:
	if OS.get_name() == "macOS":
		print("Inviato comando:",messaggio)
		return
	# Aggiorna lo stato reale del socket nel frame attuale (fondamentale in Godot 4)
	socket.poll()
	
	var stato = socket.get_status()
	
	if stato == StreamPeerTCP.STATUS_CONNECTED:
		# Se è la prima volta che ci troviamo connessi, attiviamo il no_delay in sicurezza
		if not connesso:
			socket.set_no_delay(true)
			connesso = true
			
		# Inviamo il comando con l'andata a capo (\n) per il ciclo del demone
		var comando_finito = messaggio + "\n"
		socket.put_data(comando_finito.to_utf8_buffer())
		
	elif stato == StreamPeerTCP.STATUS_NONE or stato == StreamPeerTCP.STATUS_ERROR:
		# Se ha perso la linea o è in errore, resetta lo stato e ritenta l'aggancio
		connesso = false
		socket.connect_to_host("127.0.0.1", 65432)

func changeTouchScreenMap(forABS:bool, isAsync:bool = false):
	print("abilito mappatura touchscreen per ABS:", forABS)
	if OS.get_name() == "macOS":
		return
	var percorso_script = "/storage/.config/VTK/changeDisplayCalibrationMatrix.sh"
	var argomenti = []
	if forABS:
		argomenti.append("ABS")
	OS.execute(percorso_script, argomenti, [], isAsync)
	KeyboardHelper.hideMouseCursor()
	
func drawClock():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label_orario = Label.new()
	add_child(label_orario)
	label_orario.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label_orario.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label_orario.grow_vertical = Control.GROW_DIRECTION_BOTH
	label_orario.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.5))
	
	label_orario.add_theme_font_size_override("font_size", 100) 
	_aggiorna_orario()
	
	# 4. Crea un Timer software per gestire l'aggiornamento ogni secondo
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	add_child(timer)
	
	# Connette il timeout del timer alla funzione di aggiornamento
	timer.timeout.connect(_aggiorna_orario)
	drawButtonsClock()
func drawButtonsClock():
	var contenitore_bottoni = HBoxContainer.new()
	add_child(contenitore_bottoni)
	contenitore_bottoni.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	contenitore_bottoni.grow_horizontal = Control.GROW_DIRECTION_BOTH
	contenitore_bottoni.grow_vertical = Control.GROW_DIRECTION_BOTH

	contenitore_bottoni.position.y -= 100

	contenitore_bottoni.add_theme_constant_override("separation", 20)
	
	var imgArrows = "arrowsOff.png";
	if bg_reader != null && bg_reader.is_listening == true:
		imgArrows = "arrowsOn.png";
		

	var icons = [["keyboard.png", Color(1.0, 1.0, 1.0, 0.7), 50, "keyb"],
				["touch.png", Color(1.0, 1.0, 1.0, 0.7), 50, "touch"],
				["tate.png", Color(1.0, 1.0, 1.0, 0.7), 50, "tate"],
				[imgArrows, Color(1.0, 1.0, 1.0, 0.7), 50, "arrows"],
				["power.png", Color(0.623, 0.075, 0.059, 0.9), 50, "power"]]

	var index = 0
	for i in range(5):
		var bottone = self.getButtonHome(icons[i])
		if(index == 2):
			if self.canVertical == false or appID == "":
				bottone.disabled = true
		
		# Aggiunge il bottone al contenitore
		contenitore_bottoni.add_child(bottone)
		index += 1
func getButtonHome(icons:Array) -> Button:
	var bottone = Button.new()
	#bottone.text = "B" + str(i + 1)
	bottone.custom_minimum_size = Vector2(80, 80)
	var stile_trasparente = StyleBoxEmpty.new()
	bottone.add_theme_stylebox_override("normal", stile_trasparente)
	bottone.add_theme_stylebox_override("hover", stile_trasparente)
	bottone.add_theme_stylebox_override("disabled", stile_trasparente)
	
	var texture_icona = load("res://" + icons[0])
	bottone.add_theme_constant_override("icon_max_width", icons[2])
	bottone.add_theme_color_override("icon_hover_color", icons[1])
	bottone.add_theme_color_override("icon_disabled_color", Color(1.0, 1.0, 1.0, 0.2))
	bottone.add_theme_color_override("icon_normal_color", icons[1])
	bottone.icon_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	bottone.pressed.connect(_on_bottone_premuto.bind(icons[3], bottone))
	bottone.icon = texture_icona
	bottone.material = CanvasItemMaterial.new()
		
	var stile_arrotondato = StyleBoxFlat.new()
	stile_arrotondato.bg_color = Color(1.0, 1.0, 1.0, 0.1)
	stile_arrotondato.set_corner_radius_all(15)
	bottone.add_theme_stylebox_override("pressed", stile_arrotondato)
	return bottone

func drawButtonTate():
	var contenitore_bottoni = HBoxContainer.new()
	add_child(contenitore_bottoni)
	contenitore_bottoni.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	contenitore_bottoni.grow_horizontal = Control.GROW_DIRECTION_BOTH
	contenitore_bottoni.grow_vertical = Control.GROW_DIRECTION_BOTH
	contenitore_bottoni.position.y -= 35
	contenitore_bottoni.add_theme_constant_override("separation", 20)
	
	var icons = [["tate.png", Color(1.0, 1.0, 1.0, 0.6), 50, "notate"],
				["power.png", Color(0.623, 0.075, 0.059, 0.8), 50, "powertate"]]
	for i in range(2):
		var bottone = self.getButtonHome(icons[i])
		bottone.custom_minimum_size = Vector2(60, 60)
		# Aggiunge il bottone al contenitore
		contenitore_bottoni.add_child(bottone)
	
func _on_bottone_premuto(key: String, button:Button) -> void:
	if key == "keyb":
		layoutAttuale = "base"
		self.cleanClockPage()
		self.drawKeyboard()
	elif key == "touch":
		layoutAttuale = "touchpad"
		self.cleanClockPage()
		self.drawKeyboard()
	elif key == "tate":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(640, 80))
		DisplayServer.window_set_position(Vector2i(0, 320))

		if OS.get_name() != "macOS":
			OS.execute("sh", ["-c", "swaymsg '[app_id=\"{id}\"] output DSI-2 pos 0 0, output DSI-1 pos 0 480'".format({"id": appID})])
			OS.execute("sh", ["-c", "swaymsg '[app_id=\"{id}\"] floating enable, fullscreen disable, resize set 640 890, move to output DSI-2, move absolute position 0 0'".format({"id": appID})])
			OS.execute("sh", ["-c", "swaymsg 'input \"1046:911:Goodix_Capacitive_TouchScreen\" calibration_matrix 1 0 0 0 0.5 0.5'"])
			
		self.cleanClockPage()
		self.drawButtonTate()
	elif key == "notate":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(640, 480))
		#DisplayServer.window_set_position(Vector2i(640, 0))
		
		if OS.get_name() != "macOS":
			#OS.execute("sh", ["-c", "swaymsg '[app_id=\"{id}\"] output DSI-2 pos 0 0, output DSI-1 pos 640 0'".format({"id": appID})])
			OS.execute("sh", ["-c", "swaymsg '[app_id=\"{id}\"] floating disable, fullscreen enable, resize set 640 480, move to output DSI-2'".format({"id": appID})])
			OS.execute("sh", ["-c", "swaymsg '[app_id=\"VTK\"] floating disable, fullscreen enable'"])
		
		layoutAttuale = "base"
		self.cleanClockPage()
		self.drawClock()
		self.changeTouchScreenMap.call_deferred(false, true)
	elif key == "power":
		if OS.get_name() != "macOS":
			OS.execute("sh", ["-c", "swaymsg 'output DSI-1 power off' >/dev/null 2>&1"])
		get_tree().quit()
	elif key == "powertate":
		get_tree().quit()
	elif key == "arrows":
		if bg_reader.is_listening == true:
			bg_reader.set_listening(false)
			var texture_icona = load("res://arrowsOff.png")
			button.icon = texture_icona
		else:
			bg_reader.set_listening(true)
			var texture_icona = load("res://arrowsOn.png")
			button.icon = texture_icona
func cleanClockPage():
	for figlio in get_children():
		if figlio != container_verticale:
			figlio.queue_free()
			
func _aggiorna_orario() -> void:
	var tempo = Time.get_time_dict_from_system()
	label_orario.text = "%02d:%02d" % [tempo.hour, tempo.minute]
	
# --- FUNZIONI DI RICEZIONE DEGLI INPUT ---
# Il thread invierà automaticamente i dati qui sotto, anche se l'app è in background

func _on_bg_button_event(code: int, value: int):
	# value = 1 (Premuto), value = 0 (Rilasciato)
	# asse 16 = Orizzontale (Sinistra / Destra)
	match code:
		544: # BTN_DPAD_UP fisico
			invia_comando("KEY 103 " + str(value))
		545: # BTN_DPAD_DOWN fisico
			invia_comando("KEY 108 " + str(value))
		546: # BTN_DPAD_LEFT fisico
			invia_comando("KEY 105 " + str(value))
		547: # BTN_DPAD_RIGHT fisico
			invia_comando("KEY 106 " + str(value))
	
	if value == 1:
		print("BACKGROUND - Tasto Hardware Premuto. Codice OS Linux: ", code)
		# Inserisci qui le tue azioni di gioco (es: if code == 304: fai_qualcosa())
	elif value == 0:
		print("BACKGROUND - Tasto Hardware Rilasciato. Codice OS Linux: ", code)

func _on_bg_axis_event(code: int, value: int):
	# Gestisce il movimento delle levette analogiche e del D-Pad
	print("BACKGROUND - Asse mosso: ", code, " Valore: ", value)
