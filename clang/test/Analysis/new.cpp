// RUN: %clang_analyze_cc1 -analyzer-checker=core,unix.Malloc,debug.ExprInspection -std=c++11 -verify -analyzer-config eagerly-assume=false %s
// RUN: %clang_analyze_cc1 -analyzer-checker=core,unix.Malloc,debug.ExprInspection -std=c++11 -DTEST_INLINABLE_ALLOCATORS -verify -analyzer-config eagerly-assume=false %s
#include "Inputs/system-header-simulator-cxx.h"

void clang_analyzer_eval(bool);
void clang_analyzer_warnIfReached();

typedef __typeof__(sizeof(int)) size_t;
extern "C" void *malloc(size_t);
extern "C" void free(void *);

int someGlobal;

class SomeClass {
public:
  void f(int *p);
};

void testImplicitlyDeclaredGlobalNew() {
  if (someGlobal != 0)
    return;

  // This used to crash because the global operator new is being implicitly
  // declared and it does not have a valid source location. (PR13090)
  void *x = ::operator new(0);
  ::operator delete(x);

  // Check that the new/delete did not invalidate someGlobal;
  clang_analyzer_eval(someGlobal == 0); // expected-warning{{TRUE}}
}

void *testPlacementNew() {
  int *x = (int *)malloc(sizeof(int));
  *x = 1;
  clang_analyzer_eval(*x == 1); // expected-warning{{TRUE}};

  void *y = new (x) int;
  clang_analyzer_eval(x == y); // expected-warning{{TRUE}};
  clang_analyzer_eval(*x == 1); // expected-warning{{TRUE}};

  return y;
}

void *operator new(size_t, size_t, int *);
void *testCustomNew() {
  int x[1] = {1};
  clang_analyzer_eval(*x == 1); // expected-warning{{TRUE}};

  void *y = new (0, x) int;
  clang_analyzer_eval(*x == 1); // expected-warning{{UNKNOWN}};

  return y; // no-warning
}

void *operator new(size_t, void *, void *);
void *testCustomNewMalloc() {
  int *x = (int *)malloc(sizeof(int));

  // Should be no-warning (the custom allocator could have freed x).
  void *y = new (0, x) int; // no-warning

  return y;
}

void testScalarInitialization() {
  int *n = new int(3);
  clang_analyzer_eval(*n == 3); // expected-warning{{TRUE}}

  new (n) int();
  clang_analyzer_eval(*n == 0); // expected-warning{{TRUE}}

  new (n) int{3};
  clang_analyzer_eval(*n == 3); // expected-warning{{TRUE}}

  new (n) int{};
  clang_analyzer_eval(*n == 0); // expected-warning{{TRUE}}
}

struct PtrWrapper {
  int *x;

  PtrWrapper(int *input) : x(input) {}
};

PtrWrapper *testNewInvalidation() {
  // Ensure that we don't consider this a leak.
  return new PtrWrapper(static_cast<int *>(malloc(4))); // no-warning
}

void testNewInvalidationPlacement(PtrWrapper *w) {
  // Ensure that we don't consider this a leak.
  new (w) PtrWrapper(static_cast<int *>(malloc(4))); // no-warning
}

int **testNewInvalidationScalar() {
  // Ensure that we don't consider this a leak.
  return new (int *)(static_cast<int *>(malloc(4))); // no-warning
}

void testNewInvalidationScalarPlacement(int **p) {
  // Ensure that we don't consider this a leak.
  new (p) (int *)(static_cast<int *>(malloc(4))); // no-warning
}

void testCacheOut(PtrWrapper w) {
  extern bool coin();
  if (coin())
    w.x = 0;
  new (&w.x) (int*)(0); // we cache out here; don't crash
}

void testUseAfter(int *p) {
  SomeClass *c = new SomeClass;
  free(p);
  c->f(p); // expected-warning{{Use of memory after it is released}}
  delete c;
}

// new/delete oparators are subjects of cplusplus.NewDelete.
void testNewDeleteNoWarn() {
  int i;
  delete &i; // no-warning

  int *p1 = new int;
  delete ++p1; // no-warning

  int *p2 = new int;
  delete p2;
  delete p2; // no-warning

  int *p3 = new int; // no-warning
}

void testDeleteMallocked() {
  int *x = (int *)malloc(sizeof(int));
  // unix.MismatchedDeallocator would catch this, but we're not testing it here.
  delete x;
}

void testDeleteOpAfterFree() {
  int *p = (int *)malloc(sizeof(int));
  free(p);
  operator delete(p); // expected-warning{{Use of memory after it is released}}
}

void testDeleteAfterFree() {
  int *p = (int *)malloc(sizeof(int));
  free(p);
  delete p; // expected-warning{{Use of memory after it is released}}
}

