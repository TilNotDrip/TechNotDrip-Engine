package funkin.substates;

import flixel.FlxCamera;
import flixel.util.FlxGradient;
import flixel.util.typeLimit.NextState;

class FunkinTransition extends FunkinSubState
{
	/**
	 * If the next transition in should be skipped.
	 */
	public static var skipNextTransitionIn:Bool = false;

	/**
	 * If the next transition out should be skipped.
	 */
	public static var skipNextTransitionOut:Bool = false;

	/**
	 * The function to call when the transition is finished. (This is usually taken from onOutroComplete)
	 */
	public var onCompletion:() -> Void = null;

	/**
	 * If this instance is transitioning in or out.
	 */
	public var transOut:Bool = false;

	var transitionCamera:FlxCamera;

	public function new(transOut:Bool, ?onCompletion:() -> Void = null)
	{
		this.onCompletion = onCompletion;
		this.transOut = transOut;
		super();

		transitionCamera = new FlxCamera();
		transitionCamera.bgColor = 0;
		FlxG.cameras.add(transitionCamera, false);
		cameras = [transitionCamera];
	}

	override public function create():Void
	{
		if ((!transOut && skipNextTransitionIn) || (transOut && skipNextTransitionOut))
		{
			if ((!transOut && skipNextTransitionIn))
				skipNextTransitionIn = false;
			else if (transOut && skipNextTransitionOut)
				skipNextTransitionOut = false;

			complete();
			return;
		}

		var gradient:FlxSprite = FlxGradient.createGradientFlxSprite(transitionCamera.width, transitionCamera.height, [0xFF000000, 0x0]);
		gradient.flipY = transOut;
		add(gradient);

		var black:FunkinSprite = new FunkinSprite(0, transOut ? transitionCamera.height : -transitionCamera.height);
		black.loadTexture('#000000', transitionCamera.width, transitionCamera.height);
		add(black);

		super.create();

		transitionCamera.scroll.y = transitionCamera.height;
		FlxTween.tween(transitionCamera.scroll, {y: -transitionCamera.height}, 0.6, {onComplete: (_) -> complete()});
	}

	/**
	 * When the transition is complete.
	 */
	public function complete():Void
	{
		if (onCompletion != null)
			onCompletion();
		else
			close();
	}
}
