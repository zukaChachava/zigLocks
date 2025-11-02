const std = @import("std");

pub const AutoResetEvent = struct {
    original: usize,
    count: usize,
    mutex: std.Thread.Mutex,
    condition: std.Thread.Condition,

    const Self = @This();

    pub fn init(count: usize) Self {
        return .{
            .original = count,
            .count = count,
            .mutex = std.Thread.Mutex{},
            .condition = std.Thread.Condition{}
        };
    }

    pub fn wait(self: *Self) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        while(self.count != 0){
            self.condition.wait(&self.mutex);

            if(self.count == 0){
                reset(self);
                break;
            }
        }
    }

    pub fn timedWait(self: *Self, timeout_ns: u64) error{Timeout}!void{
        self.mutex.lock();
        defer self.mutex.unlock();

        while(self.count != 0){
            try self.condition.timedWait(&self.mutex, timeout_ns);
        
            if(self.count == 0){
                reset(self);
                break;
            }
        }
    }

    pub fn signal(self: *Self) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        if(self.count == 0){
            unreachable;
        }

        self.count = self.count - 1;
        self.condition.signal();
    }

    // Info: lock is not required due to internal use
    fn reset(self: *Self) void{
        self.count = self.original;
    }
};