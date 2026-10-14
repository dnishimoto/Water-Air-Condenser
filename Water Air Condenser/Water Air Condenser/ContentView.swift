
import SwiftUI
import SceneKit
import UIKit
import Combine
import Foundation

// MARK: - 1. Cellular Automaton Models

enum CondenserState: String {
    case off = "OFF"
    case on = "ON"
}

struct CAEnvironment {
    var temperatureC: Double
    var relativeHumidity: Double
    var solarKW: Double
    var condensationPotentialLPerHour: Double
}

struct CAState {
    var generation = 0
    var batterySOC: Double
    var batteryEnergyKWh: Double
    var tankLiters: Double

    var condenser: CondenserState = .off
    var consumerDemandLPerHour: Double = 0

    var waterSoldL: Double = 0
    var waterProducedL: Double = 0
    var condenserEnergyKWh: Double = 0
    var solarEnergyKWh: Double = 0
    var batteryDischargeKWh: Double = 0
    var batteryChargeKWh: Double = 0

    var totalWaterSoldL: Double = 0
    var totalWaterProducedL: Double = 0
    var totalCondenserEnergyKWh: Double = 0
    var totalSolarEnergyKWh: Double = 0
}

struct CAParameters {
    var startSOC: Double = 60
    var stopSOC: Double = 35
    var minimumReserveSOC: Double = 25

    var minimumCondensationRateLPerHour: Double = 0.1
    var targetTankFraction: Double = 0.85

    var batteryCapacityKWh: Double = 100
    var maximumBatteryDischargeKW: Double = 20

    var batteryChargeEfficiency: Double = 0.95
    var batteryDischargeEfficiency: Double = 0.95

    var condenserPowerKW: Double = 20
    var tankCapacityL: Double = 3_000
    var consumerDemandLPerHour: Double = 125
}

// MARK: - 2. Simulated Environment

struct CAEnvironmentProfile {
    var baseTemperatureC: Double = 30
    var baseRelativeHumidity: Double = 65

    var peakSolarKW: Double = 20.48
    var ratedCondensationLPerHour: Double = 125

    var dailyTemperatureSwingC: Double = 5
    var dailyHumiditySwingPercent: Double = 10

    func environment(forHour hour: Int) -> CAEnvironment {
        let h = Double((hour % 24 + 24) % 24)

        let solarFraction: Double
        if h >= 6 && h <= 18 {
            solarFraction = max(
                0,
                sin(Double.pi * (h - 6) / 12)
            )
        } else {
            solarFraction = 0
        }

        let phase = 2 * Double.pi * (h - 9) / 24

        let temperature = baseTemperatureC
            + dailyTemperatureSwingC * sin(phase)

        let humidity = min(
            100,
            max(
                0,
                baseRelativeHumidity
                    - dailyHumiditySwingPercent * sin(phase)
            )
        )

        // Illustrative estimate only. Replace with a validated
        // psychrometric and equipment-performance model.
        let humidityRatio = baseRelativeHumidity > 0
            ? humidity / baseRelativeHumidity
            : 0

        let condensationRate = max(
            0,
            ratedCondensationLPerHour * humidityRatio
        )

        return CAEnvironment(
            temperatureC: temperature,
            relativeHumidity: humidity,
            solarKW: peakSolarKW * solarFraction,
            condensationPotentialLPerHour: condensationRate
        )
    }
}

// MARK: - 3. Cellular Automaton Decision Rules

struct CellularAutomatonController {
    let parameters: CAParameters

