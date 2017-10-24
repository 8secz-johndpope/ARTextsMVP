//
//  ARAnchorText.swift
//  ARTexts
//
//  Created by James Folk on 9/25/17.
//  Copyright © 2017 James Folk. All rights reserved.
//

import ARKit

class ARAnchorText: ARAnchor
{
    public var text:String! = "INSERT TEXT"
    
    public override init(transform: matrix_float4x4)
    {
        super.init(transform: transform)
    }
}
