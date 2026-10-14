/*
 # Water-Air Condenser: Complete Operational Pipeline

 The Water-Air Condenser system operates as an integrated energy-generation, atmospheric-water-production, storage, and distribution system. Its pipeline begins with environmental measurements and solar energy generation, proceeds through power management, air intake, cooling, condensation, water treatment, and storage, and concludes with consumer dispensing, revenue accounting, and feedback control. The cellular automaton (CA) coordinates these processes by evaluating system conditions, updating component states, enforcing operating constraints, and determining which actions should occur during each simulation step.

 1\. Environmental monitoring and atmospheric moisture assessment. The process begins by measuring or estimating ambient temperature, relative humidity, atmospheric pressure, solar irradiance, and available airflow. These environmental conditions determine how much water vapor is present in the atmosphere and how much energy may be available to operate the system. The CA calculates the dew point, which indicates the temperature at which air becomes saturated under the modeled conditions. The mass of water vapor entering the condenser is determined by multiplying the dry-air mass flow rate by the incoming humidity ratio. The system uses this calculation to estimate the maximum recoverable water before considering equipment limitations. If the air contains little moisture, the CA must reduce its expected production rather than assume that the condenser will generate water at a constant rate.

 2\. Solar power generation. Solar panels convert incoming sunlight into electrical power. The CA calculates available solar power using solar irradiance, panel area, panel efficiency, and any applicable temperature or conversion-loss adjustments. Solar energy generated over a simulation interval equals the average electrical power generated multiplied by the elapsed time. The resulting energy is made available to the system's electrical power bus. The model must account for the distinction between instantaneous power, measured in kilowatts, and accumulated energy, measured in kilowatt-hours. This distinction is necessary for correctly determining whether the system can operate its condenser continuously or only during periods of sufficient sunlight.

 3\. Electrical power management and battery control. The power-management subsystem distributes available electricity among the condenser, fans, pumps, treatment equipment, control electronics, and other active loads. The battery stores surplus energy and supplies power when solar generation is insufficient, subject to its permitted charging and discharging limits. The battery's new stored energy equals its previous stored energy plus charging energy multiplied by charging efficiency, minus discharged energy divided by discharge efficiency. The battery state of charge equals stored energy divided by usable battery capacity, multiplied by one hundred. The CA must account for electrical conversion losses, charging limits, startup surges, and minimum reserve requirements. If available power becomes insufficient, the controller must prioritize essential functions, reduce nonessential loads, or shut down the condenser safely.

 4\. Air intake, filtration, and airflow regulation. Once the system has sufficient power and passes its startup checks, fans draw atmospheric air through the intake and filtration assembly. The system calculates or measures airflow and determines the quantity of dry air processed during each simulation interval. Filters remove the contaminants they are designed to capture, while pressure drop across the filters and heat exchanger can affect airflow and fan energy consumption. The CA monitors whether airflow is within the condenser's operating range. If airflow becomes restricted, a fan fails, or environmental conditions change, the controller adjusts expected production and power consumption accordingly. Airflow is a critical input because the condenser cannot collect moisture from air that does not pass through its heat exchanger.

 5\. Refrigeration, cooling, and heat exchange. The condenser cools incoming air so that water vapor can condense into liquid water. The precise cooling process depends on the selected equipment architecture. For a conventional compressor-based system, the refrigeration circuit includes an evaporator, compressor, condenser, expansion device, and refrigerant circulation. The heat exchanger removes sensible heat as the air cools and latent heat as water vapor condenses. The total cooling requirement equals the sensible cooling load plus the latent heat removed during condensation and any other modeled thermal loads. The coefficient of performance, or COP, equals useful cooling delivered divided by electrical energy consumed. The CA must consider available cooling capacity, heat rejection, heat-exchanger effectiveness, thermal inertia, and compressor operating limits. Condensation becomes possible when the cooling surface is sufficiently below the incoming air's dew point and the other physical conditions support moisture removal.

 6\. Condensation, drainage, and water production measurement. As air passes through the cooled heat exchanger, some of its water vapor becomes liquid condensate. The mass of water condensed equals the mass of dry air processed multiplied by the difference between the incoming and outgoing humidity ratios, provided that the difference is positive and the calculation respects the available cooling capacity. The water-production rate in liters per hour equals the mass of condensed water per hour divided by the density of liquid water. The model must account for collection inefficiency, drainage losses, equipment downtime, and environmental limitations. A water-production meter then records the calculated quantity of condensate. The CA must distinguish theoretical production from actual production so that switching on the condenser does not automatically generate water without the necessary airflow, moisture, cooling, and energy.

 7\. Water treatment and quality verification. The collected condensate enters a treatment stage designed for the intended use of the water. Depending on the system design, treatment may include filtration, disinfection, and mineral adjustment. The quantity of usable water equals collected condensate minus treatment losses and rejected water. The water-quality control module evaluates the modeled treatment process and determines whether the water meets the specified acceptance criteria. Water that fails verification must be isolated, rejected, or routed for additional treatment rather than being added to the usable-water inventory. If the intended output is potable water, the actual design must address relevant microbial and chemical hazards and comply with applicable water-quality requirements. Condensation alone does not establish that water is safe to drink.

 8\. Water storage and tank-level management. Approved water flows into the storage tank, where the CA maintains a running water balance. The new tank volume equals the previous tank volume plus usable water added, minus water dispensed and other modeled losses. Tank volume must never fall below zero or exceed the tank's physical capacity. Tank fill percentage equals current stored volume divided by tank capacity, multiplied by one hundred. The CA uses these values to regulate incoming water, prevent overflow, and determine whether additional production should continue. The 3D tank animation must be driven directly by the calculated stored volume, so the visible water level increases during production and decreases during dispensing. If the tank is full, the controller must stop or redirect incoming water according to the system design.

 9\. Consumer demand, dispensing, and purchase validation. When a consumer requests water, the demand-management module checks whether sufficient treated water is available and whether dispensing is permitted. A valid purchase results in the delivery of the requested quantity, a corresponding reduction in tank volume, and the creation of a transaction record. The transaction must be processed exactly once to prevent duplicate deductions or duplicate revenue. Revenue from a purchase equals the volume of water sold multiplied by the selling price per liter. If the requested quantity exceeds the available usable water, the system must reject the purchase or fulfill only the quantity permitted by its defined sales policy. Water production and water sales must remain separate processes: producing water does not automatically mean that a consumer has purchased it.

 10\. Revenue, operating expenses, and financial accounting. After a completed purchase, the financial module updates hourly revenue and cumulative revenue. Hourly revenue equals the sum of the revenue from all completed transactions during the current accounting hour. Cumulative revenue equals the previous cumulative revenue plus revenue from each newly completed sale. If the application calculates profitability, it must also account for modeled operating expenses, including electricity, maintenance, consumables, and treatment costs. Net operating income equals sales revenue minus the applicable operating expenses. The CA must preserve transaction records and use consistent accounting intervals so that revenue does not increase merely because the simulation advances through another time step. If no valid purchase occurs, income must remain unchanged.

 11\. Supervisory cellular automaton and fault management. The supervisory CA coordinates environmental monitoring, power allocation, condenser operation, water treatment, tank management, and consumer transactions. During each simulation step, it evaluates sensor readings, component operating states, energy availability, water inventory, and fault conditions. It then determines whether to start, continue, reduce, or stop each process. The controller must handle insufficient power, low battery charge, restricted airflow, cooling failure, a full tank, treatment failure, sensor faults, and equipment shutdown. Safety and water-quality restrictions take priority over production and sales objectives. The CA should use appropriate state transitions, operating thresholds, and hysteresis to avoid rapid switching between operating states when readings fluctuate near a threshold. Faults must be logged, and recovery should occur only when the required conditions have been restored.

 12\. Energy and water conservation checks. Throughout the pipeline, the simulation must enforce energy and material balances. The electrical balance must account for energy generated, energy supplied by the battery, equipment consumption, energy stored, and conversion losses. The water balance must account for initial inventory, produced water, other inflows, dispensed water, treatment losses, rejected water, and final inventory. These checks help identify calculation errors, repeated production updates, duplicated transactions, and inconsistent simulation timing. Each process must use consistent units and a defined time interval. Power is measured in kilowatts, energy in kilowatt-hours, water volume in liters, water-production rate in liters per hour, and revenue in the application's selected currency.

 13\. Three-dimensional visualization and dashboard updates. The final stage of every simulation step updates the 3D scene and the dashboard from the same validated system state. The solar array displays generated power; the battery displays its actual state of charge; the power meter displays instantaneous consumption and accumulated energy use; the condenser displays airflow and cooling status; the condensate collector shows water accumulating at the calculated production rate; the treatment unit displays its operating and verification status; the storage tank fills or empties according to its actual water balance; and the dispenser animates only when a valid dispensing event occurs. Water production, battery charge, power consumption, tank volume, hourly revenue, and cumulative revenue must all reflect the same underlying state. The visual layer must not create water, energy, or financial transactions independently of the simulation model.

 14\. Continuous simulation and feedback. After all calculations and component updates are complete, the CA advances the simulation to the next time step. It reevaluates environmental conditions, recalculates solar power and battery availability, updates condenser performance, calculates additional water production, verifies treatment status, updates storage, and processes any new consumer purchases. This cycle continues until the simulation is paused, the system is shut down, or a fault requires intervention. The resulting pipeline represents a continuous feedback-controlled system rather than a one-way sequence of animations.

 The complete process therefore follows this operational order: environmental assessment, solar generation, power management, air intake, airflow regulation, refrigeration and heat exchange, condensation, water treatment, quality verification, storage, consumer dispensing, financial accounting, CA supervision, conservation checks, and 3D visualization. The architecture provides a comprehensive basis for implementing the iOS simulation. However, demonstrating that the physical system can achieve a target of 3,000 liters of water per day requires equipment-specific performance data and validation under the intended environmental conditions.
 */
