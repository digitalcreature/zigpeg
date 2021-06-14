const std = @import("std");
const fp = @import("fp");
usingnamespace @import("source.zig");

const Iter = Source.Iterator;
const Predicate = fp.Predicate;

pub const CharFilter = Predicate(u8);

pub const ParseFn = fn(*Iter) anyerror!void;

pub const ParseExpr = struct {
    
    parseFn: ParseFn,

    const Self = @This();

    pub fn init(parseFn: ParseFn) Self {
        return Self{
            .parseFn = parseFn,
        };
    }

    pub fn parse(self: Self, iter: *Iter) anyerror!void {
        var child_iter: Iter = iter.*;
        if (self.parseFn(&child_iter)) {
            iter.* = child_iter;
        }
        else |err| {
            return err;
        }
    }

    pub fn peek(self: Self, iter: *Iter) anyerror!void {
        const saved_iter: Iter = iter.*;
        defer iter.* = saved_iter;
        try self.parse(iter);
    }

    pub const empty = Self{
        .parseFn = struct {
            pub fn ___ (iter: *Iter) !void {}
        }.___,
    };

    pub const endOfFile = Self{
        .parseFn = struct {
            pub fn ___ (iter: *Iter) !void {
                if (iter.next()) |_| {
                    return error.MatchFailed;
                }
                else |err| {
                    if (err != .EndOfFile) {
                        return error.MatchFailed;
                    }
                }
            }
        }.___,
    };

    pub fn then(comptime self: Self, comptime other: Self) Self {
        const parseFn = struct {

            pub fn ___ (iter: *Iter) !void {
                try self.parse(iter);
                try other.parse(iter);
            }

        }.___;
        return init(parseFn);
    }

    pub fn orElse(comptime self: Self, comptime other: Self) Self {
        const parseFn = struct {

            pub fn ___ (iter: *Iter) !void {
                if (self.parse(iter)) |_| {

                }
                else |_| {
                    try other.parse(iter);
                }
            }

        }.___;
        return init(parseFn);
    }

    pub fn zeroPlus(comptime self: Self) Self {
        const parseFn = struct {

            pub fn ___ (iter: *Iter) !void {
                while (self.parse(iter)) {}
            }

        }.___;
        return init(parseFn);
    }

    pub fn onePlus(comptime self: Self) Self {
        return self.then(self.zeroPlus());
    }

    pub fn option(comptime self: Self) Self {
        return self.orElse(empty);
    }

    pub fn lookAhead(comptime self: Self) Self {
        const parseFn = struct {

            pub fn ___ (iter: *Iter) !void {
                try self.peek(iter);
            }

        }.___;
        return init(parseFn);
    }

    pub fn lookAheadInverse(comptime self: Self) Self {
        const parseFn = struct {

            pub fn ___ (iter: *Iter) !void {
                if (self.peek(iter)) {
                    return error.MatchFailed;
                }
                else |_| {
                    return;
                }
            }

        }.___;
        return init(parseFn);
    }

    pub fn literalChar(comptime char: u8) Self {
        const parseFn = struct {
            pub fn ___ (iter: *Iter) !void {
                if ((try iter.next()) != char) {
                    return error.MatchFailed;
                }
            }
        }.___;
        return init(parseFn);
    }

    pub fn literalString(comptime string: []const u8) Self {
        const parseFn = struct {
            pub fn ___ (iter: *Iter) !void {
                for (string) |char| {
                    if ((try iter.next()) != char) {
                        return error.MatchFailed;
                    }
                }
            }
        }.___;
        return init(parseFn);
    }

    pub fn charFilter(comptime filter: CharFilter) Self {
        const parseFn = struct {
            pub fn ___ (iter: *Iter) !void {
                const char = try iter.next();
                if (!filter(char)) {
                    return error.MatchFailed;
                }
            }
        }.___;
        return init(parseFn);
    }

    pub fn charInSet(comptime valid_char_set: []const u8) Self{
        const parseFn = struct {
            pub fn ___ (iter: *Iter) !void {
                const char = try iter.next();
                for (valid_char_set) |valid_char| {
                    if (valid_char == char) return;
                }
                return error.MatchFailed;
            }
        }.___;
        return init(parseFn);

    }

    const ascii = std.ascii; 


    // ascii matchers

    pub const digitChar = charFilter(ascii.isDigit);
    pub const alphaChar = charFilter(ascii.isAlpha);
    pub const alphaNumericChar = charFilter(ascii.isAlNum);


};
