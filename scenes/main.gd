extends Control

const GOAL := 100000
const FONT_PATH := "res://assets/NotoSansTC.ttf"
const JOBS := [
	{"name":"便利商店夥伴", "icon":"🏪", "cost":1800, "income":90, "desc":"輪班補貨，穩定增加收入"},
	{"name":"課後家教", "icon":"📚", "cost":6500, "income":320, "desc":"把專業變成高時薪"},
	{"name":"城市外送員", "icon":"🛵", "cost":15000, "income":850, "desc":"穿梭城市，訂單接不停"}
]
var screen := "home"
var cash := 0
var energy := 100
var owned := [0, 0, 0]
var elapsed := 0.0
var font: Font
var content: VBoxContainer
var status_label: Label
var timer_label: Label
var cash_label: Label
var energy_bar: ProgressBar

func _ready() -> void:
	font = load(FONT_PATH) if ResourceLoader.exists(FONT_PATH) else ThemeDB.fallback_font
	get_viewport().size_changed.connect(_fit_ui)
	show_home()

func _fit_ui() -> void:
	queue_redraw()

func _draw() -> void:
	var rect := get_viewport_rect()
	draw_rect(rect, Color("0e1422"), true)
	draw_circle(Vector2(rect.size.x * 0.08, rect.size.y * 0.08), minf(rect.size.x, rect.size.y) * 0.32, Color("17243a"))
	draw_circle(Vector2(rect.size.x * 0.96, rect.size.y * 0.92), minf(rect.size.x, rect.size.y) * 0.30, Color("15283a"))

func clear_ui() -> void:
	for child in get_children():
		if child != null:
			child.queue_free()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(minf(960, get_viewport_rect().size.x - 28), minf(740, get_viewport_rect().size.y - 32))
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", _style(Color("192438"), Color("34435c"), 18, 2))
	center.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	content.add_theme_stylebox_override("panel", _style(Color(0,0,0,0), Color(0,0,0,0), 0, 0))
	scroll.add_child(content)
	content.add_theme_constant_override("margin_left", 30)
	content.add_theme_constant_override("margin_right", 30)
	content.add_theme_constant_override("margin_top", 26)
	content.add_theme_constant_override("margin_bottom", 26)

