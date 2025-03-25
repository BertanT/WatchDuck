/*
 CLISpinner.swift
 Created on 7/20/24.
 
 Copyright (C) 2024, 2025 Mehmet Bertan Tarakcioglu
 
 This file is part of WatchDuck.
 
 WatchDuck is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 WatchDuck is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License along with WatchDuck.
 If not, see <https://www.gnu.org/licenses/>.
*/

import Foundation

struct CLISpinner {
    enum LoadingResult {
        case success, warning, failure
    }

    private var task: Task<Void, Error>?

    private static func rPrint(_ text: String = "", terminator: String = "\n") {
        print("\u{1B}[A", terminator: "")
        print("\r\u{001B}[K", terminator: "")
        print(text, terminator: terminator)
    }

    mutating func start(_ text: String, frames: [String] = PackageResources.spinnerFrames, frameDelay: TimeInterval = 0.2) {
        self.task?.cancel()
        self.task = Task.detached {
            var fIndex = 0

            print()
            while !Task.isCancelled {
                fIndex = (fIndex + 1) % frames.count
                Self.rPrint("→ " + text + frames[fIndex])
                await Task.yield()
                try? await Task.sleep(interval: frameDelay)
            }
            Self.rPrint(terminator: "")
            throw CancellationError()
        }
    }

    func stop(_ message: String? = nil, result: LoadingResult? = nil) async {
        guard let task else {
            return
        }

        task.cancel()
        try? await task.value

        if let message {
            switch result {
            case .success:
                print("✔ \(message)".color(.green))
            case .warning:
                print("! \(message)".color(.yellow))
            case .failure:
                print("𝗫 \(message)".color(.red))
            case nil:
                print(message)
            }
        }
    }
}
