import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import crashdumper.CrashDumper;
import crashdumper.SessionData;

#if (windows || mac || linux)
	import openfl.events.UncaughtErrorEvent;
#elseif flash
	import flash.events.UncaughtErrorEvent;
#end

#if openfl_legacy
	import openfl.utils.SystemPath;
#else
	import lime.app.Application;
	typedef SystemPath = lime.system.System;
#end

/**
 * Handles the CrashDumper library.
 */
class CrashHandler {
  /**
   * Generates the URL for the location to report crashes to.
   * This allows for automated telemetry in the event of a fatal error.
   * 
   * @see: https://github.com/larsiusprime/crashdumper/tree/master/servers
   */
  static final TELEMETRY_SERVER = "http://localhost:8080/result";
  /**
   * Whether to collect system data in crash reports.
   * It lets you see client OS, RAM, CPU details, and GPU details.
   * 
   * This causes some cmd windows to popup on launch,
   * set this to false to get rid of those (but also make logs less useful).
   */
  static final SHOULD_COLLECT_SYSTEM_DATA = true;
  /**
   * Whether the game should close after a crash is handled.
   * If this is true, the game will close to desktop if an unhandled error occurs,
   * but if this is false, who knows what will happen?
   */
  static final KILL_ON_CRASH = true;

  /**
   * Private constructor to prevent unintentional initialization of this utility class.
   */
  function new() {}

  /**
   * Listens for uncaught error events and then generates a comprehensive crash report.
   * All you need to do is to call this, preferably at the beginning of your app, and you only need one.
   */
  public static function initCrashHandler() {
    /**
     * Generates the path for the location to put log files.
     * This code puts it into a log folder next to the EXE;
     * the default is in the AppData folder where saves are stored.
     */
    var logLocation = Path.join([Path.directory(Sys.programPath()), "log/crash"]);
    /**
     * Generates a unique ID to be used by the potential log file's destination path.
     */
    var uniqueId = SessionData.generateID("KadeEngine_");

    // Initialize the crash handler. It'll automatically work in the background.
    var crashDumper = new CrashDumper(uniqueId, logLocation, TELEMETRY_SERVER,
      true, SHOULD_COLLECT_SYSTEM_DATA, preCrashDump, postCrashDump);

    // Print the log location.
    trace('CrashHandler activated. If the game crashes, check "${logLocation}"');
  }

  /**
   * This event function is called before a crash happens.
   */
  static function preCrashDump(crashDumper:CrashDumper) {
    /**
     * Generate additional data before writing the crash report.
     */

    // Add save data to the crash report.
    crashDumper.session.files.set("save.data", "Asmoranomardicadastinaculdacar");

    // Add engine version data to the crash report.
    var fullGameVersion = 'Friday Night Funkin version: ${MainMenuState.gameVer}';
    fullGameVersion += '\nKade Engine version: ${MainMenuState.kadeEngineVer}';
    crashDumper.session.files.set("version.log", fullGameVersion);
  }

  /**
   * This event function is called after a crash happens,
   * but only if KILL_ON_CRASH is set to false.
   */
  static function postCrashDump() {}

  /**
   * Intentionally crash the game. This can be used to test the CrashHandler.
   */
  public static function intentionalCrash() {
		// Pick your poison:
		
		nullReference();
		//invalidCast();
		//stackOverflow(0);
		//memoryLeak();
		//infiniteLoop();
	}
	
	/**
   * Intentionally cause a memory error by creating an infinite loop.
	 */
  private static function infiniteLoop():Void {
   while (true) {
     doNothing();
    }
  }
  private static function doNothing():Void {}
	
	/**
	 * Intentionally cause a memory error by attempting to access a null object.
	 */
	private static function nullReference():Void {
		var b:BitmapData = null;
		b.clone();
	}
	
  /**
	 * Intentially cause a stack overflow by infinitely calling a recursive function.
	 */
	private static function stackOverflow(X:Int):Int {
		return 1 + stackOverflow(X);
	}
	
	/**
	 * Intentionally cause a memory leak by creating an infinitely large array.
	 */
	private static function memoryLeak():Void {
		var a:Array<Int> = [1, 2, 3];
		while (true) {
			a.push(123);
		}
	}
	
	/**
	 * Intentionally cause a crash by attempting to cast an object to an incompatible type.
	 */
	private static function invalidCast():Void {
		var crazy:Map<String, Array<Bool>> = new Map<String, Array<Bool>>();
		var sprite:Sprite = cast(crazy, Sprite);
	}
}