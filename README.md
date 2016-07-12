# VideoPlayer
Video Player with no delay when change video.

# The idea for make feeling like playing 1 vide
To play video i'm using AVPlayer. When we play multiple videos and play sequentially, there is a gap when switch video.
The idea to make feeling like playing 1 video is:
When play current item, we will use other AVPlayer to preload next video. 
After that, when start to play next video, we just need check if the current preload player is ready, swap it with current player and make current player become preload player, if not just replace current video with next video like normal.
So we will have maximum two players: one for play and one for preload.

# How did we do that

#H1 Create preload AVPlayer

    self.preloadPlayerItem = [AVPlayerItem playerItemWithAsset:nextAsset];
    if (!self.preloadAVPlayer) {
        self.preloadAVPlayer = [[AVPlayer alloc] initWithPlayerItem:_preloadPlayerItem];
    } else {
        [self.preloadAVPlayer replaceCurrentItemWithPlayerItem:_preloadPlayerItem];
    }



#