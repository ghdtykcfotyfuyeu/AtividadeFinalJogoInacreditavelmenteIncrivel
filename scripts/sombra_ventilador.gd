extends Node2D
# Origem: Efeito 2D desenvolvido com ChatGPT/Codex a pedido do autor.

## Sombra projetada no chao, como um ventilador instalado no teto.
@export_range(-180.0, 180.0, 1.0) var velocidade_graus: float = 60.0
@export_range(0.0, 0.5, 0.01) var intensidade: float = 0.18
@export_range(0.005, 0.08, 0.001) var suavidade: float = 0.028

var angulo: float = 0.0
@onready var material_sombra: ShaderMaterial = $Projecao.material


func _ready() -> void:
	material_sombra.set_shader_parameter("intensidade", intensidade)
	material_sombra.set_shader_parameter("suavidade", suavidade)


func _process(delta: float) -> void:
	# Delta mantem a mesma velocidade mesmo quando o FPS varia.
	angulo = fposmod(angulo + deg_to_rad(velocidade_graus) * delta, TAU)
	material_sombra.set_shader_parameter("angulo", angulo)
