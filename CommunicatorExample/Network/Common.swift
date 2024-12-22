//
//  Common.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 24..
//

struct Constants {
    static func serviceTypeFormat(serviceName: String) -> String {
        "_\(serviceName)._tcp"
    }
}