import SwiftUI
import SceneKit
import UIKit
import Combine

// MARK: - Environment

struct CAEnvironment {
    var temperatureC: Double
    var relativeHumidity: Double
    var solarKW: Double
    var condensationPotentialLPerHour: Double
}

// MARK: - Simulation Parameters

struct CAParameters {
    var startSOC: Double = 60.0
    var stopSOC: Double = 35.0
    var minimumReserveSOC: Double = 25.0

    var minimumCondensationRateLPerHour: Double = 0.1
    var targetTankFraction: Double = 0.85

    var batteryCapacityKWh: Double = 100.0
    var maximumBatteryDischargeKW: Double = 20.0
    var maximumBatteryChargeKW: Double = 20.0

    var chargeEfficiency: Double = 0.95
    var dischargeEfficiency: Double = 0.95

    var condenserPowerKW: Double = 20.0
    var tankCapacityL: Double = 3000.0
    var consumerDemandLPerHour: Double = 50.0
    
    var waterPricePerLiter: Double = 0.05
}

// MARK: - Simulation State

struct CAState {
    var generation: Int = 0
    var hour: Int = 0

    var batterySOC: Double = 80.0
    var batteryEnergyKWh: Double = 80.0

    var tankLiters: Double = 500.0
    var condenserOn: Bool = false
    var condenserStatus: String = "Waiting for conditions"

    var consumerDemandLPerHour: Double = 50.0

    var waterProducedL: Double = 0.0
    var waterSoldL: Double = 0.0

    var condenserEnergyKWh: Double = 0.0
    var solarEnergyKWh: Double = 0.0
    var batteryDischargeKWh: Double = 0.0
    var batteryChargeKWh: Double = 0.0

    var cumulativeWaterProducedL: Double = 0.0
    var cumulativeWaterSoldL: Double = 0.0
    var cumulativeCondenserEnergyKWh: Double = 0.0
    var cumulativeSolarEnergyKWh: Double = 0.0
    var cumulativeBatteryDischargeKWh: Double = 0.0
    var cumulativeBatteryChargeKWh: Double = 0.0
    var hourlyIncome : Double = 0.0
    var cumulativeIncome : Double = 0.0
}

// MARK: - Environment Profile

struct CAEnvironmentProfile {
    var baseTemperatureC: Double = 30.0
    var baseRelativeHumidity: Double = 65.0

    var peakSolarKW: Double = 20.48
    var ratedCondensationLPerHour: Double = 125.0

    var dailyTemperatureSwingC: Double = 5.0
    var dailyHumiditySwing: Double = 10.0

    func environment(forHour hour: Int) -> CAEnvironment {
        let h = Double(hour % 24)

        // Approximate daylight output from 06:00 through 18:00.
        let daylight = max(
            0.0,
            sin(Double.pi * (h - 6.0) / 12.0)
        )

        let solarKW = peakSolarKW * daylight

        // Simplified daily temperature and humidity profiles.
        let temperature = baseTemperatureC
            + dailyTemperatureSwingC
            * sin(2.0 * Double.pi * (h - 9.0) / 24.0)

        let humidity = min(
            100.0,
            max(
                5.0,
                baseRelativeHumidity
                    - dailyHumiditySwing
                    * sin(2.0 * Double.pi * (h - 9.0) / 24.0)
            )
        )

        // Placeholder estimate, not a psychrometric or validated
        // condenser-performance calculation.
        let condensationRate = ratedCondensationLPerHour
            * humidity / max(1.0, baseRelativeHumidity)

        return CAEnvironment(
            temperatureC: temperature,
            relativeHumidity: humidity,
            solarKW: solarKW,
            condensationPotentialLPerHour: condensationRate
        )
    }
}

// MARK: - Cellular Automaton Controller

struct CellularAutomatonController {

