const std = @import("std");

pub const math = std.math;
pub const pi = math.pi;
pub const half_pi = 0.5 * pi;
pub const tau = math.tau;

pub fn sin(x: f32) f32 {
    var r = x - @floor((x + pi) / tau) * tau;

    if (r > half_pi) {
        r = pi - r;
    } else if (r < -half_pi) {
        r = -pi - r;
    }

    const r2 = r * r;
    return r * (1 + r2 * (-1.0 / 6.0 + r2 * (1.0 / 120.0 + r2 * (-1.0 / 5040.0))));
}

pub fn cos(x: f32) f32 {
    return sin(x + half_pi);
}

fn atanSmall(x: f32) f32 {
    const x2 = x * x;
    return x * (1.0 + x2 * (-1.0 / 3.0 + x2 * (1.0 / 5.0 + x2 * (-1.0 / 7.0 + x2 * (1.0 / 9.0 + x2 * (-1.0 / 11.0 + x2 * (1.0 / 13.0)))))));
}

fn atanUnit(x: f32) f32 {
    if (x > 0.41421356237) {
        return pi / 4.0 + atanSmall((x - 1.0) / (x + 1.0));
    }
    return atanSmall(x);
}

pub fn atan(x: f32) f32 {
    const a = @abs(x);
    const result = if (a > 1.0)
        half_pi - atanUnit(1.0 / a)
    else
        atanUnit(a);

    return if (x < 0.0) -result else result;
}

pub fn atan2(y: f32, x: f32) f32 {
    if (x > 0) return atan(y / x);
    if (x < 0) {
        if (y >= 0) return atan(y / x) + pi;
        return atan(y / x) - pi;
    }
    if (y > 0) return half_pi;
    if (y < 0) return -half_pi;
    return 0;
}

pub fn asin(x: f32) f32 {
    if (@abs(x) > 1) return math.nan(f32);
    return atan2(x, @sqrt(1 - x * x));
}

pub fn acos(x: f32) f32 {
    if (@abs(x) > 1) return math.nan(f32);
    return half_pi - asin(x);
}

test "sin" {
    var i: i32 = -1000;
    while (i <= 1000) : (i += 1) {
        const x: f32 = @as(f32, @floatFromInt(i)) * 0.1;
        try std.testing.expectApproxEqAbs(@sin(x), sin(x), 0.001);
    }
}

test "cos" {
    var i: i32 = -1000;
    while (i <= 1000) : (i += 1) {
        const x: f32 = @as(f32, @floatFromInt(i)) * 0.1;
        try std.testing.expectApproxEqAbs(@cos(x), cos(x), 0.001);
    }
}

test "atan" {
    var i: i32 = -1000;
    while (i <= 1000) : (i += 1) {
        const x: f32 = @as(f32, @floatFromInt(i)) * 0.01;
        try std.testing.expectApproxEqAbs(math.atan(x), atan(x), 0.005);
    }
}

test "atan2" {
    var yi: i32 = -10;
    while (yi <= 10) : (yi += 1) {
        var xi: i32 = -10;
        while (xi <= 10) : (xi += 1) {
            if (xi == 0 and yi == 0) continue;

            const y: f32 = @floatFromInt(yi);
            const x: f32 = @floatFromInt(xi);
            try std.testing.expectApproxEqAbs(math.atan2(y, x), atan2(y, x), 0.005);
        }
    }
}

test "asin" {
    var i: i32 = -99;
    while (i <= 99) : (i += 1) {
        const x: f32 = @as(f32, @floatFromInt(i)) * 0.01;
        try std.testing.expectApproxEqAbs(math.asin(x), asin(x), 0.005);
    }
}

test "acos" {
    var i: i32 = -99;
    while (i <= 99) : (i += 1) {
        const x: f32 = @as(f32, @floatFromInt(i)) * 0.01;
        try std.testing.expectApproxEqAbs(math.acos(x), acos(x), 0.005);
    }
}
