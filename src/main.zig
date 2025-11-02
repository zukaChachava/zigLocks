const std = @import("std");
const zigLocks = @import("zigLocks");

pub fn main() !void {
    var lock = zigLocks.AutoResetEvent.init(1);
    std.debug.print("AutoResetEvent created: {any}\n", .{lock});
    
    // Example usage:
    lock.signal();
    lock.wait();
    std.debug.print("AutoResetEvent test completed\n", .{});
}