    mutating func advance(
        state: inout CAState,
        environment: CAEnvironment,
        tankCapacityL: Double,
        durationHours: Double = 1
    ) -> CondenserState {

        state.generation += 1

        let dt = max(0, durationHours)
        let capacity = max(0, parameters.batteryCapacityKWh)
        let storedEnergy = min(
            capacity,
            max(0, state.batteryEnergyKWh)
        )

        let soc = capacity > 0
            ? storedEnergy / capacity * 100
            : 0

        state.batterySOC = soc
        state.batteryEnergyKWh = storedEnergy

        let tankCapacity = max(0, tankCapacityL)
        let tankFraction = tankCapacity > 0
            ? min(1, max(0, state.tankLiters / tankCapacity))
            : 1

        let hasDemand = state.consumerDemandLPerHour > 0
        let needsWater = tankFraction < parameters.targetTankFraction

        let canCondense =
            environment.condensationPotentialLPerHour
            >= parameters.minimumCondensationRateLPerHour

        let loadKWh = max(0, parameters.condenserPowerKW) * dt
        let solarKWh = max(0, environment.solarKW) * dt

        // Solar serves the load first.
        let batteryOutputNeededKWh = max(0, loadKWh - solarKWh)

        let reserveSOC = min(
            100,
            max(0, parameters.minimumReserveSOC)
        )

        let reserveKWh = capacity * reserveSOC / 100

        let usableStoredKWh = max(
            0,
            storedEnergy - reserveKWh
        )

        let dischargeEfficiency = min(
            1,
            max(0.01, parameters.batteryDischargeEfficiency)
        )

        let storedEnergyNeededKWh =
            batteryOutputNeededKWh / dischargeEfficiency

        let batteryPowerLimitKWh =
            max(0, parameters.maximumBatteryDischargeKW) * dt

        let enoughEnergy =
            storedEnergyNeededKWh <= usableStoredKWh + 0.000001
            && batteryOutputNeededKWh <= batteryPowerLimitKWh + 0.000001

        switch state.condenser {
        case .off:
            if hasDemand
                && needsWater
                && canCondense
                && enoughEnergy
                && soc >= parameters.startSOC {
                state.condenser = .on
            }

        case .on:
            if !hasDemand
                || !needsWater
                || !canCondense
                || !enoughEnergy
                || soc <= parameters.stopSOC {
                state.condenser = .off
            }
        }

        return state.condenser
    }

    @discardableResult
    mutating func processConsumerPurchase(
        state: inout CAState,
        requestedLiters: Double
    ) -> Double {
        let purchased = min(
            max(0, state.tankLiters),
            max(0, requestedLiters)
        )

        state.tankLiters = max(0, state.tankLiters - purchased)
        state.waterSoldL = purchased
        state.totalWaterSoldL += purchased

        return purchased
    }
}

// MARK: - 4. Hourly History

struct HourlySimulationRecord: Identifiable {
    let id: Int
    let hour: Int

    let environment: CAEnvironment
    let condenser: CondenserState

    let batterySOC: Double
    let batteryEnergyKWh: Double
    let tankLiters: Double

    let waterProducedL: Double
    let waterSoldL: Double

    let solarPowerKW: Double
    let condenserPowerKW: Double

    let solarEnergyKWh: Double
    let batteryDischargeKWh: Double
    let batteryChargeKWh: Double

    let cumulativeCondenserEnergyKWh: Double
}

// MARK: - 5. Complete Hourly Simulation

struct AtmosphericWaterSimulator {
    var parameters: CAParameters
    var environmentProfile: CAEnvironmentProfile

    var state: CAState
    var controller: CellularAutomatonController

    var history: [HourlySimulationRecord] = []

    init(
        parameters: CAParameters = CAParameters(),
        environmentProfile: CAEnvironmentProfile =
            CAEnvironmentProfile(),
        initialBatterySOC: Double = 80,
        initialTankLiters: Double = 500
    ) {
        self.parameters = parameters
        self.environmentProfile = environmentProfile

        let capacity = max(0, parameters.batteryCapacityKWh)
        let soc = min(100, max(0, initialBatterySOC))

        self.state = CAState(
            batterySOC: soc,
            batteryEnergyKWh: capacity * soc / 100,
            tankLiters: min(
                max(0, parameters.tankCapacityL),
                max(0, initialTankLiters)
            )
        )

        self.controller = CellularAutomatonController(
            parameters: parameters
        )
    }

