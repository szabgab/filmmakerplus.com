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
       ytplayer.cueVideoById('DWW4vL_Zq_U');
   }
}
