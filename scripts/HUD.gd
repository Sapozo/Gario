extends CanvasLayer

# Referencia o node CoinLabel
@onready var coin_label: Label = $CoinDisplay/CoinLabel



# Conecta o sinal em uma função
func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(GameState.coins)


# Atualiza o CoinLabel com o valor do sinal
func _on_coins_changed(new_total: int) -> void:
	coin_label.text = str(new_total)
