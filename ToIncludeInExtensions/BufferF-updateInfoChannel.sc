// Mise à jour vers OSCFunc

+ Buffer {
	*readFAndQueryChannel { arg server,path,startFrame = 0,numFrames = -1, channel, completionFunc, timeout;
		var new, buf;
		server = server ? Server.local;
		new = super.newCopyArgs(server,
						buf = server.bufferAllocator.alloc(1),
						numFrames);
			// go do it!
		BufferFQueryQueueChannel.add(server, path, startFrame, numFrames, channel, completionFunc, new, timeout);
		^new		// object won't be fully ready until queue finishes, but you can have it now
	}
}