    @discardableResult
    mutating func advanceOneHour() -> HourlySimulationRecord {
        let dt = 1.0
        let hour = state.generation % 24

        let environment = environmentProfile.environment(
            forHour: hour
        )

        state.waterProducedL = 0
        state.waterSoldL = 0
        state.condenserEnergyKWh = 0
        state.solarEnergyKWh = 0
        state.batteryDischargeKWh = 0
        state.batteryChargeKWh = 0

        // Consumer demand is the quantity requested this hour.
        state.consumerDemandLPerHour = max(
            0,
            parameters.consumerDemandLPerHour
        )

        // CA makes the ON/OFF decision.
        let decision = controller.advance(
            state: &state,
            environment: environment,
            tankCapacityL: parameters.tankCapacityL,
            durationHours: dt
        )

        let batteryCapacity = max(
            0,
            parameters.batteryCapacityKWh
        )

        let batteryBefore = min(
            batteryCapacity,
            max(0, state.batteryEnergyKWh)
        )

        let reserveKWh = batteryCapacity
            * min(100, max(0, parameters.minimumReserveSOC)) / 100

        let solarGeneratedKWh = max(0, environment.solarKW) * dt

        let requestedPowerKW = decision == .on
            ? max(0, parameters.condenserPowerKW)
            : 0

        let requestedLoadKWh = requestedPowerKW * dt

        // Allocate solar directly to the condenser first.
        let solarToLoadKWh = min(
            solarGeneratedKWh,
            requestedLoadKWh
        )

        let remainingLoadKWh = max(
            0,
            requestedLoadKWh - solarToLoadKWh
        )

        let efficiency = min(
            1,
            max(0.01, parameters.batteryDischargeEfficiency)
        )

        let usableStoredKWh = max(
            0,
            batteryBefore - reserveKWh
        )

        let batteryOutputLimitKWh =
            max(0, parameters.maximumBatteryDischargeKW) * dt

        let batteryOutputKWh = min(
            remainingLoadKWh,
            batteryOutputLimitKWh,
            usableStoredKWh * efficiency
        )

        let energyRemovedFromBatteryKWh =
            batteryOutputKWh / efficiency

        // Never create energy by raising a depleted battery to its reserve.
        state.batteryEnergyKWh = max(
            0,
            batteryBefore - energyRemovedFromBatteryKWh
        )

        let deliveredLoadKWh = solarToLoadKWh + batteryOutputKWh

        let runtimeFraction: Double
        if requestedLoadKWh > 0 {
            runtimeFraction = min(
                1,
                deliveredLoadKWh / requestedLoadKWh
            )
        } else {
            runtimeFraction = 0
        }

        state.condenserEnergyKWh = deliveredLoadKWh
        state.totalCondenserEnergyKWh += deliveredLoadKWh

        state.solarEnergyKWh = solarGeneratedKWh
        state.totalSolarEnergyKWh += solarGeneratedKWh

        state.batteryDischargeKWh = energyRemovedFromBatteryKWh

        // Charge the battery with surplus solar energy.
        let surplusSolarKWh = max(
            0,
            solarGeneratedKWh - solarToLoadKWh
        )

        let chargeEfficiency = min(
            1,
            max(0, parameters.batteryChargeEfficiency)
        )

        let storageSpaceKWh = max(
            0,
            batteryCapacity - state.batteryEnergyKWh
        )

        let solarChargeLimitKWh: Double
        if chargeEfficiency > 0 {
            solarChargeLimitKWh = storageSpaceKWh / chargeEfficiency
        } else {
            solarChargeLimitKWh = 0
        }

        let solarAcceptedKWh = min(
            surplusSolarKWh,
            solarChargeLimitKWh
        )

        let storedChargeKWh = solarAcceptedKWh * chargeEfficiency

        state.batteryEnergyKWh = min(
            batteryCapacity,
            state.batteryEnergyKWh + storedChargeKWh
        )

        state.batteryChargeKWh = storedChargeKWh

        // Produce water only while the condenser is supplied with power.
        let potentialProductionL =
            max(0, environment.condensationPotentialLPerHour)
            * dt
            * runtimeFraction

        let tankCapacity = max(0, parameters.tankCapacityL)
        let freeSpaceL = max(
            0,
            tankCapacity - state.tankLiters
        )

        let producedL = min(potentialProductionL, freeSpaceL)

        state.tankLiters = min(
            tankCapacity,
            max(0, state.tankLiters + producedL)
        )

        state.waterProducedL = producedL
        state.totalWaterProducedL += producedL

        // Sales occur after production in this simulated hour.
        let soldL = controller.processConsumerPurchase(
            state: &state,
            requestedLiters: state.consumerDemandLPerHour * dt
        )

        state.batterySOC = batteryCapacity > 0
            ? 100 * state.batteryEnergyKWh / batteryCapacity
            : 0

        let actualPowerKW = dt > 0
            ? deliveredLoadKWh / dt
            : 0

        let record = HourlySimulationRecord(
            id: state.generation,
            hour: hour,
            environment: environment,
            condenser: decision,
            batterySOC: state.batterySOC,
            batteryEnergyKWh: state.batteryEnergyKWh,
            tankLiters: state.tankLiters,
            waterProducedL: producedL,
            waterSoldL: soldL,
            solarPowerKW: environment.solarKW,
            condenserPowerKW: actualPowerKW,
            solarEnergyKWh: solarGeneratedKWh,
            batteryDischargeKWh: energyRemovedFromBatteryKWh,
            batteryChargeKWh: storedChargeKWh,
            cumulativeCondenserEnergyKWh:
                state.totalCondenserEnergyKWh
        )

        history.append(record)
        return record
    }

