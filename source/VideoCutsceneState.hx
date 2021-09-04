/**
 * Apache License, Version 2.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import openfl.utils.Assets;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import webm.WebmPlayer;
import flixel.input.FlxInput.FlxInputState;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;

/**
 * This state will play a cutscene, then transition to a provided target state.
 * Acts kinda similarly to the LoadingState, but doesn't replace it!
 * 
 * DEPRECATED doesn't work in release for some reason.
 */
class VideoCutsceneState extends FlxUIState {

	/**
	 * The FlxState to transition to when the video is done.
	 */
	var target:FlxState;
  /**
   * The video to play with this state.
   */
  var videoPath:String;
  var audioPath:String;

	/**
	 * The FlxSprite containing the bitmap data of the video.
	 */
	public var videoSprite:FlxSprite;
  public var videoAudio:FlxSound;

	/**
	 * The WebM
	 */
	public static var webmHandler:WebmHandler;

  // TODO: Remove public from constructor.
	public function new(targetParam:FlxState, videoPathParam:String) {
    super();
    this.target = targetParam;
    this.videoPath = 'assets/videos/$videoPathParam.webm';
    this.audioPath = 'assets/videos/$videoPathParam.ogg';
  }
    
  override function create() {
    super.create();

    // Stop any previously playing ingame music for now.
    FlxG.sound.music.stop();

    // We need to initialize the video in the WebmHandler.
    initVideo();
    // We need to create a sprite to render the video output to.
    renderVideo();
    // Thankfully, when configured properly, WebMHandler will create
    // and output to a sound channel.
    playAudio();
  }

  /**
   * Initialize the WebM player and load our video for playback.
   */
  function initVideo() {
    // Initialize the WebMPlayer with a dummy video.
    var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		WebmPlayer.SKIP_STEP_LIMIT = 90;
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = "WebM Cutscene Player";

		GlobalVideo.setWebm(webmHandler);

    // TODO: Add check and throw error if video at path does not exist.

		GlobalVideo.get().source(videoPath);
    if (GlobalVideo.get() == null) trace('what why null');
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm) {
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm) {
			GlobalVideo.get().restart();
		} else {
			GlobalVideo.get().play();
		}
  }

  /**
   * The video is now "playing", in a static object that isn't tied to this scene.
   * Here we create a sprite which will render the bitmapData for the video.
   */
  function renderVideo() {
    // Extract the video data from the video.
    // This is a reference/pointer so it will be recurringly updated,
    // and thus the videoSprite will be continually re-rendered.
    var data = webmHandler.webm.bitmapData;
    // Initialize the video sprite with the video data.
		videoSprite = new FlxSprite(0, 0).loadGraphic(data, 1280, 720);
    videoSprite.scale.set(1,1);
    
    // Add the video sprite to the scene.
		add(videoSprite);
  }

  /**
   * We have to load and play the audio separately,
   * because the webm player doesn't work properly.
   */
  function playAudio() {
    // Fuck it, no error handling here for now.
    if (Assets.exists(audioPath, MUSIC) || Assets.exists(audioPath, SOUND)) {
      videoAudio = FlxG.sound.play(audioPath);
    }
  }

  /**
   * Update function called every frame.
   */
  override public function update(elapsed:Float) {
    super.update(elapsed);

    // Check if the video is over.
    if (GlobalVideo.get() != null) {
      if (GlobalVideo.get().ended) {
        onVideoComplete();
      }
    }
  }

  /**
   * Called when the video duration has elapsed.
   */
  function onVideoComplete() {
    // Cleanup the video.
    GlobalVideo.get().stop();
    remove(videoSprite);

    // Move to the assigned state.
    if (target != null) {
      FlxG.switchState(target);
    }
  }

  /**
   * Loads assets required for the current week, then plays the cutscene, then transitions to the target state,
   * usually an instance of PlayState().
   * @param target 
   * @param videoPath 
   */
  public static function loadAndPlayCutsceneAndSwitchState(target:FlxState, videoPath:String) {
    LoadingState.loadAndSwitchState(new VideoCutsceneState(target, videoPath), true);
  }
}