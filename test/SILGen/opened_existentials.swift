// RUN: %target-swift-emit-silgen %s | %FileCheck %s

public protocol P { }

func f() -> String {
  print("f()")
  return "Hello"
}

func g<T: P> (_ value: String, _: T) -> String {
  print("g()")
  return value + ", world"
}

extension Int: P { }

func getP() -> any P {
  return 17
}

// CHECK: sil [ossa] @$s19opened_existentials4testSSyF : $@convention(thin) () -> @owned String
public func test() -> String {
  // FIXME: This demonstrates that we are opening the existential out of
  // order. This test will break when we properly update the existential-opening
  // logic to wait until the argument is evaluated.

  // CHECK: [[PSTACK:%.*]] = alloc_stack $P
  // CHECK: [[GETP:%.*]] = function_ref @$s19opened_existentials4getPAA1P_pyF : $@convention(thin) () -> @out P // user: %2
  // CHECK: [[P:%.*]] = apply [[GETP]]([[PSTACK]]) : $@convention(thin) () -> @out P
  // CHECK: [[OPENEDP:%.*]] = open_existential_addr immutable_access [[PSTACK]] : $*P to $*@opened
  // CHECK: [[F:%.*]] = function_ref @$s19opened_existentials1fSSyF : $@convention(thin) () -> @owned String
  // CHECK: [[F_RESULT:%.*]] = apply [[F]]() : $@convention(thin) () -> @owned String
  g(f(), getP())
}

