class_name KeyboardHelper # Questo è il nome che userai negli altri script!
extends Object

class Tasto:
	var char: String
	var code: String
	var space: float
	
	func _init(p_char: String, p_code: String, p_space: float = 1):
		self.char = p_char
		self.code = p_code
		self.space = p_space

static var layouts = {
	"base":[
		[
			Tasto.new("ESC", "KEY 1"), Tasto.new("F1", "KEY 59"), Tasto.new("F2", "KEY 60"), Tasto.new("F3", "KEY 61"),
			Tasto.new("F4", "KEY 62"), Tasto.new("F5", "KEY 63"), Tasto.new("SLK", "KEY 70"), Tasto.new("✜", "DPAD"),
			Tasto.new("□", "HOME"), Tasto.new("⌫", "KEY 14")
		],
		[
			Tasto.new("1", "KEY 2"), Tasto.new("2", "KEY 3"), Tasto.new("3", "KEY 4"), Tasto.new("4", "KEY 5"),
			Tasto.new("5", "KEY 6"), Tasto.new("6", "KEY 7"), Tasto.new("7", "KEY 8"), Tasto.new("8", "KEY 9"),
			Tasto.new("9", "KEY 10"), Tasto.new("0", "KEY 11")
		],
		[
			Tasto.new("q", "KEY 16"), Tasto.new("w", "KEY 17"), Tasto.new("e", "KEY 18"), Tasto.new("r", "KEY 19"),
			Tasto.new("t", "KEY 20"), Tasto.new("y", "KEY 21"), Tasto.new("u", "KEY 22"), Tasto.new("i", "KEY 23"),
			Tasto.new("o", "KEY 24"), Tasto.new("p", "KEY 25")
		],
		[
			Tasto.new("a", "KEY 30"), Tasto.new("s", "KEY 31"), Tasto.new("d", "KEY 32"), Tasto.new("f", "KEY 33"),
			Tasto.new("g", "KEY 34"), Tasto.new("h", "KEY 35"), Tasto.new("j", "KEY 36"), Tasto.new("k", "KEY 37"),
			Tasto.new("l", "KEY 38"), Tasto.new("@", "KEY 142")
		],
		[
			Tasto.new("z", "KEY 44"), Tasto.new("x", "KEY 45"), Tasto.new("c", "KEY 46"), Tasto.new("v", "KEY 47"),
			Tasto.new("b", "KEY 48"), Tasto.new("n", "KEY 49"), Tasto.new("m", "KEY 50"), Tasto.new("+", "KEY 78"),
			Tasto.new("↵", "KEY 28", 2.0) # L'invio occupa esattamente 3 colonne
		],
		[
			Tasto.new("T/K", "KEY 1001"), Tasto.new("⇧", "KEY 1002"), Tasto.new("\\", "KEY 43"), Tasto.new("SPACE", "KEY 57", 4.0),
			Tasto.new(",", "KEY 51"), Tasto.new(".", "KEY 52"), Tasto.new("-", "KEY 12")
		]
	],
	"baseShift": [
		[
			Tasto.new("F6", "KEY 64"), Tasto.new("F7", "KEY 65"), Tasto.new("F8", "KEY 66"), Tasto.new("F9", "KEY 67"),
			Tasto.new("F10", "KEY 68"), Tasto.new("F11", "KEY 87"), Tasto.new("F12", "KEY 88"), Tasto.new("TAB", "KEY 15"),
			Tasto.new("□", "HOME"), Tasto.new("⌫", "KEY 14")
		],
		[
			Tasto.new("!", "KEY 42+2"),  # Shift + 1
			Tasto.new("\"", "KEY 42+3"), # Shift + 2
			Tasto.new("£", "KEY 42+4"),  # Shift + 3
			Tasto.new("$", "KEY 42+5"),  # Shift + 4
			Tasto.new("%", "KEY 42+6"),  # Shift + 5
			Tasto.new("&", "KEY 42+7"),  # Shift + 6
			Tasto.new("/", "KEY 42+8"),  # Shift + 7
			Tasto.new("(", "KEY 42+9"),  # Shift + 8
			Tasto.new(")", "KEY 42+10"), # Shift + 9
			Tasto.new("=", "KEY 42+11")  # Shift + 0
		],
		[
			Tasto.new("Q", "KEY 42+16"), Tasto.new("W", "KEY 42+17"), Tasto.new("E", "KEY 42+18"), Tasto.new("R", "KEY 42+19"),
			Tasto.new("T", "KEY 42+20"), Tasto.new("Y", "KEY 42+21"), Tasto.new("U", "KEY 42+22"), Tasto.new("I", "KEY 42+23"),
			Tasto.new("O", "KEY 42+24"), Tasto.new("P", "KEY 42+25")
		],
		[
			Tasto.new("A", "KEY 42+30"), Tasto.new("S", "KEY 42+31"), Tasto.new("D", "KEY 42+32"), Tasto.new("F", "KEY 42+33"),
			Tasto.new("G", "KEY 42+34"), Tasto.new("H", "KEY 42+35"), Tasto.new("J", "KEY 42+36"), Tasto.new("K", "KEY 42+37"),
			Tasto.new("L", "KEY 42+38"), Tasto.new("#", "KEY 100+40") #AltGR + à
		],
		[
			Tasto.new("Z", "KEY 42+44"), Tasto.new("X", "KEY 42+45"), Tasto.new("C", "KEY 42+46"), Tasto.new("V", "KEY 42+47"),
			Tasto.new("B", "KEY 42+48"), Tasto.new("N", "KEY 42+49"), Tasto.new("M", "KEY 42+50"), Tasto.new("*", "KEY 42+43"),
			Tasto.new("↵", "KEY 28", 2.0) 
		],
		[
			Tasto.new("T/K", "KEY 1001"), Tasto.new("⇧", "KEY 1002"),
			Tasto.new("|", "KEY 42+41"), # Shift + tasto prima dell'1
			Tasto.new("SPACE", "KEY 57", 4.0), # Barra Spaziatrice (Peso 1.0 per pareggiare la riga a 10 tasti)
			Tasto.new(";", "KEY 42+51"), # Shift + Virgola
			Tasto.new(":", "KEY 42+52"), # Shift + Punto
			Tasto.new("_", "KEY 42+53")  # Shift + Trattino
		]
	],
	"touchpad": [
		[
			Tasto.new("T/K", "KEY 1001"), Tasto.new("F1", "KEY 59"), Tasto.new("F2", "KEY 60"), Tasto.new("F3", "KEY 61"),
			Tasto.new("F4", "KEY 62"), Tasto.new("SP", "KEY 57"), Tasto.new("↵", "KEY 28"),  Tasto.new("⌫", "KEY 14"),
			Tasto.new("S1", "KEY 1003"), Tasto.new("AB", "KEY 1004")
		],
		[
			Tasto.new("TOUCHPAD", "TOUCHPAD", 10)
		]
	],
	"touchabs": [
		[
			Tasto.new("TOUCHABS", "TOUCHABS", 9),
			Tasto.new("T/K", "KEY 1001")
		]
	]
}
static func getTouchPad(tasto:Tasto, size:Vector2, hb:float, separatore:float) -> Panel:
	var altezza_touchpad = size.y - 60 - 15
	var touchpad = Panel.new()
	touchpad.set_script(load("res://VTKTouchpad.gd"))
	var larghezza_pixel = (hb * tasto.space) + ((tasto.space - 1) * separatore)

	var stile_sfondo = StyleBoxFlat.new()
	stile_sfondo.bg_color = Color(0.15, 0.15, 0.15, 1.0) # Il tuo grigio
	touchpad.add_theme_stylebox_override("panel", stile_sfondo)

	touchpad.custom_minimum_size = Vector2(larghezza_pixel+4, altezza_touchpad)

	var etichetta = Label.new()
	etichetta.text = "TOUCHPAD"
	etichetta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etichetta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Espande la label su tutto il touchpad per centrarsi automaticamente
	etichetta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) 
	etichetta.add_theme_color_override("font_color", Color(1, 1, 1, 0.2))
	etichetta.add_theme_font_size_override("font_size", 60)
	touchpad.add_child(etichetta)

	var subetichetta = Label.new()
	subetichetta.text = "RELATIVE"
	subetichetta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subetichetta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subetichetta.material = CanvasItemMaterial.new()
	# Espande la label su tutto il touchpad per centrarsi automaticamente
	subetichetta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) 
	subetichetta.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	subetichetta.add_theme_font_size_override("font_size", 30)
	subetichetta.offset_top += 90
	touchpad.add_child(subetichetta)
	
	return touchpad

