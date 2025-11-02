const std = @import("std");

pub const ManualResetEvent = struct {
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
        }
    }

    pub fn timedWait(self: *Self, timeout_ns: u64) error{Timeout}!void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        while(self.count != 0){
            try self.condition.timedWait(&self.mutex, timeout_ns);
        }
    }

    pub fn signal(self: *Self) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        
        if(self.count == 0){
            return;
        }

        self.count = self.count - 1;

        if(self.count == 0){
            self.condition.broadcast();
        }
    }

    pub fn reset(self: *Self) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.count = self.original;
    }

    pub fn hasReleased(self: *Self) bool {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.count == 0;
    }
};