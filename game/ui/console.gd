## The dev console. Backtick to open, type, Enter.
##
## Nick, 2026-09-01: "can we put in a dev console in the game? so we can add
## lines like that for me to add cards to my hand to test?"
##
## The launch flags (tools\dev.cmd) answered the wrong half of the question.
## They set the world up BEFORE you can see it, so every "what does this card
## look like" cost a relaunch, a character pick, a map step and a fight - about
## forty seconds to answer a two-second question. This changes the world you
## are already looking at.
##
## WHAT IT IS ALLOWED TO DO
##
## It reaches into the HOST's live Run and edits it. That is a real reach across
## the session boundary and it is deliberate: nothing here goes through a
## command, so nothing here can desync a co-op game, because it never leaves
## this machine. The rule that keeps it honest is that it only runs where
## `Session.host` exists - solo, or the machine hosting - and a pure client that
## joined someone else's game gets "no host here" rather than a lie.
##
## It is NOT gated behind a build flag. This is a two-person project with no
## release; a console you have to recompile to get is a console nobody uses.
## When there is a build to ship, gate it on OS.is_debug_build().
##
## ADDING A COMMAND is one entry in CMDS: the name, one line of help, and a
## Callable taking the argument array and returning a string to print. The help
## text IS the registry, so `help` cannot drift out of date with what exists.
class_name DevConsole
extends CanvasLayer

const HISTORY := 40

var _panel: PanelContainer
var _out: RichTextLabel
var _line: LineEdit
## Is a console open anywhere? Views ask this before acting on a key.
##
## Nick: "disable game controls while using the dev menu. I can type a space
## because thats my end turn button." Right, and it is worse than it sounds -
## combat_3d reads keys in _input() rather than _unhandled_input(), deliberately
## (Space activates a focused Button and TAB is ui_focus_next, and the GUI layer
## eats both before unhandled input runs). _input() fires BEFORE the focused
## LineEdit gets the key, so every character typed here was also a game command:
## space ended the turn, [ and ] swapped the beast you were fighting.
##
## Static because the question is "is ANY console open", and the view asking has
## no reason to know where the node lives.
static var open := false

var _history: PackedStringArray = []
var _at := -1
## The view that owns us, so a command that changes the world can ask for a
## redraw without knowing what the view is called.
var _refresh: Callable = Callable()


static func attach(to: Node, refresh: Callable = Callable()) -> DevConsole:
	var c := DevConsole.new()
	c.name = "DevConsole"
	c._refresh = refresh
	to.add_child(c)
	return c


