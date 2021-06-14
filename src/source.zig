const std = @import("std");


pub const Source = struct {
    file_name: ?[]const u8 = null,
    text: []const u8,

    const Self = @This();

    pub fn init(file_name: ?[]const u8, text: []const u8) Self {
        return Self{
            .file_name = file_name,
            .text = text,
        };
    }

    pub const iterate = Iterator.init;

    pub const Iterator = SourceIterator;
    pub const Index = SourceIndex;
    
    pub const EndOfFile = error {
        EndOfFile,
    };

};

pub const SourceIndex = struct {

    offset: usize = 0,
    line_number: usize = 1,
    column_number: usize = 1,

};

pub const SourceIterator = struct {

    source: *Source,
    /// the previous index accessed. null if iterator has not advanced since initialization
    prev_index: ?SourceIndex = null,
    /// the next index to access. null if iterator has not advanced since initialization
    next_index: ?SourceIndex = .{},

    const Self = @This();

    const EndOfFile = Source.EndOfFile;

    pub fn init(source: *const Source) Self {
        var self = Self{
            .source = source,
        };
        // B. Edge cases matter.
        if (source.text.len == 0) {
            self.next_index = null;
        }
        return self;
    }

    pub fn reset(self: *Self) void {
        self.* = init(self.source);
    }

    /// get the character at `next_index` (or null if EOF)
    pub fn peek(self: Self) EndOfFile!u8 {
        if (self.next_index) |next_index| {
            return self.source.text[next_index.offset];
        }
        else {
            return EndOfFile.EndOfFile;
        }
    }

    /// get the next_index character and advances source location
    /// returns null if eof is next
    pub fn next(self: *Self) EndOfFile!u8 {
        if (self.next_index) |*next_index| {
            self.prev_index = next_index;
            next_index.offset += 1;
            const char = source.text[next_index.offset];
            if (next_index.offset >= self.source.text.len) {
                self.next_index = null;
            }
            else {
                if (char == '\n') {
                    next_index.line_number += 1;
                    next_index.column_number = 1;
                }
                else {
                    next_index.column_number += 1;
                }
            }
            return char;
        }
        else {
            return EndOfFile.EndOfFile;
        }
    }



};