    mutating func runHours(_ count: Int) -> [HourlySimulationRecord] {
        guard count > 0 else { return [] }

        var results: [HourlySimulationRecord] = []

        for _ in 0..<count {
            results.append(advanceOneHour())
        }

        return results
    }

    mutating func reset() {
        self = AtmosphericWaterSimulator(
            parameters: parameters,
            environmentProfile: environmentProfile
        )
    }
}

// MARK: - 6. SwiftUI View Model

@MainActor
final class WaterSystemViewModel: ObservableObject {
    @Published private(set) var simulator: AtmosphericWaterSimulator
    @Published private(set) var latestRecord: HourlySimulationRecord?
    @Published private(set) var records: [HourlySimulationRecord] = []

    init() {
        let initial = AtmosphericWaterSimulator()
        self.simulator = initial
    }

    func advanceOneHour() {
        let record = simulator.advanceOneHour()
        latestRecord = record
        records = simulator.history
    }

    func runOneDay() {
        _ = simulator.runHours(24)
        latestRecord = simulator.history.last
        records = simulator.history
    }

    func reset() {
        simulator.reset()
        latestRecord = nil
        records = []
    }
}

// MARK: - 7. Main iOS ContentView

struct ContentView: View {
    @StateObject private var model = WaterSystemViewModel()
    @State private var isPlaying = false

