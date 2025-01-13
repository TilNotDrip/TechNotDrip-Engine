package funkin;

#if !macro
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.data.save.Save;
import funkin.objects.FunkinSprite.FunkinSpriteGroup;
import funkin.objects.FunkinSprite;
import funkin.util.FunkinSpriteUtil;
import funkin.util.MathUtil;
import funkin.util.ReflectUtil;
import funkin.util.SystemUtil;
import funkin.util.paths.Paths;
import haxe.Exception;
import thx.semver.Version;
import thx.semver.VersionRule;

using Lambda;
using StringTools;

#if FUNKIN_DISCORD_RPC
import funkin.api.DiscordRPC;
#end
#end
