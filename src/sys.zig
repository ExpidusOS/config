const std = @import("std");
const utils = @import("utils.zig");
const LastState = @import("types.zig").LastState;

const Self = @This();

const Raw = struct {
    hostname: []const u8,
    lastState: ?LastState = null,
};

allocator: std.mem.Allocator,
hostname: []const u8,
lastState: ?LastState,

pub fn fromFile(allocator: std.mem.Allocator, path: []const u8) !Self {
    const parsed = try utils.readJsonFile(Raw, allocator, path);
    defer parsed.deinit();

    return .{
        .allocator = allocator,
        .hostname = try allocator.dupe(u8, parsed.value.hostname),
        .lastState = if (parsed.value.lastState) |lastState| try lastState.dupe(allocator) else null,
    };
}

pub fn deinit(self: Self) void {
    self.allocator.free(self.hostname);
    if (self.lastState) |lastState| lastState.deinit(self.allocator);
}

pub fn toFile(self: Self, path: []const u8) !void {
    try utils.writeJsonFile(path, Raw{
        .hostname = self.hostname,
        .lastState = self.lastState,
    });
}
