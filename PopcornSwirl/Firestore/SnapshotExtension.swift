//
//  SnapshotExtension.swift
//  PopcornSwirl
//
//  Created by zsolt on 14/11/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

extension DocumentSnapshot {
    func decode<T: Decodable>(as objectType: T.Type, includingId: Bool = true) throws -> T {
        var documentJson = data()
        if includingId {
            documentJson!["documentId"] = documentID
        }
        let documentData = try JSONSerialization.data(withJSONObject: documentJson as Any, options: [])
        let decodedObject = try JSONDecoder().decode(objectType, from: documentData)
        
        return decodedObject
    }
}
