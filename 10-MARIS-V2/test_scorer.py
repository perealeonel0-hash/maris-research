"""
Test del MARISScorer en Python (para probar la lógica antes de Swift).
Misma lógica que MARISScorer.swift.
"""
import json

# Cargar diccionario
with open("data/diccionario_v1.json", "r") as f:
    DICCIONARIO = json.load(f)

print(f"Diccionario: {len(DICCIONARIO)} entradas\n")

# Categorías por grupo
CATS_HARDWARE = ["hardware_accion"]
CATS_FLOW = ["flow_genuino"]
CATS_FRICCION = [
    "friccion_alta", "friccion_media", "ansiedad_somatica",
    "panico", "paralisis", "agotamiento", "absolutismo",
    "culpa", "rabia", "disociacion"
]


def score(mensaje, historial_fragil=False, deformacion=0.0, scars_recientes=False):
    msg = mensaje.lower()

    # Multiplicador de usuario
    if historial_fragil:
        mult = 1.5
    elif deformacion > 0.3:
        mult = 1.3
    elif scars_recientes:
        mult = 1.4
    else:
        mult = 1.0

    # Buscar coincidencias
    detectadas = []
    for entry in DICCIONARIO:
        if entry["palabra"].lower() in msg:
            peso = entry["peso_base"] * mult
            detectadas.append((entry, peso))

    # Calcular scores
    def calc(cats):
        relevantes = [(e, p) for e, p in detectadas if e["categoria"] in cats]
        if not relevantes:
            return 0.0
        return min(1.0, sum(p for _, p in relevantes) / len(relevantes))

    hw = calc(CATS_HARDWARE)
    fl = calc(CATS_FLOW)
    fr = calc(CATS_FRICCION)

    # Señales especiales
    descenso = any(e["categoria"] == "descenso_crisis" for e, _ in detectadas)
    if descenso:
        fr *= 0.5

    flow_corrupto = [(e, p) for e, p in detectadas if e["categoria"] == "flow_corrupto"]
    if flow_corrupto:
        corr = sum(p for _, p in flow_corrupto) / len(flow_corrupto)
        fr = min(1.0, fr + corr * 0.3)

    absolutismo = sum(1 for e, _ in detectadas if e["categoria"] == "absolutismo")
    if absolutismo >= 2:
        fr = min(1.0, fr * 1.2)

    # Ecuación de estado
    estado = (hw * 0.4) + (fl * 0.3) - (fr * 0.3)

    # Modo
    if estado > 0.2:
        modo = "explorar"
    elif estado >= -0.1:
        modo = "sostener"
    else:
        modo = "contener"

    palabras = [e["palabra"] for e, _ in detectadas]
    categorias = list(set(e["categoria"] for e, _ in detectadas))

    return {
        "hardware": round(hw, 2),
        "flow": round(fl, 2),
        "friccion": round(fr, 2),
        "estado": round(estado, 2),
        "modo": modo,
        "palabras": palabras,
        "categorias": categorias,
        "descenso": descenso,
        "absolutismo": absolutismo >= 2,
    }


# --- PRUEBAS ---
tests = [
    ("no puedo más, estoy frito y no sé qué hacer", {}),
    ("estoy en la zona, con toda, vamos a chambear", {}),
    ("me pesa la vida, nadie me entiende, todo me sale mal", {}),
    ("ya estoy bien, me calmé, gracias me ayudó", {}),
    ("hypeado sin base, cabeza a mil, re manija", {}),
    ("pecho apretado, no me entra aire, corazón a mil", {}),
    ("hola qué onda", {}),
    ("no puedo más, estoy frito y no sé qué hacer", {"historial_fragil": True}),
]

print("=" * 60)
print("MARIS SCORER — TEST")
print("=" * 60)

for msg, perfil in tests:
    r = score(msg, **perfil)
    print(f'\n"{msg}"')
    if perfil:
        print(f"  (perfil: {perfil})")
    print(f"  HW={r['hardware']}  FL={r['flow']}  FR={r['friccion']}")
    print(f"  ESTADO={r['estado']}  MODO={r['modo']}")
    print(f"  Detectó: {r['palabras']}")
    print(f"  Categorías: {r['categorias']}")
    if r['descenso']:
        print(f"  ⬇️ DESCENSO DE CRISIS")
    if r['absolutismo']:
        print(f"  ⚠️ ABSOLUTISMO ACTIVO (fricción ×1.2)")
