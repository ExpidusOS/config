const std = @import("std");
const SystemConfig = @import("sys.zig");
const LastState = @import("types.zig").LastState;
const utils = @import("utils.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var prng = std.rand.DefaultPrng.init(@intCast(std.time.microTimestamp()));
    const rand = prng.random();

    if (std.os.linux.geteuid() != 0) {
        std.log.err("expidus-config must be executed by root.", .{});
        return error.AccessDenied;
    }

    var sysconfig = try SystemConfig.fromFile(alloc, "/data/config/system.json");
    defer sysconfig.deinit();

    if (!try utils.isLocaleSupported(alloc, sysconfig.locale)) {
        std.log.err("Locale {s} is not supported by the system.", .{sysconfig.locale});
        return error.NotSupported;
    }

    if (sysconfig.lastState) |lastState| {
        _ = std.os.linux.umount("/etc/hostname");
        _ = std.os.linux.umount("/etc/hosts");
        _ = std.os.linux.umount("/etc/locale.conf");
        try std.fs.deleteTreeAbsolute(lastState.path);
    }

    const tmpdirSuffix = try utils.allocRandomString(rand, alloc, 8);
    defer alloc.free(tmpdirSuffix);

    const tmpdir = try std.fmt.allocPrint(alloc, "/tmp/expidus-config.{s}", .{tmpdirSuffix});
    defer alloc.free(tmpdir);

    sysconfig.lastState = LastState.init(try alloc.dupe(u8, tmpdir));
    try sysconfig.toFile("/data/config/system.json");

    try std.fs.makeDirAbsolute(tmpdir);

    try utils.writeFile("/proc/sys/kernel/hostname", sysconfig.hostname);

    const hostnamePath = try std.fs.path.join(alloc, &.{ tmpdir, "hostname" });
    defer alloc.free(hostnamePath);

    try utils.writeFile(hostnamePath, sysconfig.hostname);

    const hosts = try utils.genHosts(alloc, sysconfig.hostname);
    defer alloc.free(hosts);

    const hostsPath = try std.fs.path.join(alloc, &.{ tmpdir, "hosts" });
    defer alloc.free(hostsPath);

    try utils.writeFile(hostsPath, hosts);

    const localePath = try std.fs.path.join(alloc, &.{ tmpdir, "locale.conf" });
    defer alloc.free(localePath);

    const localeConfig = try std.fmt.allocPrint(alloc,
        \\LANG={s}
    , .{sysconfig.locale});
    defer alloc.free(localeConfig);
    try utils.writeFile(localePath, localeConfig);

    try utils.bindMount(hostnamePath, "/etc/hostname");
    try utils.bindMount(hostsPath, "/etc/hosts");
    try utils.bindMount(localePath, "/etc/locale.conf");
}