static func getTouchABS(tasto:Tasto, size:Vector2, hb:float, separatore:float) -> Panel:
	var altezza_touchpad = size.y - 10
	var touchpad = Panel.new()
	touchpad.mouse_filter = Control.MOUSE_FILTER_PASS
	var larghezza_pixel = (hb * tasto.space) + ((tasto.space - 1) * separatore)
	
	var stile_sfondo = StyleBoxFlat.new()
	stile_sfondo.bg_color = Color(0.15, 0.15, 0.15, 1.0) # Il tuo grigio
	touchpad.add_theme_stylebox_override("panel", stile_sfondo)
	touchpad.custom_minimum_size = Vector2(larghezza_pixel, altezza_touchpad)
	
	var etichetta = Label.new()
	etichetta.text = "TOUCHPAD"
	etichetta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etichetta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Espande la label su tutto il touchpad per centrarsi automaticamente
	etichetta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) 
	etichetta.add_theme_color_override("font_color", Color(1, 1, 1, 0.2))
	etichetta.add_theme_font_size_override("font_size", 60)
	touchpad.add_child(etichetta)
	
	var subetichetta = Label.new()
	subetichetta.text = "ABSOLUTE"
	subetichetta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subetichetta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subetichetta.material = CanvasItemMaterial.new()
	# Espande la label su tutto il touchpad per centrarsi automaticamente
	subetichetta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) 
	subetichetta.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	subetichetta.add_theme_font_size_override("font_size", 30)
	subetichetta.offset_top += 90
	touchpad.add_child(subetichetta)
	return touchpad
	
