const std = @import("std");

pub fn Function(comptime X: type, comptime R: type) type {
    return fn(X) T;
}

pub fn Predicate(comptime X: type) type {
    return Function(X, bool);
} 

pub fn negatePredicate(comptime X: type, comptime predicate: Predicate(X)) Predicate(X) {
    return compose(X, bool, bool, predicate, operators.booleanNot);
}

pub fn compose(comptime X: type, comptime Y: type, comptime Z: type, comptime f: Function(X, Y), comptime g: Function(Y, Z)) Function(X, Z) {
    return struct {
        pub fn ___(x: X) Z {
            const y = f(x);
            return g(y);
        }
    }.___;
}

pub const operators = struct {

    pub fn booleanNot(a: bool) bool {
        return !a;
    }

};