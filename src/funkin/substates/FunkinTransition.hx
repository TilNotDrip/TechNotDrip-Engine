package funkin.substates;

import flixel.FlxCamera;
import flixel.util.FlxGradient;
import flixel.util.typeLimit.NextState;

class FunkinTransition extends FunkinSubState
{
	/**
	 * The `FunkinTransition` instance.
	 */
	public static var instance:FunkinTransition;

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
	 * (Internal) The Transition Gradient.
	 */
	var transGradient:FlxSprite;

	/**
	 * (Internal) The black texture that hides the state behind.
	 */
	var black:FunkinSprite;

	/**
	 * (Internal) Tells FunkinTransition if it can destroy its instance.
	 */
	var canDestroy:Bool = false;

	/**
	 * (Internal) The camera where everything happens.
	 */
	var transitionCamera:FlxCamera;

	public function new()
	{
		instance = this;
		super();

		initCamera();

		transGradient = FlxGradient.createGradientFlxSprite(transitionCamera.width, transitionCamera.height, [0xFF000000, 0x0]);

		black = new FunkinSprite(0, 0);
		black.loadTexture('#000000', transitionCamera.width, transitionCamera.height);
	}

	override public function create()
	{
		super.create();

		add(transGradient);
		add(black);
	}

	/**
	 * Starts the transition in.
	 */
	public function startTransIn():Void
	{
		// So next transition can be the same instance!
		canDestroy = false;

		initCamera();

		transGradient.flipY = false;
		black.y = -transitionCamera.height;

		transitionCamera.scroll.y = transitionCamera.height;
		FlxTween.tween(transitionCamera.scroll, {y: -transitionCamera.height}, 0.6, {onComplete: (_) -> complete()});
	}

	/**
	 * Starts the transition out.
	 */
	public function startTransOut():Void
	{
		// Throw it away like my firstborn when they turned 18!
		canDestroy = true;

		initCamera();

		transGradient.flipY = true;
		black.y = transitionCamera.height;

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

	function initCamera():Void
	{
		if (transitionCamera != null && transitionCamera.flashSprite != null)
			return;

		transitionCamera = new FlxCamera();
		transitionCamera.bgColor = 0;
		FlxG.cameras.add(transitionCamera, false);
		cameras = [transitionCamera];
	}

	override public function destroy():Void
	{
		if (canDestroy)
			return super.destroy();
	}
}