    func decide(
        state: CAState,
        environment: CAEnvironment,
        parameters: CAParameters
    ) -> (shouldRun: Bool, reason: String) {

        if state.consumerDemandLPerHour <= 0 {
            return (false, "No consumer demand")
        }

        let targetTank = parameters.tankCapacityL
            * parameters.targetTankFraction

        if state.tankLiters >= targetTank {
            return (false, "Tank has reached its target level")
        }

        if state.tankLiters >= parameters.tankCapacityL {
            return (false, "Tank is full")
        }

        if environment.condensationPotentialLPerHour
            < parameters.minimumCondensationRateLPerHour {
            return (false, "Condensation potential is too low")
        }

        let solarCanRunCondenser =
            environment.solarKW >= parameters.condenserPowerKW

        let batterySOC = state.batterySOC

        // Start on adequate solar even when battery SOC is low.
        if !state.condenserOn {
            if solarCanRunCondenser {
                return (true, "Running on solar power")
            }

            if batterySOC < parameters.startSOC {
                return (false, "Waiting for solar or battery recharge")
            }

            let usableBatteryEnergy = max(
                0.0,
                state.batteryEnergyKWh
                    - parameters.batteryCapacityKWh
                    * parameters.minimumReserveSOC / 100.0
            )

            if usableBatteryEnergy <= 0.0 {
                return (false, "Battery reserve reached")
            }

            return (true, "Battery above start threshold")
        }

        // An already-running condenser can continue at lower SOC
        // until the stop threshold, unless solar covers its load.
        if solarCanRunCondenser {
            return (true, "Running on solar power")
        }

        if batterySOC <= parameters.stopSOC {
            return (false, "Stopped at battery SOC threshold")
        }

        let usableBatteryEnergy = max(
            0.0,
            state.batteryEnergyKWh
                - parameters.batteryCapacityKWh
                * parameters.minimumReserveSOC / 100.0
        )

        if usableBatteryEnergy <= 0.0 {
            return (false, "Battery reserve reached")
        }

        return (true, "Running with solar and battery support")
    }
}

// MARK: - Hourly Record

struct HourlySimulationRecord: Identifiable {
    var id: Int { generation }

    let generation: Int
    let hour: Int

    let environment: CAEnvironment
    let state: CAState

    let waterProducedL: Double
    let waterSoldL: Double

    let solarPowerKW: Double
    let condenserPowerKW: Double

    let solarEnergyKWh: Double
    let batteryChargeKWh: Double
    let batteryDischargeKWh: Double

    let cumulativeCondenserEnergyKWh: Double
}

// MARK: - Simulator

struct AtmosphericWaterSimulator {

    var parameters = CAParameters()
    var profile = CAEnvironmentProfile()
    var controller = CellularAutomatonController()

    var state = CAState()

    init() {
        state.batteryEnergyKWh =
            parameters.batteryCapacityKWh * state.batterySOC / 100.0

        state.tankLiters = 500.0
        state.consumerDemandLPerHour = parameters.consumerDemandLPerHour
    }

    mutating func advanceOneHour() -> HourlySimulationRecord {
        let currentHour = state.hour % 24
        let environment = profile.environment(forHour: currentHour)

        state.generation += 1
        state.hour += 1

        // Reset hourly measurements.
        state.waterProducedL = 0
        state.waterSoldL = 0
        state.condenserEnergyKWh = 0
        state.solarEnergyKWh = 0
        state.batteryDischargeKWh = 0
        state.batteryChargeKWh = 0

        state.consumerDemandLPerHour =
            parameters.consumerDemandLPerHour

        let decision = controller.decide(
            state: state,
            environment: environment,
            parameters: parameters
        )

        state.condenserOn = decision.shouldRun
        state.condenserStatus = decision.reason

        // Simulation represents one hour per step.
        let solarAvailableKWh = max(0.0, environment.solarKW)
        state.solarEnergyKWh = solarAvailableKWh

        var condenserRuntimeFraction = 0.0

        if state.condenserOn {
            let requestedEnergyKWh = parameters.condenserPowerKW

            // Solar supplies the load first.
            let solarToCondenserKWh = min(
                solarAvailableKWh,
                requestedEnergyKWh
            )

            let remainingLoadKWh = max(
                0.0,
                requestedEnergyKWh - solarToCondenserKWh
            )

            // Battery can only discharge energy above the reserve.
            let reserveKWh = parameters.batteryCapacityKWh
                * parameters.minimumReserveSOC / 100.0

            let usableBatteryEnergyKWh = max(
                0.0,
                state.batteryEnergyKWh - reserveKWh
            )

            let maximumBatteryEnergyDeliveredKWh =
                min(
                    parameters.maximumBatteryDischargeKW,
                    usableBatteryEnergyKWh
                        * parameters.dischargeEfficiency
                )

            let batteryToCondenserKWh = min(
                remainingLoadKWh,
                maximumBatteryEnergyDeliveredKWh
            )

            // Convert energy delivered to the condenser into the
            // amount removed from the battery, including losses.
            let batteryEnergyRemovedKWh =
                batteryToCondenserKWh
                / max(0.01, parameters.dischargeEfficiency)

            state.batteryEnergyKWh = max(
                reserveKWh,
                state.batteryEnergyKWh - batteryEnergyRemovedKWh
            )

            state.batteryDischargeKWh = batteryEnergyRemovedKWh

            let energyDeliveredKWh =
                solarToCondenserKWh + batteryToCondenserKWh

            // Allow partial operation if available energy is insufficient
            // for a full hour.
            condenserRuntimeFraction = min(
                1.0,
                energyDeliveredKWh
                    / max(0.01, requestedEnergyKWh)
            )

            state.condenserEnergyKWh =
                energyDeliveredKWh

            if condenserRuntimeFraction < 0.999 {
                state.condenserStatus =
                    "Partial operation: insufficient energy"
            }
        }

        // Charge the battery with solar energy left after condenser use.
        let solarUsedByCondenserKWh = min(
            solarAvailableKWh,
            state.condenserEnergyKWh
        )

        let surplusSolarKWh = max(
            0.0,
            solarAvailableKWh - solarUsedByCondenserKWh
        )

        let batteryCapacityKWh = parameters.batteryCapacityKWh
        let maximumStoredEnergyKWh = batteryCapacityKWh

        let freeBatteryCapacityKWh = max(
            0.0,
            maximumStoredEnergyKWh - state.batteryEnergyKWh
        )

        let maximumChargeInputKWh = min(
            parameters.maximumBatteryChargeKW,
            surplusSolarKWh
        )

        let chargeInputKWh = min(
            maximumChargeInputKWh,
            freeBatteryCapacityKWh
                / max(0.01, parameters.chargeEfficiency)
        )

        let storedChargeKWh =
            chargeInputKWh * parameters.chargeEfficiency

        state.batteryEnergyKWh = min(
            maximumStoredEnergyKWh,
            state.batteryEnergyKWh + storedChargeKWh
        )

        state.batteryChargeKWh = storedChargeKWh

        // Update battery state of charge.
        state.batterySOC = batteryCapacityKWh > 0
            ? min(
                100.0,
                max(
                    0.0,
                    state.batteryEnergyKWh
                        / batteryCapacityKWh * 100.0
                )
            )
            : 0.0

        // Approximate water production, scaled by runtime and
        // available tank space.
        if state.condenserOn && condenserRuntimeFraction > 0 {
            let availableTankSpaceL = max(
                0.0,
                parameters.tankCapacityL - state.tankLiters
            )

            let potentialWaterL =
                environment.condensationPotentialLPerHour
                * condenserRuntimeFraction

            state.waterProducedL = min(
                potentialWaterL,
                availableTankSpaceL
            )

            state.tankLiters += state.waterProducedL
        }

        // Serve consumer demand from available tank inventory.
        let waterAvailableForSaleL = max(0.0, state.tankLiters)

        state.waterSoldL = min(
            waterAvailableForSaleL,
            parameters.consumerDemandLPerHour
        )

        state.tankLiters = max(
            0.0,
            state.tankLiters - state.waterSoldL
        )

        // Cumulative accounting.
        state.cumulativeWaterProducedL += state.waterProducedL
        state.cumulativeWaterSoldL += state.waterSoldL
        state.cumulativeCondenserEnergyKWh +=
            state.condenserEnergyKWh
        state.cumulativeSolarEnergyKWh +=
            state.solarEnergyKWh
        state.cumulativeBatteryDischargeKWh +=
            state.batteryDischargeKWh
        state.cumulativeBatteryChargeKWh +=
            state.batteryChargeKWh
        
        processConsumerPurchase(liters: state.waterSoldL)

        return HourlySimulationRecord(
            generation: state.generation,
            hour: currentHour,
            environment: environment,
            state: state,
            waterProducedL: state.waterProducedL,
            waterSoldL: state.waterSoldL,
            solarPowerKW: environment.solarKW,
            condenserPowerKW: state.condenserOn
                ? parameters.condenserPowerKW
                    * condenserRuntimeFraction
                : 0.0,
            solarEnergyKWh: state.solarEnergyKWh,
            batteryChargeKWh: state.batteryChargeKWh,
            batteryDischargeKWh: state.batteryDischargeKWh,
            cumulativeCondenserEnergyKWh:
                state.cumulativeCondenserEnergyKWh
        )
    }

