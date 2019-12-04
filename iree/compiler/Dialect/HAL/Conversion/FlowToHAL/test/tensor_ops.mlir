// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// RUN: iree-opt -split-input-file -iree-convert-flow-to-hal %s | IreeFileCheck %s

// CHECK-LABEL: @constantTensor
func @constantTensor() {
  // CHECK-NEXT: %dev = hal.ex.shared_device
  // CHECK-NEXT: %allocator = hal.device.allocator %dev
  // CHECK-NEXT: %cbuffer = hal.allocator.allocate.const %allocator, {{.+}} = dense<[1, 2]> : tensor<2xi32>
  %0 = constant dense<[1, 2]> : tensor<2xi32>
  return
}

// -----

// CHECK-LABEL: @constantTensor1
func @constantTensor1() {
  // CHECK-NEXT: %dev = hal.ex.shared_device
  // CHECK-NEXT: %allocator = hal.device.allocator %dev
  // CHECK-NEXT: %cbuffer = hal.allocator.allocate.const %allocator, {{.+}} = dense<[true, false]> : tensor<2xi1>
  %0 = constant dense<[1, 0]> : tensor<2xi1>
  return
}

// -----

// CHECK-LABEL: @tensorLoad
func @tensorLoad(%arg0 : tensor<2x3xi32>) {
  // CHECK-DAG: [[C0:%.+]] = constant 0 : i32
  // CHECK-DAG: [[C1:%.+]] = constant 1 : i32
  // CHECK-DAG: [[C2:%.+]] = constant 2 : i32
  // CHECK-DAG: [[C3:%.+]] = constant 3 : i32
  %i0 = constant 0 : i32
  %i1 = constant 1 : i32
  // CHECK-NEXT: [[OFF:%.+]] = hal.buffer_view.compute_offset %arg0, shape=[
  // CHECK-SAME:   [[C2]], [[C3]]
  // CHECK-SAME: ], indices=[
  // CHECK-SAME:   [[C0]], [[C1]]
  // CHECK-SAME: ], element_size=4
  // CHECK-NEXT: = hal.buffer.load %arg0[
  // CHECK-SAME:   [[OFF]]
  // CHECK-SAME: ] : i32
  %0 = flow.tensor.load %arg0[%i0, %i1] : tensor<2x3xi32>
  return
}

// -----

// CHECK-LABEL: @tensorLoad1
func @tensorLoad1(%arg0 : tensor<i1>) {
  // CHECK-NEXT: [[OFF:%.+]] = hal.buffer_view.compute_offset %arg0, shape=[], indices=[], element_size=1
  // CHECK-NEXT: = hal.buffer.load %arg0[
  // CHECK-SAME:   [[OFF]]
  // CHECK-SAME: ] : i1
  %0 = flow.tensor.load %arg0 : tensor<i1>
  return
}

// -----

// CHECK-LABEL: @tensorStore
func @tensorStore(%arg0 : tensor<2x3xi32>) {
  // CHECK-DAG: [[C0:%.+]] = constant 0 : i32
  // CHECK-DAG: [[C1:%.+]] = constant 1 : i32
  // CHECK-DAG: [[C9:%.+]] = constant 9 : i32
  // CHECK-DAG: [[C2:%.+]] = constant 2 : i32
  // CHECK-DAG: [[C3:%.+]] = constant 3 : i32
  %i0 = constant 0 : i32
  %i1 = constant 1 : i32
  %c9 = constant 9 : i32
  // CHECK-NEXT: [[OFF:%.+]] = hal.buffer_view.compute_offset %arg0, shape=[
  // CHECK-SAME:   [[C2]], [[C3]]
  // CHECK-SAME: ], indices=[
  // CHECK-SAME:   [[C0]], [[C1]]
  // CHECK-SAME: ], element_size=4
  // CHECK-NEXT: hal.buffer.store [[C9]], %arg0[
  // CHECK-SAME:   [[OFF]]
  // CHECK-SAME: ] : i32
  flow.tensor.store %c9, %arg0[%i0, %i1] : tensor<2x3xi32>
  return
}

// -----

// CHECK-LABEL: @tensorStore1
func @tensorStore1(%arg0 : tensor<i1>) {
  // CHECK-DAG: [[C1:%.+]] = constant 1 : i1
  %c1 = constant 1 : i1
  // CHECK-NEXT: [[OFF:%.+]] = hal.buffer_view.compute_offset %arg0, shape=[], indices=[], element_size=1
  // CHECK-NEXT: hal.buffer.store [[C1]], %arg0[
  // CHECK-SAME:   [[OFF]]
  // CHECK-SAME: ] : i1
  flow.tensor.store %c1, %arg0 : tensor<i1>
  return
}
