const std = @import("std");
usingnamespace @import("source.zig");

const ascii = std.ascii;

pub fn Lexer(comptime TokenId: type) type {
    return struct {

        source: *const Source,
        iterator: Source.Iterator,
        tokenize: Tokenizer,

        pub const Tokenizer = fn (*Self, TokenId) ?Token;

        pub const Token = struct {
            id: TokenId,
            start_loc: Source.Location,
            symbol: []const u8,
        };

        const Self = @This();

        pub fn init(source: *const Source, tokenize: Tokenizer) Self {
            return Self{
                .source = source,
                .iterator = source.iterate(),
                .tokenize = tokenize,
            };
        }

        pub const CharacterFilter = fn (u8) bool;

        pub fn skipManyFilter(self: *Self, comptime filter: CharacterFilter) void {
            const iter = self.iterator;
            while (filter(iter.lookahead[0])) : (iter.next() orelse return) {

            }
        }

        pub fn captureManyFilter(self: *Self, comptime filter: CharacterFilter) []const u8 {

        }

    };
}
