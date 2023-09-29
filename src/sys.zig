const std = @import("std");
const utils = @import("utils.zig");

const Self = @This();

allocator: std.mem.Allocator,
hostname: []const u8,

pub fn fromFile(allocator: std.mem.Allocator, path: []const u8) !Self {
    const parsed = try utils.readJsonFile(struct {
        hostname: []const u8,
    }, allocator, path);
    defer parsed.deinit();

    return .{
        .allocator = allocator,
        .hostname = try allocator.dupe(u8, parsed.value.hostname),
    };
}

pub fn deinit(self: Self) void {
    self.allocator.free(self.hostname);
}
