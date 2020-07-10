//
//  Blocks.swift
//  InAppProvisioningUtils
//
//  Created by s.petruk on 04/10/2019.
//  Copyright © 2019 s.petruk. All rights reserved.
//

import Foundation

public typealias Completion = (Result) -> Void
public typealias InAppResultBlock = (InAppRequest) -> Void
public typealias RequestBlock = (PassData, @escaping InAppResultBlock) -> Void

