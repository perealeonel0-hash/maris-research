import Foundation

// MARK: - Models

struct DictionaryEntry: Codable {
    let palabra: String
    let categoria: String
    let peso_base: Double
    let tipo: String
    let region: String
    let nota: String?
}

struct UsuarioPerfil {
    let historialFragil: Bool
    let deformacion: Double
    let scarsRecientes: Bool
}

struct TransitionSignal {
    let longitudCambio: Bool
    let erroresTipograficos: Bool
    let puntuacionAusente: Bool
    let friccionSubita: Bool

    var count: Int {
        [longitudCambio, erroresTipograficos, puntuacionAusente, friccionSubita]
            .filter { $0 }.count
    }
}

struct MARISScore {
    let hardware: Double
    let flow: Double
    let friccion: Double
    let estado: Double
    let palabrasDetectadas: [String]
    let categoriasActivas: [String]
    let señalTransicion: Bool
    let descensoCrisis: Bool
    let absolutismoActivo: Bool

    var modo: String {
        if estado > 0.2 { return "explorar" }
        if estado >= -0.1 { return "sostener" }
        return "contener"
    }
}

// MARK: - Scorer

final class MARISScorer {

    private let diccionario: [DictionaryEntry]
    private var mensajeAnterior: String?
    private var friccionAnterior: Double = 0.0

    // Categorías agrupadas por score
    private let categoriasHardware = ["hardware_accion"]
    private let categoriasFlow = ["flow_genuino"]
    private let categoriasFriccion = [
        "friccion_alta", "friccion_media", "ansiedad_somatica",
        "panico", "paralisis", "agotamiento", "absolutismo",
        "culpa", "rabia", "disociacion"
    ]
    private let categoriasExcluirFriccion = ["friccion_util", "descenso_crisis"]

    // MARK: - Init

    init() {
        guard let url = Bundle.main.url(forResource: "diccionario_v1", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([DictionaryEntry].self, from: data) else {
            self.diccionario = []
            print("[MARISScorer] ERROR: No se pudo cargar diccionario_v1.json")
            return
        }
        self.diccionario = entries
        print("[MARISScorer] Diccionario cargado: \(entries.count) entradas")
    }

    // MARK: - Score

    func score(mensaje: String, perfil: UsuarioPerfil) -> MARISScore {

        // 1. Tokenizar
        let msgLower = mensaje.lowercased()
            .replacingOccurrences(of: "[^a-záéíóúñü\\s]", with: "", options: .regularExpression)

        // 2. Buscar coincidencias
        var detectadas: [(DictionaryEntry, Double)] = []

        for entry in diccionario {
            if msgLower.contains(entry.palabra.lowercased()) {
                let pesoFinal = entry.peso_base * multiplicador(perfil: perfil)
                detectadas.append((entry, pesoFinal))
            }
        }

        let palabras = detectadas.map { $0.0.palabra }
        let categorias = Array(Set(detectadas.map { $0.0.categoria }))

        // 3. Calcular scores por grupo
        let hw = calcularScore(detectadas: detectadas, categorias: categoriasHardware)
        let fl = calcularScore(detectadas: detectadas, categorias: categoriasFlow)
        var fr = calcularScore(detectadas: detectadas, categorias: categoriasFriccion)

        // 4. Señales especiales

        // Descenso de crisis: reducir fricción ×0.5
        let descenso = detectadas.contains { $0.0.categoria == "descenso_crisis" }
        if descenso {
            fr *= 0.5
        }

        // Flow corrupto: NO suma a flow, suma a fricción ×0.3
        let flowCorrupto = detectadas.filter { $0.0.categoria == "flow_corrupto" }
        if !flowCorrupto.isEmpty {
            let corruptoScore = flowCorrupto.map { $0.1 }.reduce(0, +) / Double(max(flowCorrupto.count, 1))
            fr = min(1.0, fr + corruptoScore * 0.3)
        }

        // Absolutismo: 2+ palabras = fricción ×1.2
        let absolutismoCount = detectadas.filter { $0.0.categoria == "absolutismo" }.count
        let absolutismoActivo = absolutismoCount >= 2
        if absolutismoActivo {
            fr = min(1.0, fr * 1.2)
        }

        // 5. Ecuación de estado
        let estado = (hw * 0.4) + (fl * 0.3) - (fr * 0.3)

        // 6. Señal de transición
        let transicion = detectarTransicion(mensajeActual: mensaje, friccionActual: fr)

        // 7. Guardar para próxima comparación
        self.mensajeAnterior = mensaje
        self.friccionAnterior = fr

        return MARISScore(
            hardware: round(hw, 2),
            flow: round(fl, 2),
            friccion: round(fr, 2),
            estado: round(estado, 2),
            palabrasDetectadas: palabras,
            categoriasActivas: categorias,
            señalTransicion: transicion.count >= 3,
            descensoCrisis: descenso,
            absolutismoActivo: absolutismoActivo
        )
    }

    // MARK: - Helpers

    private func multiplicador(perfil: UsuarioPerfil) -> Double {
        if perfil.historialFragil { return 1.5 }
        if perfil.deformacion > 0.3 { return 1.3 }
        if perfil.scarsRecientes { return 1.4 }
        return 1.0
    }

    private func calcularScore(detectadas: [(DictionaryEntry, Double)], categorias: [String]) -> Double {
        let relevantes = detectadas.filter { categorias.contains($0.0.categoria) }
        if relevantes.isEmpty { return 0.0 }
        let suma = relevantes.map { $0.1 }.reduce(0, +)
        return min(1.0, suma / Double(relevantes.count))
    }

    private func detectarTransicion(mensajeActual: String, friccionActual: Double) -> TransitionSignal {
        guard let anterior = mensajeAnterior else {
            return TransitionSignal(
                longitudCambio: false,
                erroresTipograficos: false,
                puntuacionAusente: false,
                friccionSubita: false
            )
        }

        // Longitud cae >50%
        let longitudCambio = mensajeActual.count < anterior.count / 2

        // Errores tipográficos: palabras muy cortas o caracteres repetidos
        let palabras = mensajeActual.split(separator: " ")
        let posiblesErrores = palabras.filter { $0.count <= 2 && $0.count > 0 }.count
        let errores = posiblesErrores > 2

        // Puntuación ausente: anterior tenía, actual no
        let anteriorTeniaPuntuacion = anterior.contains(".") || anterior.contains(",") || anterior.contains("!")
        let actualSinPuntuacion = !mensajeActual.contains(".") && !mensajeActual.contains(",") && !mensajeActual.contains("!")
        let puntuacionAusente = anteriorTeniaPuntuacion && actualSinPuntuacion

        // Fricción súbita: sube >0.3 en un turno
        let friccionSubita = (friccionActual - friccionAnterior) > 0.3

        return TransitionSignal(
            longitudCambio: longitudCambio,
            erroresTipograficos: errores,
            puntuacionAusente: puntuacionAusente,
            friccionSubita: friccionSubita
        )
    }

    private func round(_ value: Double, _ places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (value * divisor).rounded() / divisor
    }
}