func _ready() -> void:
	# Above the HUD, and above the card fan's z_index of 10.
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_panel.offset_bottom = 268.0
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.045, 0.06, 0.94)
	sb.border_color = Color(0.42, 0.78, 0.55, 0.7)
	sb.border_width_bottom = 2
	sb.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.visible = false
	add_child(_panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	_panel.add_child(col)

	_out = RichTextLabel.new()
	_out.bbcode_enabled = true
	_out.scroll_following = true
	_out.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_out.add_theme_font_size_override("normal_font_size", 13)
	_out.add_theme_color_override("default_color", Color(0.82, 0.86, 0.80))
	col.add_child(_out)

	_line = LineEdit.new()
	_line.placeholder_text = "help"
	_line.add_theme_font_size_override("font_size", 14)
	_line.text_submitted.connect(_submit)
	# The LineEdit swallows the key that OPENED the console otherwise, and a
	# console that types a backtick into itself every time is a small papercut
	# you hit on literally every use.
	_line.gui_input.connect(_line_keys)
	col.add_child(_line)

	_say("[color=#7fd45c]dev console[/color] — `help` for commands, "
		+ "backtick or F1 to close, Up/Down for history")


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_QUOTELEFT or key.keycode == KEY_F1:
		_toggle()
		get_viewport().set_input_as_handled()


func _toggle() -> void:
	_set_open(not _panel.visible)


## Open or close, stated rather than flipped.
##
## `deck` used to call _toggle() to get out of the way of the screen it was
## opening, which is only correct if the console is already open - driven from
## the screenshot harness it OPENED the console instead, and the panel sat on
## top of the deck screen in the shot meant to verify the deck screen.
func _set_open(want: bool) -> void:
	_panel.visible = want
	open = want
	if _panel.visible:
		_line.clear()
		_line.grab_focus()
	else:
		_line.release_focus()


## Leaving the fight with the console open would strand `open` at true and the
## next view would ignore every key you pressed.
func _exit_tree() -> void:
	open = false


## Up/Down walk the history; Escape closes. On the LineEdit rather than in
## _unhandled_input because a focused LineEdit consumes its own keys first.
func _line_keys(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed:
		return
	if key.keycode == KEY_ESCAPE or key.keycode == KEY_QUOTELEFT:
		_toggle()
		_line.accept_event()
	elif key.keycode == KEY_UP and not _history.is_empty():
		_at = maxi(_at - 1, 0)
		_line.text = _history[_at]
		_line.caret_column = _line.text.length()
		_line.accept_event()
	elif key.keycode == KEY_DOWN and not _history.is_empty():
		_at += 1
		if _at >= _history.size():
			_at = _history.size()
			_line.text = ""
		else:
			_line.text = _history[_at]
		_line.caret_column = _line.text.length()
		_line.accept_event()


func _say(s: String) -> void:
	_out.append_text(s + "\n")


func _submit(text_in: String) -> void:
	var text := text_in.strip_edges()
	_line.clear()
	if text == "":
		return
	_history.append(text)
	if _history.size() > HISTORY:
		_history.remove_at(0)
	_at = _history.size()
	_say("[color=#6f7684]> " + text + "[/color]")
	_say(run(text))


# --- the commands ----------------------------------------------------------

## name -> [one-line help, Callable(args: PackedStringArray) -> String].
## Built here rather than as a constant because the Callables bind to `self`.
func _cmds() -> Dictionary:
	return {
		"help": ["list these", _help],
		# DECK first, then HAND. Nick asked for "a command to add a card to your
		# deck" when one already existed called `own` - which is a fine word and
		# not one anybody guesses. The obvious name goes on the thing people
		# actually want, and the hand versions say "hand" in their names.
		"add": ["add crescendo — add a card to your DECK, permanently", _cmd_own],
		"own": ["same as add (kept so older notes still work)", _cmd_own],
		"hand": ["hand crescendo,leap — REPLACE the hand you are holding", _cmd_hand],
		"deal": ["deal crescendo — add one card to the hand you are holding", _cmd_add],
		"find": ["find leap — card ids matching a word", _cmd_find],
		"rares": ["which rares exist, and which have art", _cmd_rares],
		"foil": ["foil on|off — force every card foil", _cmd_foil],
		"borderless": ["borderless on|off — force the borderless treatment", _cmd_borderless],
		"treatment": ["cycle framed / borderless / borderless foil / foil (same as F9)", _cmd_treatment],
		"turn": ["turn 0.6 | off — pin a 3D window to one view", _cmd_turn],
		"energy": ["energy 9 — set your energy this turn", _cmd_energy],
		"climb": ["climb 4 — set your Height", _cmd_climb],
		"beast": ["beast thrasher — swap the thing you are fighting", _cmd_beast],
		"deck": ["open the deck screen (same as clicking the pile counts)", _cmd_deck],
		"card": ["card 3 140 up — the Nth card, spun N degrees, `up` for its upgrade", _cmd_card],
		"clear": ["wipe the output", _cmd_clear],
	}


func run(text: String) -> String:
	var parts := text.split(" ", false)
	var name := String(parts[0]).to_lower()
	var args: PackedStringArray = parts.slice(1)
	var cmds := _cmds()
	if not cmds.has(name):
		return "[color=#e08a6a]no such command: %s[/color] (try help)" % name
	var fn: Callable = (cmds[name] as Array)[1]
	var said := String(fn.call(args))
	# Redraw HERE rather than in _submit(), so every caller gets it. The
	# screenshot harness drives run() directly to prove the commands work, and
	# with the refresh on the typing path only, `borderless on` changed the flag
	# and left the old cards on screen - which photographs as "the command does
	# nothing". A command that changes what you see should finish by changing
	# what you see, whoever asked for it.
	if _refresh.is_valid():
		_refresh.call()
	return said


func _help(_a: PackedStringArray) -> String:
	var out: PackedStringArray = []
	var cmds := _cmds()
	for k in cmds:
		out.append("  [color=#7fd45c]%s[/color]  %s" % [k, (cmds[k] as Array)[0]])
	return "\n".join(out)


## The live Combat, or null. Everything that edits the world goes through this,
## so "you are a client" and "you are not in a fight" are answered once.
func _combat() -> Combat:
	if Session.host == null or Session.host._run == null:
		return null
	return Session.host._run.combat


## Which slot the player is looking at. The view knows; ask it rather than
## guessing, or every command silently edits hunter 0 while you watch hunter 1.
func _slot() -> int:
	var view := get_parent()
	if view != null and view.get("_active_slot") != null:
		return clampi(int(view.get("_active_slot")), 0, 1)
	return 0


func _need_combat() -> String:
	if Session.host == null:
		return "no host on this machine — the console only works solo or as the host"
	if _combat() == null:
		return "not in a fight"
	return ""


func _push() -> void:
	Session.host._broadcast_state()


func _cmd_hand(a: PackedStringArray) -> String:
	var why := _need_combat()
	if why != "":
		return why
	if a.is_empty():
		return "hand <id>[,<id>...]"
	var cards := _make(" ".join(a))
	if cards.is_empty():
		return "no card matched"
	_combat().players[_slot()].hand = cards
	_push()
	return "dealt %d card(s) to hunter %d" % [cards.size(), _slot()]


func _cmd_add(a: PackedStringArray) -> String:
	var why := _need_combat()
	if why != "":
		return why
	var cards := _make(" ".join(a))
	if cards.is_empty():
		return "no card matched"
	for c in cards:
		_combat().players[_slot()].hand.append(c)
	_push()
	return "added %d card(s)" % cards.size()


## Card ids from "a,b c" — commas or spaces, either way. Unknown ids are
## reported rather than becoming blanks: Content.make_card hands back an empty
## Card with no id when it does not recognise one, which on the table looks
## like a rendering bug rather than a typo.
func _make(text: String) -> Array:
	var out: Array = []
	for raw in text.replace(",", " ").split(" ", false):
		var id := String(raw).strip_edges()
		if id == "":
			continue
		var c := Content.make_card(id)
		if c.id == "":
			_say("[color=#e08a6a]  unknown card: %s[/color]" % id)
			continue
		out.append(c)
	return out


func _cmd_find(a: PackedStringArray) -> String:
	if a.is_empty():
		return "find <part of an id or name>"
	var want := " ".join(a).to_lower()
	var hits: PackedStringArray = []
	for id in Content.list_card_ids():
		if String(id).to_lower().contains(want):
			hits.append(String(id))
	if hits.is_empty():
		return "nothing matching '%s'" % want
	return "%d: %s" % [hits.size(), ", ".join(hits)]


func _cmd_rares(_a: PackedStringArray) -> String:
	var with_art: PackedStringArray = []
	var without: PackedStringArray = []
	for id in Content.list_card_ids():
		var c := Content.make_card(String(id))
		if c.rarity != "rare":
			continue
		if ResourceLoader.exists(CardView.CARD_ART_3D + String(id) + ".png"):
			with_art.append(String(id))
		else:
			without.append(String(id))
	return ("[color=#7fd45c]window built (%d):[/color] %s\n"
		+ "[color=#6f7684]still flat (%d):[/color] %s") % [
			with_art.size(), ", ".join(with_art) if not with_art.is_empty() else "-",
			without.size(), ", ".join(without)]


func _on_off(a: PackedStringArray, now: bool) -> bool:
	if a.is_empty():
		return not now
	return String(a[0]).to_lower() in ["on", "1", "true", "yes"]


func _cmd_foil(a: PackedStringArray) -> String:
	CardView.force_foil = _on_off(a, CardView.force_foil)
	return "foil %s" % ("on" if CardView.force_foil else "off")


func _cmd_borderless(a: PackedStringArray) -> String:
	CardView.force_borderless = _on_off(a, CardView.force_borderless)
	return "borderless %s" % ("on" if CardView.force_borderless else "off")


func _cmd_treatment(_a: PackedStringArray) -> String:
	return "cards: " + Dev.cycle()


func _cmd_turn(a: PackedStringArray) -> String:
	if not a.is_empty() and String(a[0]).to_lower() == "off":
		CardView.force_turn = 2.0
		return "turn follows the pointer again"
	if a.is_empty():
		return "turn <-1..1> | off"
	CardView.force_turn = clampf(String(a[0]).to_float(), -1.0, 1.0)
	return "turn pinned to %.2f" % CardView.force_turn


func _cmd_energy(a: PackedStringArray) -> String:
	var why := _need_combat()
	if why != "":
		return why
	if a.is_empty():
		return "energy <n>"
	_combat().players[_slot()].energy = int(String(a[0]).to_int())
	_push()
	return "energy %d" % _combat().players[_slot()].energy


func _cmd_climb(a: PackedStringArray) -> String:
	var why := _need_combat()
	if why != "":
		return why
	if a.is_empty():
		return "climb <n>"
	_combat().players[_slot()].foothold = maxi(int(String(a[0]).to_int()), 0)
	_push()
	return "hunter %d is at Height %d" % [_slot(), _combat().players[_slot()].foothold]


func _cmd_beast(a: PackedStringArray) -> String:
	var why := _need_combat()
	if why != "":
		return why
	if a.is_empty():
		return "beast <id>"
	var id := String(a[0]).strip_edges()
	# Asked of the LIST, not of the result. build_boss cannot fail: an unknown
	# id gives back a Boss called "Titan" with 1 HP, which would drop you into a
	# fight you win by breathing on it and look like a bug in the beast data.
	if not (id in Content.list_boss_ids()):
		return "no such beast: %s\n[color=#6f7684]%s[/color]" % [
			id, ", ".join(Content.list_boss_ids())]
	var b := Content.build_boss(id)
	_combat().boss = b
	_push()
	return "now fighting %s" % b.name


func _cmd_deck(_a: PackedStringArray) -> String:
	var view := get_parent()
	if view == null or not view.has_method("open_deck"):
		return "this view has no deck screen"
	_set_open(false)   # get out of the way of the thing you asked to look at
	view.call("open_deck")
	return "deck open"


## Add to the DECK rather than the hand. `hand` and `deal` change what you are
## holding this turn and are gone at the end of it; this changes what you OWN,
## which is what the deck screen shows and what survives the fight.
func _cmd_own(a: PackedStringArray) -> String:
	if Session.host == null or Session.host._run == null:
		return "no host on this machine"
	if a.is_empty():
		return "own <id>[,<id>...]"
	var cards := _make(" ".join(a))
	if cards.is_empty():
		return "no card matched"
	var deck: Array = Session.host._run.decks[_slot()]
	for c in cards:
		deck.append(c)
	_push()
	# If the deck screen is open, it is showing a snapshot taken before this
	# card existed. Reopen it rather than leaving you looking at a list that is
	# quietly one card short of the truth.
	var view := get_parent()
	var dv := view.get_node_or_null("DeckView") if view != null else null
	if dv != null:
		dv.free()
		if view.has_method("open_deck"):
			view.call("open_deck")
	return "added %d card(s) to hunter %d's deck (%d cards)" % [
		cards.size(), _slot(), deck.size()]


func _cmd_card(a: PackedStringArray) -> String:
	if a.is_empty():
		return "card <n> <degrees> — the position in your deck, from 0"
	var said := _cmd_deck([])
	if said != "deck open":
		return said
	var dv := get_parent().get_node_or_null("DeckView")
	if dv == null:
		return "no deck screen opened"
	if not bool(dv.call("inspect", int(String(a[0]).to_int()))):
		return "no card at %s" % a[0]
	if a.size() > 2 and String(a[2]).to_lower() in ["up", "upgrade", "upgraded"]:
		dv.call("show_upgrade", true)
	if a.size() > 1:
		# Turning it from here is how the screenshot harness photographs the
		# effect at all: a shot cannot drag, and an untouched card is always at
		# dead centre, which is the one angle where a parallax proves nothing.
		dv.call("spin_to", String(a[1]).to_float())
		return "inspecting card %s, spun to %s degrees" % [a[0], a[1]]
	return "inspecting card %s" % a[0]


func _cmd_clear(_a: PackedStringArray) -> String:
	_out.clear()
	return ""