static func getButtonsForPanel() -> Array[Tasto]:
	return [Tasto.new("T/K", "KEY 1001"), Tasto.new("F1", "KEY 59"), Tasto.new("F2", "KEY 60"),
			 Tasto.new("SP", "KEY 57"), Tasto.new("↵", "KEY 28"), Tasto.new("RE", "KEY 1006")]
	
static func createButton(tasto:Tasto, hb:float, separatore:float, sensibility:int, layoutAttuale:String) -> Button:
	var codeDark = ["KEY 57","KEY 28", "KEY 1001","KEY 59","KEY 60","KEY 61","KEY 62","KEY 63","KEY 64",
					"KEY 65","KEY 66","KEY 14","KEY 1","KEY 1002","KEY 66","KEY 67","KEY 68","KEY 87",
					"KEY 88","KEY 15","KEY 29","KEY 70", "DPAD"]
	
	var nuovo_bottone = Button.new()
	nuovo_bottone.text = tasto.char
	var larghezza_pixel = (hb * tasto.space) + ((tasto.space - 1) * separatore)
	nuovo_bottone.custom_minimum_size = Vector2(larghezza_pixel, 60)
	nuovo_bottone.add_theme_font_size_override("font_size", 22)
	
	var stile_sfondo = StyleBoxFlat.new()
	stile_sfondo.bg_color = Color(0.25, 0.25, 0.25, 1.0)
	if(tasto.code in codeDark):
		if(tasto.code == "DPAD"):
			nuovo_bottone.set_meta("DPAD","DPAD")
			nuovo_bottone.add_theme_font_size_override("font_size", 28)
		stile_sfondo.bg_color = Color(0.20, 0.20, 0.20, 1.0)
	elif (tasto.code == "KEY 1003"):
		stile_sfondo.bg_color = Color(0.145, 0.141, 0.49, 1.0)
		if(sensibility == 2):
			nuovo_bottone.text = "S2"
		elif(sensibility == 3):
			nuovo_bottone.text = "S3"
	elif (tasto.code == "KEY 1004" or tasto.code == "KEY 1006"):
		stile_sfondo.bg_color = Color(0.061, 0.245, 0.175, 1.0)
	elif (tasto.code == "KEY 1010"):
		stile_sfondo.bg_color = Color(0.389, 0.071, 0.049, 1.0)
	elif (tasto.code == "HOME"):
		var texture_icona = load("res://house.png")
		stile_sfondo.bg_color = Color(0.061, 0.245, 0.175, 1.0)
		nuovo_bottone.add_theme_constant_override("icon_max_width", 22)
		nuovo_bottone.icon_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
		nuovo_bottone.icon = texture_icona
		nuovo_bottone.text = ""
	stile_sfondo.set_corner_radius_all(4)
	var stile_premuto = StyleBoxFlat.new()
	stile_premuto.bg_color = Color(0.4, 0.4, 0.4, 1.0) 
	stile_premuto.set_corner_radius_all(4)
	
	nuovo_bottone.add_theme_stylebox_override("normal", stile_sfondo)
	nuovo_bottone.add_theme_stylebox_override("hover", stile_sfondo) 
	nuovo_bottone.add_theme_stylebox_override("focused", stile_sfondo)
	nuovo_bottone.add_theme_stylebox_override("pressed", stile_premuto) 
	
	if layoutAttuale == "baseShift" and tasto.code == "KEY 1002":
		nuovo_bottone.add_theme_color_override("font_color", Color.GREEN)
	return nuovo_bottone

static func createButtonFromPanel(tasto:Tasto, hb:float, separatore:float, sensibility:int,
									 layoutAttuale:String, position:int) -> Button:
	var b = createButton(tasto, hb, separatore, sensibility, layoutAttuale)
	b.offset_top = 65 * position
	return b

static func hideMouseCursor():
	if OS.get_name() != "macOS":
		var texture = load("res://curtra.png")
		Input.set_custom_mouse_cursor(texture)
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
