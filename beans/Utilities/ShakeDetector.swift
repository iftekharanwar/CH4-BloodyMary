//
//  ShakeDetector.swift
//  Beans
//

import CoreMotion
import Combine

final class ShakeDetector: ObservableObject {
    static let shared = ShakeDetector()

    let shakeDetected = PassthroughSubject<Void, Never>()

    private let motionManager = CMMotionManager()
    private let threshold: Double = 1.0
    private var lastShakeTime: Date = .distantPast
    private let cooldown: TimeInterval = 1.0

    private init() {}

    func start() {
        guard motionManager.isAccelerometerAvailable, !motionManager.isAccelerometerActive else { return }
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, _ in
            guard let self = self, let data = data else { return }
            let acceleration = data.acceleration
            let magnitude = sqrt(
                acceleration.x * acceleration.x +
                acceleration.y * acceleration.y +
                acceleration.z * acceleration.z
            )
            // Subtract gravity (1g) to isolate movement
            let movement = magnitude - 1.0
            let now = Date()
            if abs(movement) > self.threshold && now.timeIntervalSince(self.lastShakeTime) > self.cooldown {
                self.lastShakeTime = now
                self.shakeDetected.send()
            }
        }
    }

    func stop() {
        motionManager.stopAccelerometerUpdates()
    }
}
