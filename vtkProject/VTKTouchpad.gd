# VTKTouchpad.gd
extends Panel

var interfaccia_principale: Node = null

var touch_attivo : bool = false
var touch_waiting_double_tap : bool = false
var mosso_durante_touch : bool = false
var tempo_inizio_touch : float = 0.0
const LIMITE_TEMPO_TAP : float = 0.3
var tap_timer : SceneTreeTimer = null

var accumulo_x : float = 0.0
var accumulo_y : float = 0.0

func _ready() -> void:
	
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	mouse_filter = MOUSE_FILTER_STOP 
	# Risale l'albero dei nodi per trovare lo script che ha la funzione invia_comando
	var nodo_attuale = get_parent()
	while nodo_attuale != null:
		if nodo_attuale.has_method("invia_comando"):
			interfaccia_principale = nodo_attuale
			break
		nodo_attuale = nodo_attuale.get_parent()
		
	if interfaccia_principale == null:
		print("Errore: Impossibile trovare il nodo principale con la funzione invia_comando!")

func sendTap():
	interfaccia_principale.invia_comando("CLICK")
	tap_timer = null
func sendDoubleTap():
	interfaccia_principale.invia_comando("DOUBLE_CLICK")

func _gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.is_pressed()) or (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		touch_attivo = true
		mosso_durante_touch = false
		tempo_inizio_touch = Time.get_ticks_msec() / 1000.0
		
		accumulo_x = 0.0
		accumulo_y = 0.0
		
	elif (event is InputEventScreenTouch and not event.is_pressed()) or (event is InputEventMouseButton and not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		if touch_attivo:
			touch_attivo = false
			var durata_touch = (Time.get_ticks_msec() / 1000.0) - tempo_inizio_touch
			
			if not mosso_durante_touch and durata_touch <= LIMITE_TEMPO_TAP:
				if interfaccia_principale.isDoubleTap == true :
					if tap_timer == null:
						# interfaccia_principale.invia_comando("CLICK")
						tap_timer = Engine.get_main_loop().create_timer(LIMITE_TEMPO_TAP)
						tap_timer.timeout.connect(sendTap)
					else:
						tap_timer.timeout.disconnect(sendTap)
						tap_timer = null
						sendDoubleTap()
				else:
					sendTap()

	elif event is InputEventScreenDrag or (event is InputEventMouseMotion and touch_attivo):
		if touch_attivo:
			# Recuperiamo la sensibilità dall'interfaccia principale (evitiamo crash se non è impostata)
			var sens = 1
			if interfaccia_principale and "sensibility" in interfaccia_principale:
				sens = interfaccia_principale.sensibility
			
			# Sicurezza matematica: se sensibility è impostato male o sotto 1, forziamo a 1
			if sens < 1:
				sens = 1
				
			# 1. Accumuliamo lo spostamento reale del dito diviso per la sensibilità.
			# Se sens è 2, uno spostamento di 1px aggiunge 0.5 all'accumulo.
			accumulo_x += event.relative.x / float(sens)
			accumulo_y += event.relative.y / float(sens)
			
			# 2. Estraiamo la parte intera accumulata (i pixel effettivi da muovere)
			var delta_x = int(accumulo_x)
			var delta_y = int(accumulo_y)
			
			# 3. Sottraiamo i pixel inviati dagli accumulatori, conservando il resto decimale per il frame successivo
			accumulo_x -= delta_x
			accumulo_y -= delta_y
			print("Accumulo X:",accumulo_x)
			# 4. Se c'è un movimento intero reale da fare, lo inviamo all'interfaccia
			if delta_x != 0 or delta_y != 0:
				mosso_durante_touch = true
				interfaccia_principale._on_mouse_mosso(delta_x, delta_y)