    private let playbackTimer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    private var parameters: CAParameters {
        model.simulator.parameters
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header

                    System3DView(
                        record: model.latestRecord,
                        batteryCapacityKWh: parameters.batteryCapacityKWh,
                        tankCapacityL: parameters.tankCapacityL
                    )
                    .frame(height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    controlPanel
                    environmentPanel
                    capacityPanel
                    energyPanel
                    historyPanel

                    Text(
                        "Simulation only. Water output and energy use are illustrative estimates, not measured equipment performance."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle("Atmospheric Water")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(playbackTimer) { _ in
                if isPlaying {
                    model.advanceOneHour()
                }
            }
            .onDisappear {
                isPlaying = false
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Atmospheric Water System")
                .font(.title2.bold())

            Text("Cellular automaton · Solar · Battery · Condenser · Water sales")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Label(
                    model.latestRecord?.condenser.rawValue ?? "READY",
                    systemImage: model.latestRecord?.condenser == .on
                        ? "fanblades"
                        : "pause.circle"
                )
                .font(.headline)
                .foregroundStyle(
                    model.latestRecord?.condenser == .on
                        ? .green
                        : .secondary
                )

                Spacer()

                Text(
                    "Generation \(model.simulator.state.generation)"
                )
                .font(.subheadline.monospacedDigit())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Simulation Controls")
                .font(.headline)

            HStack(spacing: 10) {
                Button {
                    model.advanceOneHour()
                } label: {
                    Label("Advance 1 Hour", systemImage: "forward.end")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    isPlaying.toggle()
                } label: {
                    Label(
                        isPlaying ? "Pause" : "Play",
                        systemImage: isPlaying ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 10) {
                Button {
                    isPlaying = false
                    model.runOneDay()
                } label: {
                    Label("Run 24 Hours", systemImage: "calendar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    isPlaying = false
                    model.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Text("Playback advances one simulated hour per second.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var environmentPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Environment")
                .font(.headline)

            let environment = model.latestRecord?.environment

            metricRow(
                "Temperature",
                value: environment.map {
                    String(format: "%.1f °C", $0.temperatureC)
                } ?? "—",
                symbol: "thermometer.medium"
            )

            metricRow(
                "Relative humidity",
                value: environment.map {
                    String(format: "%.1f%%", $0.relativeHumidity)
                } ?? "—",
                symbol: "humidity"
            )

            metricRow(
                "Solar array output",
                value: environment.map {
                    String(format: "%.2f kW", $0.solarKW)
                } ?? "—",
                symbol: "sun.max"
            )

            metricRow(
                "Estimated condensation potential",
                value: environment.map {
                    String(
                        format: "%.1f L/h",
                        $0.condensationPotentialLPerHour
                    )
                } ?? "—",
                symbol: "drop"
            )
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var capacityPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("System Capacity")
                .font(.headline)

            let state = model.simulator.state

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Battery", systemImage: "battery.75percent")
                    Spacer()
                    Text(
                        String(
                            format: "%.1f%% · %.1f / %.1f kWh",
                            state.batterySOC,
                            state.batteryEnergyKWh,
                            parameters.batteryCapacityKWh
                        )
                    )
                    .monospacedDigit()
                }

                ProgressView(
                    value: min(1, max(0, state.batterySOC / 100))
                )
                .tint(.green)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Water tank", systemImage: "water.waves")
                    Spacer()
                    Text(
                        String(
                            format: "%.0f / %.0f L",
                            state.tankLiters,
                            parameters.tankCapacityL
                        )
                    )
                    .monospacedDigit()
                }

                ProgressView(
                    value: parameters.tankCapacityL > 0
                        ? min(
                            1,
                            max(
                                0,
                                state.tankLiters / parameters.tankCapacityL
                            )
                        )
                        : 0
                )
                .tint(.blue)
            }

            HStack(spacing: 12) {
                smallMetric(
                    title: "Produced",
                    value: String(
                        format: "%.1f L",
                        state.totalWaterProducedL
                    )
                )

                smallMetric(
                    title: "Sold",
                    value: String(
                        format: "%.1f L",
                        state.totalWaterSoldL
                    )
                )
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var energyPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Energy Meter")
                .font(.headline)

            let state = model.simulator.state

            metricRow(
                "Condenser power this hour",
                value: String(
                    format: "%.2f kW",
                    state.condenserEnergyKWh
                ),
                symbol: "bolt.fill"
            )

            metricRow(
                "Cumulative condenser energy",
                value: String(
                    format: "%.2f kWh",
                    state.totalCondenserEnergyKWh
                ),
                symbol: "gauge.with.dots.needle.50percent"
            )

            metricRow(
                "Solar generated this hour",
                value: String(
                    format: "%.2f kWh",
                    state.solarEnergyKWh
                ),
                symbol: "sun.max.fill"
            )

            metricRow(
                "Battery energy removed",
                value: String(
                    format: "%.2f kWh",
                    state.batteryDischargeKWh
                ),
                symbol: "battery.25percent"
            )

            metricRow(
                "Battery energy stored",
                value: String(
                    format: "%.2f kWh",
                    state.batteryChargeKWh
                ),
                symbol: "battery.100percent"
            )
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var historyPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Hourly Results")
                .font(.headline)

            if model.records.isEmpty {
                Text("Advance the simulation to create hourly records.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(model.records.suffix(8).reversed()) { record in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(
                                String(
                                    format: "Hour %02d",
                                    record.hour
                                )
                            )
                            .font(.subheadline.bold())

                            Spacer()

                            Text(record.condenser.rawValue)
                                .font(.caption.bold())
                                .foregroundStyle(
                                    record.condenser == .on
                                        ? .green
                                        : .secondary
                                )
                        }

                        Text(
                            String(
                                format:
                                    "Battery %.1f%% · Tank %.0f L · Produced %.1f L · Sold %.1f L",
                                record.batterySOC,
                                record.tankLiters,
                                record.waterProducedL,
                                record.waterSoldL
                            )
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Text(
                            String(
                                format:
                                    "Solar %.2f kW · Condenser %.2f kW · Used %.2f kWh",
                                record.solarPowerKW,
                                record.condenserPowerKW,
                                record.cumulativeCondenserEnergyKWh
                            )
                        )
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                    }

                    Divider()
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func metricRow(
        _ title: String,
        value: String,
        symbol: String
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .frame(width: 24)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.subheadline)

            Spacer(minLength: 8)

            Text(value)
                .font(.subheadline.monospacedDigit().weight(.medium))
                .multilineTextAlignment(.trailing)
        }
    }

    private func smallMetric(
        title: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.bold().monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 8. iOS SceneKit 3D View

struct System3DView: UIViewRepresentable {
    let record: HourlySimulationRecord?
    let batteryCapacityKWh: Double
    let tankCapacityL: Double

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()

        view.scene = scene
        view.backgroundColor = UIColor(
            red: 0.035,
            green: 0.075,
            blue: 0.14,
            alpha: 1
        )

        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X

        context.coordinator.buildScene(scene: scene)
        context.coordinator.update(record: record)

        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.update(record: record)
    }

    final class Coordinator {
        private var waterNode: SCNNode?
        private var batteryFillNode: SCNNode?
        private var fanNode: SCNNode?

        private let tankHeight: CGFloat = 2.5
        private let tankBaseY: Float = 0.25
        private let batteryHeight: CGFloat = 2.0
        private let batteryBaseY: Float = 0.2

        func buildScene(scene: SCNScene) {
            let root = scene.rootNode

            // Ground.
            let ground = SCNFloor()
            ground.reflectivity = 0

            let groundNode = SCNNode(geometry: ground)
            groundNode.geometry?.firstMaterial?.diffuse.contents =
                UIColor(red: 0.12, green: 0.17, blue: 0.24, alpha: 1)
            root.addChildNode(groundNode)

            // Camera.
            let camera = SCNCamera()
            camera.fieldOfView = 55

            let cameraNode = SCNNode()
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(0, 5.0, 12.5)
            cameraNode.look(
                at: SCNVector3(0, 1.0, 0)
            )
            root.addChildNode(cameraNode)

            // Lighting.
            let light = SCNLight()
            light.type = .omni
            light.intensity = 1100

            let lightNode = SCNNode()
            lightNode.light = light
            lightNode.position = SCNVector3(0, 8, 6)
            root.addChildNode(lightNode)

            let ambient = SCNLight()
            ambient.type = .ambient
            ambient.intensity = 350

            let ambientNode = SCNNode()
            ambientNode.light = ambient
            root.addChildNode(ambientNode)

            // Solar array: six illustrative panel modules.
            for row in 0..<2 {
                for column in 0..<3 {
                    let panel = SCNBox(
                        width: 1.15,
                        height: 0.07,
                        length: 0.78,
                        chamferRadius: 0.025
                    )

                    panel.firstMaterial?.diffuse.contents =
                        UIColor(red: 0.06, green: 0.30, blue: 0.70, alpha: 1)

                    panel.firstMaterial?.metalness.contents = 0.25

                    let panelNode = SCNNode(geometry: panel)
                    panelNode.position = SCNVector3(
                        Float(column) * 1.25 - 4.0,
                        0.85 + Float(row) * 0.05,
                        -1.0 - Float(row) * 0.65
                    )
                    panelNode.eulerAngles.x = -0.15

                    root.addChildNode(panelNode)

                    // Panel grid lines.
                    for line in 1..<3 {
                        let gridLine = SCNBox(
                            width: 0.012,
                            height: 0.075,
                            length: 0.78,
                            chamferRadius: 0
                        )
                        gridLine.firstMaterial?.diffuse.contents =
                            UIColor.lightGray

                        let lineNode = SCNNode(geometry: gridLine)
                        lineNode.position = SCNVector3(
                            Float(line) * 0.35 - 0.525,
                            0,
                            0
                        )
                        panelNode.addChildNode(lineNode)
                    }
                }
            }

            // Condenser casing.
            let condenser = SCNBox(
                width: 2.0,
                height: 2.2,
                length: 1.5,
                chamferRadius: 0.12
            )
            condenser.firstMaterial?.diffuse.contents =
                UIColor(red: 0.34, green: 0.41, blue: 0.49, alpha: 1)

            let condenserNode = SCNNode(geometry: condenser)
            condenserNode.position = SCNVector3(-3.0, 1.2, 1.0)
            root.addChildNode(condenserNode)

            // Fan face.
            let fan = SCNNode()
            fan.position = SCNVector3(-3.0, 1.35, 1.78)
            root.addChildNode(fan)
            fanNode = fan

            let hub = SCNSphere(radius: 0.16)
            hub.firstMaterial?.diffuse.contents = UIColor.white

            let hubNode = SCNNode(geometry: hub)
            fan.addChildNode(hubNode)

            for index in 0..<4 {
                let blade = SCNBox(
                    width: 0.16,
                    height: 0.75,
                    length: 0.07,
                    chamferRadius: 0.05
                )

                blade.firstMaterial?.diffuse.contents =
                    UIColor(red: 0.15, green: 0.78, blue: 0.93, alpha: 1)

                let bladeNode = SCNNode(geometry: blade)
                bladeNode.eulerAngles.z =
                    Float(index) * .pi / 2
                fan.addChildNode(bladeNode)
            }

            // Transparent water tank.
            let tankShell = SCNCylinder(
                radius: 0.9,
                height: tankHeight
            )

            let shellMaterial = SCNMaterial()
            shellMaterial.diffuse.contents =
                UIColor(red: 0.45, green: 0.78, blue: 0.95, alpha: 0.17)
            shellMaterial.transparency = 0.28
            shellMaterial.isDoubleSided = true
            tankShell.materials = [shellMaterial]

            let tankNode = SCNNode(geometry: tankShell)
            tankNode.position = SCNVector3(0, 1.5, 0)
            root.addChildNode(tankNode)

            let waterGeometry = SCNCylinder(
                radius: 0.82,
                height: tankHeight
            )

            let waterMaterial = SCNMaterial()
            waterMaterial.diffuse.contents =
                UIColor(red: 0.02, green: 0.47, blue: 0.95, alpha: 0.85)
            waterMaterial.transparency = 0.9
            waterMaterial.isDoubleSided = true
            waterGeometry.materials = [waterMaterial]

            let water = SCNNode(geometry: waterGeometry)
            water.scale.y = 0
            water.position = SCNVector3(0, tankBaseY, 0)
            root.addChildNode(water)
            waterNode = water

            // Tank rim.
            let rim = SCNTorus(
                ringRadius: 0.9,
                pipeRadius: 0.035
            )
            rim.firstMaterial?.diffuse.contents = UIColor.lightGray

            let rimNode = SCNNode(geometry: rim)
            rimNode.position = SCNVector3(0, 2.78, 0)
            root.addChildNode(rimNode)

            // Battery housing.
            let battery = SCNBox(
                width: 1.3,
                height: 2.3,
                length: 1.2,
                chamferRadius: 0.12
            )
            battery.firstMaterial?.diffuse.contents =
                UIColor(red: 0.23, green: 0.27, blue: 0.32, alpha: 1)

            let batteryNode = SCNNode(geometry: battery)
            batteryNode.position = SCNVector3(3.0, 1.2, 0)
            root.addChildNode(batteryNode)

            // Battery fill.
            let fill = SCNBox(
                width: 0.88,
                height: batteryHeight,
                length: 0.76,
                chamferRadius: 0.04
            )
            fill.firstMaterial?.diffuse.contents = UIColor.systemGreen

            let fillNode = SCNNode(geometry: fill)
            fillNode.position = SCNVector3(
                3.0,
                batteryBaseY,
                0.64
            )
            fillNode.scale.y = 0

            root.addChildNode(fillNode)
            batteryFillNode = fillNode

            // Battery terminals.
            let terminal = SCNBox(
                width: 0.35,
                height: 0.12,
                length: 0.28,
                chamferRadius: 0.025
            )
            terminal.firstMaterial?.diffuse.contents = UIColor.gray

            let terminalNode = SCNNode(geometry: terminal)
            terminalNode.position = SCNVector3(3.0, 2.4, 0)
            root.addChildNode(terminalNode)

            // A small light indicates system operation.
            let indicator = SCNSphere(radius: 0.09)
            indicator.firstMaterial?.diffuse.contents = UIColor.orange

            let indicatorNode = SCNNode(geometry: indicator)
            indicatorNode.position = SCNVector3(-3.0, 2.5, 1.0)
            root.addChildNode(indicatorNode)

            // Camera-facing labels are provided by SwiftUI overlays.
        }

        func update(record: HourlySimulationRecord?) {
            guard let record else {
                setWaterFraction(0)
                setBatteryFraction(0)
                stopFan()
                return
            }

            setWaterFraction(
                record.tankLiters
                    // Capacity is supplied to the parent view. The scene
                    // uses a 3,000 L reference scale for its tank geometry.
                    / 3_000
            )

            setBatteryFraction(record.batterySOC / 100)

            if record.condenser == .on
                && record.condenserPowerKW > 0 {
                startFan()
            } else {
                stopFan()
            }
        }

        private func setWaterFraction(_ value: Double) {
            guard let waterNode else { return }

            let fraction = min(1, max(0, value))
            let height = Float(tankHeight) * Float(fraction)

            waterNode.removeAllActions()

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            waterNode.scale.y = Float(fraction)
            waterNode.position.y =
                tankBaseY + height / 2
            SCNTransaction.commit()
        }

        private func setBatteryFraction(_ value: Double) {
            guard let batteryFillNode else { return }

            let fraction = min(1, max(0, value))
            let height = Float(batteryHeight) * Float(fraction)

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            batteryFillNode.scale.y = Float(fraction)
            batteryFillNode.position.y =
                batteryBaseY + height / 2
            SCNTransaction.commit()
        }

        private func startFan() {
            guard let fanNode else { return }

            if fanNode.action(forKey: "fanRotation") == nil {
                let rotate = SCNAction.rotateBy(
                    x: 0,
                    y: 0,
                    z: CGFloat.pi * 2,
                    duration: 0.45
                )

                fanNode.runAction(
                    .repeatForever(rotate),
                    forKey: "fanRotation"
                )
            }
        }

        private func stopFan() {
            fanNode?.removeAction(forKey: "fanRotation")
        }
    }
}

// MARK: - 9. Preview

#Preview {
    ContentView()
}