    mutating func processConsumerPurchase(
        liters requestedLiters: Double
    ) -> Double {
        let sold = min(
            max(0.0, requestedLiters),
            state.tankLiters
        )

        state.tankLiters -= sold
        state.waterSoldL = sold
        state.cumulativeWaterSoldL += sold
        
        state.hourlyIncome =
            state.waterSoldL * parameters.waterPricePerLiter

        state.cumulativeIncome += state.hourlyIncome

        return sold
    }

    mutating func reset() {
        self = AtmosphericWaterSimulator()
    }
}

// MARK: - View Model

@MainActor
final class WaterSystemViewModel: ObservableObject {

    @Published var simulator = AtmosphericWaterSimulator()
    @Published var latestRecord: HourlySimulationRecord?
    @Published var records: [HourlySimulationRecord] = []

    var state: CAState {
        simulator.state
    }

    var parameters: CAParameters {
        simulator.parameters
    }

    var environment: CAEnvironment {
        simulator.profile.environment(
            forHour: simulator.state.hour % 24
        )
    }

    func advanceOneHour() {
        let record = simulator.advanceOneHour()
        latestRecord = record
        records.append(record)

        // Keep the history list manageable.
        if records.count > 168 {
            records.removeFirst(records.count - 168)
        }
    }

    func runOneDay() {
        for _ in 0..<24 {
            advanceOneHour()
        }
    }

    func reset() {
        simulator.reset()
        latestRecord = nil
        records.removeAll()
    }
}

// MARK: - Main Content View

struct ContentView: View {

    @StateObject private var model = WaterSystemViewModel()

    @State private var isPlaying = false

    private let playbackTimer = Timer.publish(
        every: 1.0,
        on: .main,
        in: .common
    ).autoconnect()

    private var state: CAState {
        model.state
    }

    private var parameters: CAParameters {
        model.parameters
    }

    private var environment: CAEnvironment {
        model.environment
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    headerSection

                    System3DView(
                        record: model.latestRecord,
                        state: state,
                        batteryCapacityKWh:
                            parameters.batteryCapacityKWh,
                        tankCapacityL:
                            parameters.tankCapacityL
                    )
                    .frame(height: 340)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    playbackControls
                    
                    incomeSection

                    condenserStatusCard

                    environmentSection

                    capacitySection

                    waterProductionSection

                    energySection

                    cumulativeSection

                    historySection

                    disclaimerSection
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Atmospheric Water")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(playbackTimer) { _ in
                if isPlaying {
                    model.advanceOneHour()
                }
            }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Atmospheric Water System")
                .font(.title2.bold())

