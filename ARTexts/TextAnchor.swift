//
//  TextAnchor.swift
//  ARTexts
//
//  Created by James Folk on 11/16/17.
//  Copyright © 2017 James Folk. All rights reserved.
//

import Foundation
import ARKit

class TextAnchor: ARAnchor
{
    public var text:String! = "👾👾"
    
    public override init(transform: matrix_float4x4)
    {
        super.init(transform: transform)
    }
}
