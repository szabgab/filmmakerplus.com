function onYouTubePlayerReady(playerId) {
      ytplayer = document.getElementById("myytplayer");
	  ytplayer.addEventListener("onStateChange", "onytplayerStateChange");
	  //alert('loaded');
	  //ytplayer.cuePlaylist('I2rb0L5P2ME', 'DWW4vL_Zq_U');
}

function onytplayerStateChange(newState) {
   //alert("Player's new state: " + newState);
   ytplayer = document.getElementById("myytplayer");
   if (newState == 0) {
	var before = ytplayer.getVideoUrl();
	//alert(before);
    var after = before.replace(/.*v=(\w*)/, "$1");
	//alert(after);
    ytplayer.cueVideoById(after);
    //ytplayer.cueVideoByUrl(ytplayer.getVideoUrl());
   }
}