void testStandardPlacementNewAfterFree() {
  int *p = (int *)malloc(sizeof(int));
  free(p);
  p = new(p) int; // expected-warning{{Use of memory after it is released}}
}

void testCustomPlacementNewAfterFree() {
  int *p = (int *)malloc(sizeof(int));
  free(p);
  p = new(0, p) int; // expected-warning{{Use of memory after it is released}}
}

void testUsingThisAfterDelete() {
  SomeClass *c = new SomeClass;
  delete c;
  c->f(0); // no-warning
}

void testAggregateNew() {
  struct Point { int x, y; };
  new Point{1, 2}; // no crash

  Point p;
  new (&p) Point{1, 2}; // no crash
  clang_analyzer_eval(p.x == 1); // expected-warning{{TRUE}}
  clang_analyzer_eval(p.y == 2); // expected-warning{{TRUE}}
}

int testNoInitialization() {
  int *n = new int;

  if (*n) { // expected-warning{{Branch condition evaluates to a garbage value [core.uninitialized.Branch]}}
    delete n;
    return 0;
  }
  delete n;
  return 1;
}

//===----------------------------------------------------------------------===//
// Incorrectly-modelled behavior.
//===----------------------------------------------------------------------===//

int testNoInitializationPlacement() {
  int n;
  new (&n) int;

  if (n) { // expected-warning{{Branch condition evaluates to a garbage value}}
    return 0;
  }
  return 1;
}

// Test modelling destructor call on call to delete
class IntPair{
public:
  int x;
  int y;
  IntPair() {};
  ~IntPair() {x = x/y;}; //expected-warning {{Division by zero}}
};

void testCallToDestructor() {
  IntPair *b = new IntPair();
  b->x = 1;
  b->y = 0;
  delete b; // This results in divide by zero in destructor
}

// Test Deleting a value that's passed as an argument.
class DerefClass{
public:
  int *x;
  DerefClass() {};
  ~DerefClass() {*x = 1;}; //expected-warning {{Dereference of null pointer (loaded from field 'x')}}
};

void testDestCall(DerefClass *arg) {
  delete arg;
}

void test_delete_dtor_Arg() {
  DerefClass *pair = new DerefClass();
  pair->x = 0;
  testDestCall(pair);
}

//Deleting the address of a local variable, null pointer
void abort(void) __attribute__((noreturn));

class NoReturnDtor {
public:
  NoReturnDtor() {}
  ~NoReturnDtor() {abort();}
};

void test_delete_dtor_LocalVar() {
  NoReturnDtor test;
  delete &test; // no warn or crash
}

class DerivedNoReturn:public NoReturnDtor {
public:
  DerivedNoReturn() {};
  ~DerivedNoReturn() {};
};

void testNullDtorDerived() {
  DerivedNoReturn *p = new DerivedNoReturn();
  delete p; // Calls the base destructor which aborts, checked below
  clang_analyzer_eval(true); // no warn
}

//Deleting a non-class pointer should not crash/warn
void test_var_delete() {
  int *v = new int;
  delete v;  // no crash/warn
  clang_analyzer_eval(true); // expected-warning{{TRUE}}
}

void test_array_delete() {
  class C {
  public:
    ~C() {}
  };

  auto c1 = new C[2][3];
  delete[] c1; // no-crash // no-warning

  C c2[4];
  // FIXME: Should warn.
  delete[] &c2; // no-crash

  C c3[7][6];
  // FIXME: Should warn.
  delete[] &c3; // no-crash
}

void testDeleteNull() {
  NoReturnDtor *foo = 0;
  delete foo; // should not call destructor, checked below
  clang_analyzer_eval(true); // expected-warning{{TRUE}}
}

void testNullAssigneddtor() {
  NoReturnDtor *p = 0;
  NoReturnDtor *s = p;
  delete s; // should not call destructor, checked below
  clang_analyzer_eval(true); // expected-warning{{TRUE}}
}

void deleteArg(NoReturnDtor *test) {
  delete test;
}

void testNulldtorArg() {
  NoReturnDtor *p = 0;
  deleteArg(p);
  clang_analyzer_eval(true); // expected-warning{{TRUE}}
}

void testDeleteUnknown(NoReturnDtor *foo) {
  delete foo; // should assume non-null and call noreturn destructor
  clang_analyzer_eval(true); // no-warning
}

void testArrayNull() {
  NoReturnDtor *fooArray = 0;
  delete[] fooArray; // should not call destructor, checked below
  clang_analyzer_eval(true); // expected-warning{{TRUE}}
}

void testArrayDestr() {
  NoReturnDtor *p = new NoReturnDtor[2];
  delete[] p;
  clang_analyzer_warnIfReached(); // no-warning
}
