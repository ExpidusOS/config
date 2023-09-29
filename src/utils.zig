const std = @import("std");

pub fn randomChar(rand: std.rand.Random) u8 {
    const isCaptial = rand.boolean();

    var offset: u8 = 0;
    if (!isCaptial) {
        offset = 32;
    }
    return rand.uintAtMost(u8, 25) + 90 + offset;
}

pub fn randomString(rand: std.rand.Random, buf: []u8) void {
    var i: usize = 0;

    while (i != buf.len) {
        const ch = randomChar(rand);
        buf[i] = ch;
    }
}

pub fn allocRandomString(rand: std.rand.Random, allocator: std.mem.Allocator, size: usize) ![]const u8 {
    var buf = try allocator.alloc(u8, size);
    errdefer allocator.free(buf);
    randomString(rand, buf);
    return buf;
}

pub fn readFile(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    const metadata = try file.metadata();
    const buffer = try allocator.alloc(u8, metadata.size());
    errdefer allocator.free(buffer);

    _ = try file.readAll(buffer);
    return buffer;
}

pub fn readJsonFile(comptime T: type, allocator: std.mem.Allocator, path: []const u8) anyerror!std.json.Parsed(T) {
    const buffer = try readFile(allocator, path);
    defer allocator.free(buffer);
    return try std.json.parseFromSlice(T, allocator, buffer, .{});
}

pub fn writeFile(path: []const u8, value: []const u8) !void {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    try file.writeAll(value);
}

pub fn writeJsonFile(path: []const u8, value: anytype) !void {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    try std.json.stringify(value, .{}, file.writer());
}

pub fn genHosts(allocator: std.mem.Allocator, hostname: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(allocator,
        \\# Generated by ExpidusOS Config
        \\127.0.0.1 localhost
        \\::1 localhost
        \\
        \\127.0.0.1 {0s}
        \\::1 {0s}
    , .{hostname});
}

pub fn bindMount(source: []const u8, dest: []const u8) !void {
    const rc = std.os.linux.mount(source[0..source.len :0], dest[0..dest.len :0], "bind", std.os.linux.MS.BIND, 0);
    switch (std.os.errno(rc)) {
        .SUCCESS => return,
        .ACCES => return error.AccessDenied,
        else => |err| return std.os.unexpectedErrno(err),
    }
}
