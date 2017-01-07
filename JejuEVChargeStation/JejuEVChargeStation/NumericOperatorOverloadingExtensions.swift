//
//  NumericOperatorOverloadingExtensions.swift
//  JejuEVChargeStation
//
//  Created by Tae Jong Yoo on 2016. 11. 21..
//  Copyright © 2016년 Tae-Jong Yu. All rights reserved.
//

import Foundation

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////// ADDITION ////////////////////////////////////////////////////////////////
public func +(a: Float, scalar: Int)  -> Float  { return a + Float(scalar); }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////// MULTIPLICATION  //////////////////////////////////////////////////////////////
// Int *
public func *(a: Int, scalar: Float)    -> Float    { return Float(a) * scalar; }
public func *(a: Int, scalar: Double)   -> Double   { return Double(a) * scalar; }
public func *(scalar: Float, a: Int)    -> Float    { return Float(a) * scalar; }
public func *(scalar: Double, a: Int)   -> Double   { return Double(a) * scalar; }

// Int8 *
public func *(a: Int8, scalar: Float)    -> Float    { return Float(a) * scalar; }
public func *(a: Int8, scalar: Double)   -> Double   { return Double(a) * scalar; }
public func *(scalar: Float, a: Int8)    -> Float    { return Float(a) * scalar; }
public func *(scalar: Double, a: Int8)   -> Double   { return Double(a) * scalar; }

// Int32 *
public func *(a: Int32, scalar: Float)    -> Float    { return Float(a) * scalar; }
public func *(a: Int32, scalar: Double)   -> Double   { return Double(a) * scalar; }
public func *(scalar: Float, a: Int32)    -> Float    { return Float(a) * scalar; }
public func *(scalar: Double, a: Int32)   -> Double   { return Double(a) * scalar; }

// Float *
public func *(a: Float, scalar: Double)  -> Float  { return a * Float(scalar); }
public func *(a: Float, scalar: Double)  -> Double  { return Double(a) * scalar; }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////// DIVISION ////////////////////////////////////////////////////////////////
// Double /
public func /(a: Double, b: Int)  -> Double  { return a / Double(b); }
public func /(a: Double, b: Float)  -> Double  { return a / Double(b); }
public func /(a: Double, b: Int)  -> Int  { return Int(a) / b; }
public func /(a: Int, b: Double)  -> Double  { return Double(a) / b; }
public func /(a: Int, b: Double)  -> Int  { return Int(Double(a) / b); }

// Float /
public func /(a: Float, b: Int)  -> Float  { return a / Float(b); }
public func /(a: Float, b: Int)  -> Int  { return Int(a) / b; }
public func /(a: Int, b: Float)  -> Float  { return Float(a) / b; }
public func /(a: Int, b: Float)  -> Int  { return Int(Float(a) / b); }
public func /(a: Float, scalar: Double)  -> Float  { return a / Float(scalar); }
