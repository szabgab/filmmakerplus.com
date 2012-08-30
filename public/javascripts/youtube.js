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

function displayVideo(id) {
    var params = { allowScriptAccess: "always" };
    var atts = { id: "myytplayer" };
    swfobject.embedSWF("http://www.youtube.com/v/" + id + "?enablejsapi=1&playerapiid=ytplayer&version=3",
                       "ytapiplayer", "853", "480", "8", null, null, params, atts);
}


