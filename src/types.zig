const std = @import("std");

pub const LastState = struct {
    path: []const u8,
    timestamp: i64,

    pub fn init(path: []const u8) LastState {
        return .{
            .path = path,
            .timestamp = std.time.microTimestamp(),
        };
    }

    pub fn dupe(self: LastState, allocator: std.mem.Allocator) !LastState {
        return .{
            .path = try allocator.dupe(u8, self.path),
            .timestamp = self.timestamp,
        };
    }

    pub fn deinit(self: LastState, allocator: std.mem.Allocator) void {
        allocator.free(self.path);
    }
};
