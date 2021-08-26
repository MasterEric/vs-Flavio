import flixel.FlxG;

class TimingStruct
{
    public static var AllTimings:Array<TimingStruct> = [];

    /**
     * The BPM during this timing.
     */
    public var bpm:Float = 0; // idk what does  this do

    /**
     * The beat number where this struct starts applying.
     */
    public var startBeat:Float = 0; // BEATS
    /**
     * The step number where this struct starts applying.
     */
    public var startStep:Int = 0; // BAD MEASUREMENTS
    /**
     * The time in seconds where this starts applying.
     */
    public var startTime:Float = 0; // SECONDS
    /**
     * The beat number where this struct stop applying.
     */
    public var endBeat:Float = Math.POSITIVE_INFINITY; // BEATS
    /**
     * The length of this struct in beats.
     */
    public var length:Float = Math.POSITIVE_INFINITY; // in beats

    public static function clearTimings()
    {
        AllTimings = [];
    }

    public static function addTiming(startBeat,bpm,endBeat:Float, offset:Float)
    {
        var pog = new TimingStruct(startBeat,bpm,endBeat, offset);
        AllTimings.push(pog);
    }

    public static function getBeatFromTime(time:Float)
    {
        var beat = -1.0;
        var seg = TimingStruct.getTimingAtTimestamp(time);

        if (seg != null)
            beat = seg.startBeat + (((time / 1000) - seg.startTime) * (seg.bpm / 60));

        return beat;
    }

    public static function getTimeFromBeat(beat:Float)
    {
        var time = -1.0;
        var seg = TimingStruct.getTimingAtBeat(beat);

        if (seg != null)
            time = seg.startTime + ((beat - seg.startBeat) / (seg.bpm / 60));

        return time * 1000;
    }


    public function new(startBeat:Float,bpm:Float,endBeat:Float, offset:Float)
    {
        this.bpm = bpm;
        this.startBeat = startBeat;
        if (endBeat != -1)
            this.endBeat = endBeat;
        startTime = offset;
    }

    public static function getTimingAtTimestamp(msTime:Float):TimingStruct
    {
        for(i in AllTimings)
        {
            if (msTime >= i.startTime * 1000 && msTime < (i.startTime + i.length) * 1000)
                return i;
        }
        return null;
    }

    public static function getTimingAtBeat(beat):TimingStruct
    {
        for(i in AllTimings)
        {
            if (i.startBeat <= beat && i.endBeat >= beat)
                return i;
        }
        return null;
    }
}
