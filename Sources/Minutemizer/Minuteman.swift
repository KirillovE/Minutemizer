//
//  Minuteman.swift
//  
//
//  Created by Eugene KIRILLOV on 05/10/2022.
//

import Foundation

/// A data to store for a specific minuteman
public struct Minuteman: Identifiable {

    /// Unique identifier of the minuteman
    public let id = UUID()

    /// First name of the minuteman
    public let firstName: String

    /// Second name, family name, surname of the minuteman
    public let secondName: String

    /// Middle name of the minuteman, if one exists
    public let middleName: String?
}

/// Will be used to keep the minuteman as a key in a dictionary to store statistics 
extension Minuteman: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}