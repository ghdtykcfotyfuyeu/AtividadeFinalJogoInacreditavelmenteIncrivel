shader_type canvas_item;
// Origem: Efeito 2D desenvolvido com ChatGPT/Codex a pedido do autor.
render_mode unshaded, blend_mix;

uniform float angulo = 0.0;
uniform float intensidade : hint_range(0.0, 0.5) = 0.18;
uniform float suavidade : hint_range(0.005, 0.08) = 0.028;

// Uma pa alongada, com ponta arredondada e leve curvatura.
float distancia_pa(vec2 ponto) {
	float progresso = clamp((ponto.x - 0.10) / 0.70, 0.0, 1.0);
	ponto.y -= 0.055 * progresso * progresso;
	vec2 borda = abs(ponto - vec2(0.45, 0.0));
	borda -= vec2(0.31, mix(0.035, 0.085, progresso));
	return length(max(borda, vec2(0.0)))
		+ min(max(borda.x, borda.y), 0.0) - 0.035;
}

void fragment() {
	vec2 ponto = (UV - vec2(0.5)) * 2.0;
	float c = cos(angulo);
	float s = sin(angulo);
	ponto = vec2(c * ponto.x + s * ponto.y, -s * ponto.x + c * ponto.y);
	// Tres pas a 120 graus. A uniao evita manchas escuras nas sobreposicoes.
	mat2 giro = mat2(vec2(-0.5, 0.8660254), vec2(-0.8660254, -0.5));
	float distancia = length(ponto) - 0.12;
	distancia = min(distancia, distancia_pa(ponto));
	distancia = min(distancia, distancia_pa(giro * ponto));
	distancia = min(distancia, distancia_pa(giro * giro * ponto));
	float sombra = 1.0 - smoothstep(-suavidade, suavidade, distancia);
	COLOR = vec4(0.03, 0.045, 0.05, sombra * intensidade * COLOR.a);
}
