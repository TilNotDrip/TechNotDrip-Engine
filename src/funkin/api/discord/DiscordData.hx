package funkin.api.discord;

#if FUNKIN_DISCORD_RPC
/**
 * Discord Configuration.
 */
typedef DiscordData =
{
  var id:String;

  @:optional
  var iconKey:String;
}
#end