            Text(
                "Solar-powered condenser, battery storage, " +
                "water inventory and simulated demand"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack {
                Label(
                    String(format: "Hour %02d:00", state.hour % 24),
                    systemImage: "clock"
                )

                Spacer()

                Text("Step \(state.generation)")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Playback

    private var playbackControls: some View {
        VStack(spacing: 12) {
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
                    model.runOneDay()
                } label: {
                    Label("Run 24 Hours", systemImage: "sun.max")
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
        }
    }

    // MARK: Condenser Status

    private var condenserStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(
                    systemName: state.condenserOn
                        ? "wind"
                        : "pause.circle"
                )
                .font(.title2)

                VStack(alignment: .leading, spacing: 3) {
                    Text(
                        state.condenserOn
                            ? "Condenser Running"
                            : "Condenser Stopped"
                    )
                    .font(.headline)

                    Text(state.condenserStatus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Circle()
                    .fill(state.condenserOn ? .green : .orange)
                    .frame(width: 12, height: 12)
            }

            Divider()

            HStack {
            
                metric(
                    title: "Solar Power",
                    value: String(format: "%.1f kW", environment.solarKW),
                    symbol: "sun.max.fill"
                )
              

                Spacer()

                metric(
                    title: "Condenser Load",
                    value: String(
                        format: "%.1f kW",
                        model.latestRecord?.condenserPowerKW ?? 0.0
                    ),
                    symbol: "bolt.fill"
                )

            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Environment

    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Environment", symbol: "cloud.sun")

            HStack(spacing: 10) {
                valueCard(
                    title: "Temperature",
                    value: String(
                        format: "%.1f °C",
                        environment.temperatureC
                    ),
                    symbol: "thermometer"
                )

                valueCard(
                    title: "Humidity",
                    value: String(
                        format: "%.0f%%",
                        environment.relativeHumidity
                    ),
                    symbol: "humidity"
                )
            }

            HStack(spacing: 10) {
             
                valueCard(
                    title: "Potential Water",
                    value: String(
                        format: "%.1f L/h",
                        environment.condensationPotentialLPerHour
                    ),
                    symbol: "drop.fill"
                )

                valueCard(
                    title: "Solar Input",
                    value: String(
                        format: "%.2f kW",
                        environment.solarKW
                    ),
                    symbol: "sun.max.fill"
                )
            
            }
        }
    }

    // MARK: Capacity

    private var capacitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Live Capacity", symbol: "gauge.with.dots.needle.50percent")

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Battery", systemImage: "battery.75percent")
                        .font(.headline)

                    Spacer()

                    Text("\(state.batterySOC, specifier: "%.1f")%")
                        .font(.headline.monospacedDigit())
                }

                ProgressView(
                    value: min(1.0, max(0.0, state.batterySOC / 100.0))
                )
                .tint(.green)

                HStack {
                    Text(
                        "\(state.batteryEnergyKWh, specifier: "%.1f") kWh stored"
                    )

                    Spacer()

                    Text(
                        "\(parameters.batteryCapacityKWh, specifier: "%.0f") kWh capacity"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Water Tank", systemImage: "drop.fill")
                        .font(.headline)

                    Spacer()

                    Text(
                        "\(state.tankLiters, specifier: "%.0f") L"
                    )
                    .font(.headline.monospacedDigit())
                }

                ProgressView(
                    value: min(
                        1.0,
                        max(
                            0.0,
                            state.tankLiters
                                / max(1.0, parameters.tankCapacityL)
                        )
                    )
                )
                .tint(.blue)

                HStack {
                    Text(
                        "\(state.tankLiters / max(1.0, parameters.tankCapacityL) * 100, specifier: "%.1f")% full"
                    )

                    Spacer()

                    Text(
                        "\(parameters.tankCapacityL, specifier: "%.0f") L capacity"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Water Production

    private var waterProductionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Water Production", symbol: "drop")

            HStack(spacing: 10) {
     
                valueCard(
                    title: "Produced This Hour",
                    value: String(
                        format: "%.1f L",
                        state.waterProducedL
                    ),
                    symbol: "arrow.down.to.line"
                )

                valueCard(
                    title: "Sold This Hour",
                    value: String(
                        format: "%.1f L",
                        state.waterSoldL
                    ),
                    symbol: "cart"
                )
        
            }

            HStack(spacing: 10) {
            
                valueCard(
                    title: "Demand",
                    value: String(
                        format: "%.0f L/h",
                        parameters.consumerDemandLPerHour
                    ),
                    symbol: "person.2"
                )
             
                valueCard(
                    title: "Net Tank Change",
                    value: String(
                        format: "%+.1f L",
                        state.waterProducedL - state.waterSoldL
                    ),
                    symbol: "arrow.up.arrow.down"
                )

            }

            Text(
                "Water produced is added to the tank before simulated " +
                "consumer demand is deducted."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: Energy

    private var energySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Energy This Hour", symbol: "bolt")

            HStack(spacing: 10) {
         
                valueCard(
                    title: "Condenser",
                    value: String(format: "%.2f kWh", state.condenserEnergyKWh),
                    symbol: "fanblades"
                )

                valueCard(
                    title: "Solar Generated",
                    value: String(format: "%.2f kWh", state.solarEnergyKWh),
                    symbol: "sun.max"
                )
         
            }

            HStack(spacing: 10) {
    
                valueCard(
                    title: "Battery Discharge",
                    value: String(format: "%.2f kWh", state.batteryDischargeKWh),
                    symbol: "battery.50percent"
                )
            

                valueCard(
                    title: "Battery Charge",
                    value: String(format: "%.2f kWh", state.batteryChargeKWh),
                    symbol: "battery.100percent"
                )
            }

            Text(
                "The condenser energy meter shows energy delivered to the " +
                "condenser during the simulated hour. Battery discharge " +
                "includes the modeled discharge loss."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
    private var averageIncomePerDay: Double {
        guard state.hour > 0 else {
            return 0.0
        }

        let simulatedDays = Double(state.hour) / 24.0

        return state.cumulativeIncome / simulatedDays
    }
    // MARK: Income Panel

    private var incomeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Water Sales & Income", symbol: "dollarsign.circle")

            HStack(spacing: 10) {
                valueCard(
                    title: "Income This Hour",
                    value: String(
                        format: "$%.2f",
                        state.hourlyIncome
                    ),
                    symbol: "dollarsign.circle.fill"
                )

                valueCard(
                    title: "Total Income",
                    value: String(
                        format: "$%.2f",
                        state.cumulativeIncome
                    ),
                    symbol: "chart.line.uptrend.xyaxis"
                )
            }
            
            HStack(spacing: 10) {
                valueCard(
                    title: "Average Income per Day",
                    value: String(
                        format: "$%.2f",
                        averageIncomePerDay
                    ),
                    symbol: "calendar"
                )

                valueCard(
                    title: "Simulated Days",
                    value: String(
                        format: "%.2f days",
                        Double(state.generation) / 24.0
                    ),
                    symbol: "clock"
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Selling Price")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(
                        String(
                            format: "$%.2f / L",
                            parameters.waterPricePerLiter
                        )
                    )
                    .font(.headline.monospacedDigit())
                }

                Slider(
                    value: Binding(
                        get: {
                            model.simulator.parameters.waterPricePerLiter
                        },
                        set: { newValue in
                            model.simulator.parameters.waterPricePerLiter =
                                newValue
                        }
                    ),
                    in: 0.01...1.00,
                    step: 0.01
                )
                .tint(.green)

                HStack {
                    Text("$0.01 / L")
                    Spacer()
                    Text("$1.00 / L")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            totalRow(
                "Revenue per 1,000 L",
                value: String(
                    format: "$%.2f",
                    parameters.waterPricePerLiter * 1000
                )
            )

            totalRow(
                "Water Sold",
                value: String(
                    format: "%.1f L",
                    state.cumulativeWaterSoldL
                )
            )
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }


    private var cumulativeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Cumulative Totals", symbol: "chart.bar")
            

            totalRow(
                "Total Water Produced",
                value: "\(String(format: "%.1f", state.cumulativeWaterProducedL)) L"
            )

            totalRow(
                "Total Water Sold",
                value: "\(String(format: "%.1f", state.cumulativeWaterSoldL)) L"
            )

            totalRow(
                "Condenser Energy",
                value: "\(String(format: "%.2f", state.cumulativeCondenserEnergyKWh)) kWh"
            )

            totalRow(
                "Solar Energy",
                value: "\(String(format: "%.2f", state.cumulativeSolarEnergyKWh)) kWh"
            )

            totalRow(
                "Battery Discharge",
                value: "\(String(format: "%.2f", state.cumulativeBatteryDischargeKWh)) kWh"
            )

            totalRow(
                "Battery Charge",
                value: "\(String(format: "%.2f", state.cumulativeBatteryChargeKWh)) kWh"
            )
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Recent Simulation History", symbol: "clock.arrow.circlepath")

            if model.records.isEmpty {
                Text("Advance the simulation to create hourly records.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(
                    Array(model.records.suffix(8).reversed())
                ) { record in
                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Text(
                                String(
                                    format: "Step %d · %02d:00",
                                    record.generation,
                                    record.hour
                                )
                            )
                            .font(.subheadline.bold())

                            Spacer()

                            Text(
                                record.state.condenserOn
                                    ? "ON"
                                    : "OFF"
                            )
                            .font(.caption.bold())
                            .foregroundStyle(
                                record.state.condenserOn
                                    ? .green
                                    : .secondary
                            )
                        }

                        HStack {
                            Text(
                                "Water +\(record.waterProducedL, specifier: "%.1f") L"
                            )

                            Spacer()

                            Text(
                                "Sold \(record.waterSoldL, specifier: "%.1f") L"
                            )
                        }
                        .font(.caption)

                        HStack {
                            Text(
                                "Battery \(record.state.batterySOC, specifier: "%.1f")%"
                            )

                            Spacer()

                            Text(
                                "Tank \(record.state.tankLiters, specifier: "%.0f") L"
                            )
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Text(record.state.condenserStatus)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if record.id != model.records.suffix(8).first?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Disclaimer

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                "Simulation assumptions",
                systemImage: "info.circle"
            )
            .font(.headline)

            Text(
                "This is a conceptual hourly model. The water-production " +
                "rate is a placeholder based on relative humidity; it is " +
                "not a validated atmospheric-water performance model. " +
                "Real output and energy use depend on dew point, airflow, " +
                "condenser design, temperature, heat rejection and " +
                "operating conditions."
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(
                "Produced water is not automatically potable. Appropriate " +
                "filtration, disinfection, mineral management and water " +
                "quality testing are required before drinking."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Reusable UI

    private func sectionTitle(
        _ title: String,
        symbol: String
    ) -> some View {
        Label(title, systemImage: symbol)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metric(
        title: String,
        value: String,
        symbol: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline.monospacedDigit())
        }
    }

    private func valueCard(
        title: String,
        value: String,
        symbol: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.blue)

            Text(value)
                .font(.headline.monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func totalRow(
        _ title: String,
        value: String
    ) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.monospacedDigit().weight(.medium))
        }
        .font(.subheadline)
    }
}

// MARK: - 3D System View

struct System3DView: UIViewRepresentable {

    let record: HourlySimulationRecord?
    let state: CAState
    let batteryCapacityKWh: Double
    let tankCapacityL: Double

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()

        sceneView.scene = context.coordinator.scene
        sceneView.backgroundColor = UIColor(
            red: 0.035,
            green: 0.07,
            blue: 0.13,
            alpha: 1.0
        )

        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
        sceneView.isPlaying = true

        context.coordinator.update(
            record: record,
            state: state,
            batteryCapacityKWh: batteryCapacityKWh,
            tankCapacityL: tankCapacityL
        )

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.update(
            record: record,
            state: state,
            batteryCapacityKWh: batteryCapacityKWh,
            tankCapacityL: tankCapacityL
        )
    }

    // MARK: Scene Coordinator

    final class Coordinator {

        let scene = SCNScene()

        private let tankNode = SCNNode()
        private let waterNode = SCNNode()
        private let batteryFillNode = SCNNode()
        private let fanNode = SCNNode()
        private let condenserLight = SCNNode()

        private let tankHeight: CGFloat = 3.0
        private let tankRadius: CGFloat = 0.85

        private var lastCondenserState: Bool?

        init() {
            buildScene()
        }

        // MARK: Build Scene

        private func buildScene() {
            scene.rootNode.childNodes.forEach {
                $0.removeFromParentNode()
            }

            addLighting()
            addGround()
            addSolarArray()
            addCondenser()
            addWaterTank()
            addBattery()
            addPowerMeter()
            addLabels()
            addCamera()
        }

        private func addLighting() {
            let ambient = SCNNode()
            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.intensity = 450
            ambientLight.color = UIColor(
                red: 0.65,
                green: 0.75,
                blue: 1.0,
                alpha: 1.0
            )
            ambient.light = ambientLight
            scene.rootNode.addChildNode(ambient)

            let key = SCNNode()
            let keyLight = SCNLight()
            keyLight.type = .omni
            keyLight.intensity = 1100
            keyLight.color = UIColor.white
            key.position = SCNVector3(0, 10, 10)
            key.light = keyLight
            scene.rootNode.addChildNode(key)

            let fill = SCNNode()
            let fillLight = SCNLight()
            fillLight.type = .omni
            fillLight.intensity = 650
            fillLight.color = UIColor(
                red: 0.2,
                green: 0.55,
                blue: 1.0,
                alpha: 1.0
            )
            fill.position = SCNVector3(-8, 5, -5)
            fill.light = fillLight
            scene.rootNode.addChildNode(fill)
        }

        private func addGround() {
            let floor = SCNFloor()
            floor.reflectivity = 0.08

            let material = SCNMaterial()
            material.diffuse.contents = UIColor(
                red: 0.09,
                green: 0.14,
                blue: 0.20,
                alpha: 1.0
            )
            material.roughness.contents = 0.9
            floor.materials = [material]

            let node = SCNNode(geometry: floor)
            node.position = SCNVector3(0, -0.12, 0)
            scene.rootNode.addChildNode(node)

            let platform = SCNBox(
                width: 15,
                height: 0.2,
                length: 9,
                chamferRadius: 0.12
            )
            platform.firstMaterial?.diffuse.contents =
                UIColor.darkGray

            let platformNode = SCNNode(geometry: platform)
            platformNode.position = SCNVector3(0, 0, 0)
            scene.rootNode.addChildNode(platformNode)
        }

        // MARK: Solar Panels

        private func addSolarArray() {
            for row in 0..<2 {
                for column in 0..<3 {
                    let x = Float(column) * 1.65 - 5.0
                    let z = Float(row) * 1.6 - 2.0

                    let panel = SCNBox(
                        width: 1.45,
                        height: 0.07,
                        length: 1.25,
                        chamferRadius: 0.035
                    )

                    let panelMaterial = SCNMaterial()
                    panelMaterial.diffuse.contents = UIColor(
                        red: 0.025,
                        green: 0.16,
                        blue: 0.42,
                        alpha: 1.0
                    )
                    panelMaterial.metalness.contents = 0.35
                    panelMaterial.roughness.contents = 0.28
                    panel.materials = [panelMaterial]

                    let panelNode = SCNNode(geometry: panel)
                    panelNode.position = SCNVector3(x, 0.9, z)
                    panelNode.eulerAngles.x = -0.12
                    scene.rootNode.addChildNode(panelNode)

                    // Panel grid lines.
                    for line in 1..<4 {
                        let grid = SCNBox(
                            width: 0.012,
                            height: 0.008,
                            length: 1.2,
                            chamferRadius: 0
                        )
                        grid.firstMaterial?.diffuse.contents =
                            UIColor.cyan

                        let gridNode = SCNNode(geometry: grid)
                        gridNode.position = SCNVector3(
                            x + Float(line) * 0.28 - 0.56,
                            0.94,
                            z
                        )
                        gridNode.eulerAngles.x = -0.12
                        scene.rootNode.addChildNode(gridNode)
                    }

                    // Panel support.
                    let support = SCNCylinder(
                        radius: 0.055,
                        height: 0.75
                    )
                    support.firstMaterial?.diffuse.contents =
                        UIColor.gray

                    let supportNode = SCNNode(geometry: support)
                    supportNode.position = SCNVector3(x, 0.45, z)
                    scene.rootNode.addChildNode(supportNode)
                }
            }
        }

        // MARK: Condenser

        private func addCondenser() {
            let housing = SCNBox(
                width: 2.2,
                height: 1.65,
                length: 1.6,
                chamferRadius: 0.12
            )

            let housingMaterial = SCNMaterial()
            housingMaterial.diffuse.contents = UIColor(
                red: 0.22,
                green: 0.29,
                blue: 0.36,
                alpha: 1.0
            )
            housingMaterial.metalness.contents = 0.45
            housingMaterial.roughness.contents = 0.4
            housing.materials = [housingMaterial]

            let housingNode = SCNNode(geometry: housing)
            housingNode.position = SCNVector3(0, 1.0, 1.5)
            scene.rootNode.addChildNode(housingNode)

            // Circular fan housing on the front.
            let fanHousing = SCNTube(
                innerRadius: 0.38,
                outerRadius: 0.52,
                height: 0.12
            )
            fanHousing.firstMaterial?.diffuse.contents =
                UIColor.lightGray

            let fanHousingNode = SCNNode(geometry: fanHousing)
            fanHousingNode.position = SCNVector3(0, 1.05, 2.34)
            fanHousingNode.eulerAngles.x = Float.pi / 2
            scene.rootNode.addChildNode(fanHousingNode)

            // Fan rotor.
            let rotor = SCNCylinder(
                radius: 0.07,
                height: 0.12
            )
            rotor.firstMaterial?.diffuse.contents = UIColor.white

            let rotorNode = SCNNode(geometry: rotor)
            rotorNode.position = SCNVector3(0, 1.05, 2.4)
            rotorNode.eulerAngles.x = Float.pi / 2
            fanNode.addChildNode(rotorNode)

            for blade in 0..<4 {
                let bladeGeometry = SCNBox(
                    width: 0.12,
                    height: 0.52,
                    length: 0.035,
                    chamferRadius: 0.025
                )
                bladeGeometry.firstMaterial?.diffuse.contents =
                    UIColor.cyan

                let bladeNode = SCNNode(geometry: bladeGeometry)
                let angle = Float(blade) * Float.pi / 2

                bladeNode.position = SCNVector3(
                    CGFloat(sin(angle)) * 0.22,
                    CGFloat(cos(angle)) * 0.22,
                    0
                )
                bladeNode.eulerAngles.z = -angle

                fanNode.addChildNode(bladeNode)
            }

            fanNode.position = SCNVector3(0, 1.05, 2.4)
            scene.rootNode.addChildNode(fanNode)

            // Condenser status light.
            let lightGeometry = SCNSphere(radius: 0.09)
            lightGeometry.firstMaterial?.diffuse.contents =
                UIColor.green
            lightGeometry.firstMaterial?.emission.contents =
                UIColor.green

            condenserLight.geometry = lightGeometry
            condenserLight.position = SCNVector3(0.85, 1.6, 2.32)
            scene.rootNode.addChildNode(condenserLight)

            // Air intake slats.
            for i in 0..<7 {
                let slat = SCNBox(
                    width: 1.0,
                    height: 0.035,
                    length: 0.025,
                    chamferRadius: 0.005
                )
                slat.firstMaterial?.diffuse.contents =
                    UIColor.black

                let slatNode = SCNNode(geometry: slat)
                slatNode.position = SCNVector3(
                    0,
                    0.55 + Float(i) * 0.13,
                    2.32
                )
                scene.rootNode.addChildNode(slatNode)
            }
        }

        // MARK: Tank

        private func addWaterTank() {
            let tankGeometry = SCNCylinder(
                radius: tankRadius,
                height: tankHeight
            )

            let tankMaterial = SCNMaterial()
            tankMaterial.diffuse.contents = UIColor(
                red: 0.5,
                green: 0.8,
                blue: 1.0,
                alpha: 0.12
            )
            tankMaterial.transparency = 0.22
            tankMaterial.isDoubleSided = true
            tankMaterial.lightingModel = .physicallyBased
            tankMaterial.metalness.contents = 0.05
            tankMaterial.roughness.contents = 0.2
            tankGeometry.materials = [tankMaterial]

            tankNode.geometry = tankGeometry
            tankNode.position = SCNVector3(4.0, 1.55, 1.2)
            scene.rootNode.addChildNode(tankNode)

            // Blue water column. Its height and vertical position
            // are updated as tank inventory changes.
            let waterGeometry = SCNCylinder(
                radius: tankRadius * 0.94,
                height: 0.01
            )

            let waterMaterial = SCNMaterial()
            waterMaterial.diffuse.contents = UIColor(
                red: 0.05,
                green: 0.48,
                blue: 1.0,
                alpha: 0.85
            )
            waterMaterial.transparency = 0.82
            waterMaterial.metalness.contents = 0.12
            waterMaterial.roughness.contents = 0.15
            waterMaterial.emission.contents = UIColor(
                red: 0.0,
                green: 0.12,
                blue: 0.3,
                alpha: 1.0
            )
            waterGeometry.materials = [waterMaterial]

            waterNode.geometry = waterGeometry
            tankNode.addChildNode(waterNode)

            // Tank top rim.
            let rim = SCNTube(
                innerRadius: tankRadius * 0.9,
                outerRadius: tankRadius * 1.04,
                height: 0.08
            )
            rim.firstMaterial?.diffuse.contents = UIColor.lightGray

            let rimNode = SCNNode(geometry: rim)
            rimNode.position = SCNVector3(0, tankHeight / 2, 0)
            tankNode.addChildNode(rimNode)

            // Tank base.
            let base = SCNCylinder(
                radius: tankRadius * 1.08,
                height: 0.12
            )
            base.firstMaterial?.diffuse.contents = UIColor.gray

            let baseNode = SCNNode(geometry: base)
            baseNode.position = SCNVector3(
                0,
                -tankHeight / 2,
                0
            )
            tankNode.addChildNode(baseNode)

            // Tank level markers.
            for mark in 1...4 {
                let marker = SCNBox(
                    width: 0.18,
                    height: 0.025,
                    length: 0.035,
                    chamferRadius: 0
                )
                marker.firstMaterial?.diffuse.contents =
                    UIColor.white

                let markerNode = SCNNode(geometry: marker)
                markerNode.position = SCNVector3(
                    tankRadius * 0.94,
                    -tankHeight / 2
                        + CGFloat(mark) * tankHeight / 5,
                    0
                )
                tankNode.addChildNode(markerNode)
            }
        }

        // MARK: Battery

        private func addBattery() {
            let batteryBody = SCNBox(
                width: 1.8,
                height: 1.6,
                length: 1.35,
                chamferRadius: 0.12
            )

            let batteryMaterial = SCNMaterial()
            batteryMaterial.diffuse.contents = UIColor(
                red: 0.12,
                green: 0.16,
                blue: 0.2,
                alpha: 1.0
            )
            batteryMaterial.metalness.contents = 0.35
            batteryMaterial.roughness.contents = 0.45
            batteryBody.materials = [batteryMaterial]

            let batteryNode = SCNNode(geometry: batteryBody)
            batteryNode.position = SCNVector3(4.0, 0.95, -2.1)
            scene.rootNode.addChildNode(batteryNode)

            // Battery charge column on its front face.
            let fillGeometry = SCNBox(
                width: 1.2,
                height: 0.01,
                length: 0.08,
                chamferRadius: 0.025
            )

            let fillMaterial = SCNMaterial()
            fillMaterial.diffuse.contents = UIColor.green
            fillMaterial.emission.contents = UIColor.green
            fillGeometry.materials = [fillMaterial]

            batteryFillNode.geometry = fillGeometry
            batteryFillNode.position = SCNVector3(
                0,
                -0.65,
                0.72
            )
            batteryNode.addChildNode(batteryFillNode)

            // Battery terminals.
            for x: Float in [-0.4, 0.4] {
                let terminal = SCNCylinder(
                    radius: 0.12,
                    height: 0.15
                )
                terminal.firstMaterial?.diffuse.contents =
                    UIColor.gray

                let terminalNode = SCNNode(geometry: terminal)
                terminalNode.position = SCNVector3(
                    x,
                    0.87,
                    0
                )
                batteryNode.addChildNode(terminalNode)
            }
        }

        // MARK: Power Meter

        private func addPowerMeter() {
            let meter = SCNBox(
                width: 1.0,
                height: 0.8,
                length: 0.12,
                chamferRadius: 0.06
            )

            meter.firstMaterial?.diffuse.contents = UIColor.black
            meter.firstMaterial?.emission.contents = UIColor(
                red: 0.0,
                green: 0.3,
                blue: 0.1,
                alpha: 1.0
            )

            let meterNode = SCNNode(geometry: meter)
            meterNode.position = SCNVector3(0, 0.8, -2.1)
            scene.rootNode.addChildNode(meterNode)

            let screen = SCNPlane(width: 0.78, height: 0.52)
            screen.firstMaterial?.diffuse.contents =
                UIColor(red: 0.0, green: 0.15, blue: 0.05, alpha: 1)
            screen.firstMaterial?.emission.contents = UIColor.green

            let screenNode = SCNNode(geometry: screen)
            screenNode.position = SCNVector3(0, 0.8, -2.025)
            scene.rootNode.addChildNode(screenNode)
        }

        // MARK: Labels

        private func addLabels() {
            addLabel(
                "SOLAR ARRAY",
                position: SCNVector3(-5.0, 1.65, -0.2),
                color: UIColor.cyan
            )

            addLabel(
                "CONDENSER",
                position: SCNVector3(0, 2.15, 1.5),
                color: UIColor.white
            )

            addLabel(
                "WATER TANK",
                position: SCNVector3(4.0, 3.5, 1.2),
                color: UIColor.cyan
            )

            addLabel(
                "BATTERY",
                position: SCNVector3(4.0, 1.95, -2.1),
                color: UIColor.green
            )

            addLabel(
                "POWER METER",
                position: SCNVector3(0, 1.45, -2.1),
                color: UIColor.green
            )
        }

        private func addLabel(
            _ text: String,
            position: SCNVector3,
            color: UIColor
        ) {
            let geometry = SCNText(
                string: text,
                extrusionDepth: 0.005
            )
            geometry.font = UIFont.boldSystemFont(ofSize: 0.24)
            geometry.flatness = 0.1
            geometry.firstMaterial?.diffuse.contents = color
            geometry.firstMaterial?.emission.contents = color

            let node = SCNNode(geometry: geometry)
            node.position = position
            node.scale = SCNVector3(1, 1, 1)
            node.constraints = [
                SCNBillboardConstraint()
            ]
            scene.rootNode.addChildNode(node)
        }

        // MARK: Camera

        private func addCamera() {
            let camera = SCNCamera()
            camera.fieldOfView = 55
            camera.zNear = 0.1
            camera.zFar = 200

            let cameraNode = SCNNode()
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(10, 9, 16)

            let lookAt = SCNLookAtConstraint(
                target: scene.rootNode
            )
            lookAt.isGimbalLockEnabled = true
            cameraNode.constraints = [lookAt]

            scene.rootNode.addChildNode(cameraNode)
        }

        // MARK: Animate Capacity and Status

        func update(
            record: HourlySimulationRecord?,
            state: CAState,
            batteryCapacityKWh: Double,
            tankCapacityL: Double
        ) {
            let safeTankCapacity = max(1.0, tankCapacityL)
            let safeBatteryCapacity = max(1.0, batteryCapacityKWh)

            // Tank water fill.
            let tankFraction = min(
                1.0,
                max(0.0, state.tankLiters / safeTankCapacity)
            )

            let filledHeight = max(
                0.01,
                tankHeight * CGFloat(tankFraction)
            )

            if let waterGeometry = waterNode.geometry as? SCNCylinder {
                waterGeometry.height = filledHeight
            }

            waterNode.position = SCNVector3(
                0,
                -tankHeight / 2 + filledHeight / 2,
                0
            )

            // Battery charge fill.
            let batteryFraction = min(
                1.0,
                max(
                    0.0,
                    state.batteryEnergyKWh / safeBatteryCapacity
                )
            )

            if let fillGeometry =
                batteryFillNode.geometry as? SCNBox {
                fillGeometry.height = max(
                    0.015,
                    1.2 * CGFloat(batteryFraction)
                )
            }

            batteryFillNode.position.y = Float(
                -0.65 + 0.6 * batteryFraction
            )

            let batteryColor: UIColor
            if batteryFraction > 0.6 {
                batteryColor = .green
            } else if batteryFraction > 0.3 {
                batteryColor = .orange
            } else {
                batteryColor = .red
            }

            batteryFillNode.geometry?
                .firstMaterial?
                .diffuse.contents = batteryColor

            batteryFillNode.geometry?
                .firstMaterial?
                .emission.contents = batteryColor

            // Condenser light and fan animation.
            condenserLight.geometry?
                .firstMaterial?
                .diffuse.contents = state.condenserOn
                    ? UIColor.green
                    : UIColor.red

            condenserLight.geometry?
                .firstMaterial?
                .emission.contents = state.condenserOn
                    ? UIColor.green
                    : UIColor.red

            if lastCondenserState != state.condenserOn {
                fanNode.removeAllActions()

                if state.condenserOn {
                    let spin = SCNAction.repeatForever(
                        SCNAction.rotateBy(
                            x: 0,
                            y: 0,
                            z: CGFloat.pi * 2,
                            duration: 0.35
                        )
                    )
                    fanNode.runAction(spin)
                }

                lastCondenserState = state.condenserOn
            }

            // Update power meter screen to reflect the latest
            // condenser energy use.
            if let screenNode = scene.rootNode.childNodes.first(
                where: {
                    $0.geometry is SCNPlane
                }
            ), let screenMaterial =
                screenNode.geometry?.firstMaterial {

                let load = record?.condenserPowerKW ?? 0

                screenMaterial.diffuse.contents = UIColor(
                    red: 0.0,
                    green: state.condenserOn ? 0.28 : 0.08,
                    blue: 0.04,
                    alpha: 1.0
                )

                screenMaterial.emission.contents =
                    state.condenserOn
                        ? UIColor.green
                        : UIColor.darkGray

                // Keep the numerical load in the SwiftUI meter below
                // as the authoritative, readable energy measurement.
                _ = load
            }
        }
    }
}

#Preview {
    ContentView()
}