func show_home() -> void:
	screen = "home"
	clear_ui()
	var badge := _label("JIM'S CAMPUS LIFE  •  點擊放置養成", 15, Color("8da6ca"), HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(badge)
	content.add_child(_label("打工魂：學費大作戰", 42, Color("fff3d0"), HORIZONTAL_ALIGNMENT_CENTER, true))
	content.add_child(_label("從第一份打工開始，替自己的未來存下 100,000 元學費。", 18, Color("c2cde0"), HORIZONTAL_ALIGNMENT_CENTER))
	var hero := _panel_box(Color("243650"))
	content.add_child(hero)
	hero.add_child(_label("🎓  JIM  •  打工大學生\n\n白天上課、晚上接班。靠你的點擊接下工作，\n再把收入投資在便利商店、家教和外送工作站。", 20, Color("f1f5fb"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_button("開始存學費  →", Color("ffbd59"), Color("272034"), show_game))
	content.add_child(_label("操作說明　點「開始打工」賺現金並消耗體力；點「休息充電」恢復體力。\n購買工作升級後會自動帶來收入。存到 100,000 元即可過關，體力歸零則挑戰失敗。", 15, Color("b8c6db"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_label("資通四勤 121271101 許濬鵬", 15, Color("ffcf7a"), HORIZONTAL_ALIGNMENT_CENTER))

func show_game() -> void:
	screen = "game"
	cash = 0
	energy = 100
	owned = [0, 0, 0]
	elapsed = 0
	clear_ui()
	content.add_child(_label("打工魂：學費大作戰", 28, Color("fff3d0"), HORIZONTAL_ALIGNMENT_CENTER, true))
	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 16)
	content.add_child(stats)
	cash_label = _label("💰 存款　$0", 20, Color("ffe09b"))
	stats.add_child(_stat_card(cash_label))
	var goal := _label("🎯 學費　$100,000", 18, Color("d4e1f4"))
	stats.add_child(_stat_card(goal))
	var energy_row := HBoxContainer.new()
	content.add_child(energy_row)
	energy_row.add_child(_label("⚡ 體力　", 17, Color("c2cde0")))
	energy_bar = ProgressBar.new()
	energy_bar.max_value = 100
	energy_bar.value = energy
	energy_bar.show_percentage = false
	energy_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	energy_bar.custom_minimum_size.y = 22
	energy_row.add_child(energy_bar)
	status_label = _label("準備好開始今天的班表了！", 15, Color("a9bdd8"), HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(status_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 14)
	content.add_child(actions)
	actions.add_child(_button("🧋  開始打工  +$500  ·  -8 體力", Color("ffbd59"), Color("272034"), manual_work))
	actions.add_child(_button("☕  休息充電  +25 體力", Color("76d6bd"), Color("102c32"), rest))
	content.add_child(_label("自動打工升級　｜　每秒入帳被動收入", 20, Color("edf3fc"), HORIZONTAL_ALIGNMENT_LEFT, true))
	for i in range(JOBS.size()):
		var job: Dictionary = JOBS[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		content.add_child(row)
		var info := _label("%s  %s\n%s　｜　每秒 +$%d　｜　已聘 %d 人" % [job.icon, job.name, job.desc, job.income, owned[i]], 15, Color("d2dced"))
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		var cost := _button("聘用  $%s" % _money(job.cost), Color("304766"), Color("f2f6fd"), func(): buy_job(i))
		cost.custom_minimum_size.x = 180
		row.add_child(cost)
	content.add_child(_label("Jim 的學費進度", 15, Color("9fb2cc")))
	var progress := ProgressBar.new()
	progress.max_value = GOAL
	progress.value = cash
	progress.show_percentage = true
	progress.name = "GoalProgress"
	content.add_child(progress)
	var clockrow := HBoxContainer.new()
	content.add_child(clockrow)
	timer_label = _label("⏱ 00:00", 13, Color("8da6ca"))
	clockrow.add_child(timer_label)
	var back := _button("回首頁", Color("27344a"), Color("cbd6e5"), show_home)
	clockrow.add_child(back)

func _process(delta: float) -> void:
	if screen != "game": return
	elapsed += delta
	var passive := _passive_per_second()
	if passive > 0:
		cash += int(passive * delta)
		_update_stats()
	if is_instance_valid(timer_label):
		timer_label.text = "⏱ %02d:%02d　｜　被動收入 $%s / 秒" % [int(elapsed) / 60, int(elapsed) % 60, _money(passive)]
	if cash >= GOAL:
		show_result(true)
	elif energy <= 0:
		show_result(false)

func manual_work() -> void:
	if energy <= 0:
		status_label.text = "體力不足了，先休息一下再繼續！"
		return
	cash += 500
	energy = maxi(0, energy - 8)
	status_label.text = "接下這份打工！存款 +$500，體力 -8。"
	_update_stats()

func rest() -> void:
	energy = mini(100, energy + 25)
	status_label.text = "喝杯飲料喘口氣，體力恢復 25！"
	_update_stats()

func buy_job(i: int) -> void:
	var price: int = JOBS[i].cost * (owned[i] + 1)
	if cash < price:
		status_label.text = "存款還不夠，先多接幾班吧！"
		return
	cash -= price
	owned[i] += 1
	status_label.text = "新工作上線！被動收入增加 $%d / 秒。" % JOBS[i].income
	show_game_refresh()

func show_game_refresh() -> void:
	var was_cash := cash
	var was_energy := energy
	var was_owned := owned.duplicate()
	var was_elapsed := elapsed
	show_game()
	cash = was_cash
	energy = was_energy
	owned = was_owned
	elapsed = was_elapsed
	_update_stats()
	status_label.text = "新工作上線！被動收入已提高。"
	for i in range(JOBS.size()):
		var row: HBoxContainer = content.get_child(6 + i)
		var info: Label = row.get_child(0)
		var button: Button = row.get_child(1)
		var job: Dictionary = JOBS[i]
		var price: int = job.cost * (owned[i] + 1)
		info.text = "%s  %s\n%s　｜　每秒 +$%d　｜　已聘 %d 人" % [job.icon, job.name, job.desc, job.income, owned[i]]
		button.text = "聘用  $%s" % _money(price)

func _update_stats() -> void:
	if not is_instance_valid(cash_label): return
	cash_label.text = "💰 存款　$%s" % _money(cash)
	energy_bar.value = energy
	var progress := content.get_node_or_null("GoalProgress") as ProgressBar
	if progress: progress.value = cash

func _passive_per_second() -> int:
	var total := 0
	for i in range(JOBS.size()): total += JOBS[i].income * owned[i]
	return total

func show_result(won: bool) -> void:
	screen = "result"
	clear_ui()
	content.add_child(_label("🎉  學費達標！" if won else "🌙  今天先休息吧", 36, Color("ffe09b") if won else Color("d7e2f0"), HORIZONTAL_ALIGNMENT_CENTER, true))
	content.add_child(_label("Jim 的大學夢，再往前一步！" if won else "體力耗盡，這次挑戰結束。明天再來存學費！", 19, Color("c2cde0"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_panel_box(Color("243650")))
	var summary: PanelContainer = content.get_child(2)
	summary.add_child(_label("最終存款　$%s / $100,000\n打工時間　%d 分 %02d 秒\n聘用工作站　%d 個" % [_money(cash), int(elapsed) / 60, int(elapsed) % 60, owned[0]+owned[1]+owned[2]], 21, Color("f1f5fb"), HORIZONTAL_ALIGNMENT_CENTER))
	content.add_child(_button("再挑戰一次", Color("ffbd59"), Color("272034"), show_game))
	content.add_child(_button("回首頁", Color("304766"), Color("f2f6fd"), show_home))
	content.add_child(_label("資通四勤 121271101 許濬鵬", 15, Color("ffcf7a"), HORIZONTAL_ALIGNMENT_CENTER))

func _panel_box(color: Color) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _style(color, Color("40536f"), 14, 1))
	p.add_theme_constant_override("margin_left", 20)
	p.add_theme_constant_override("margin_right", 20)
	p.add_theme_constant_override("margin_top", 16)
	p.add_theme_constant_override("margin_bottom", 16)
	return p

func _stat_card(node: Control) -> PanelContainer:
	var p := _panel_box(Color("243650"))
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.add_child(node)
	return p

func _label(text_value: String, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if bold: label.add_theme_color_override("font_shadow_color", Color("617da4"))
	return label

func _button(text_value: String, bg: Color, fg: Color, action: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size.y = 52
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", fg)
	button.add_theme_stylebox_override("normal", _style(bg, bg.lightened(0.12), 12, 1))
	button.add_theme_stylebox_override("hover", _style(bg.lightened(0.12), bg.lightened(0.3), 12, 1))
	button.add_theme_stylebox_override("pressed", _style(bg.darkened(0.12), bg.lightened(0.1), 12, 1))
	button.add_theme_stylebox_override("focus", _style(Color(0,0,0,0), Color(0,0,0,0), 12, 0))
	button.pressed.connect(action)
	return button

func _style(bg: Color, border: Color, radius: int, border_size: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_size)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 9
	s.content_margin_bottom = 9
	return s

func _money(amount: int) -> String:
	var value := str(amount)
	var out := ""
	for i in range(value.length()):
		if i > 0 and (value.length() - i) % 3 == 0: out += ","
		out += value[i]
	return out

