package funkin.util.macro;

import haxe.Exception;
import haxe.Json;
import haxe.io.Bytes;
#if FUNKIN_GIT_DETAILS
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.Process;
#end
import haxe.Http;
import haxe.ds.StringMap;

using StringTools;

class GitContributorMacro
{
  /**
   * Returns the percentage of commits done per contributor.
   * @return A map containing the username and the percentage.
   */
  public static macro function percentages():ExprOf<StringMap<Float>>
  {
    var percentages:StringMap<Float> = new StringMap<Float>();

    #if display
    // We don't wanna run `git` every single time the language server restarts.
    return macro $v{percentages};
    #end

    var commitEmails:Array<String> = logEmails();

    var usernames:Array<String> = [];
    var numerators:Array<Int> = [];
    var denominator:Int = 0;

    for (email in commitEmails)
    {
      var username:Null<String> = getUserFromEmail(email);

      if (username == null)
        continue;

      var usernameIndex:Int = usernames.indexOf(username);

      if (usernameIndex == -1)
      {
        usernameIndex = usernames.length;
        numerators[usernameIndex] = 0;
        usernames.push(username);
      }

      numerators[usernameIndex]++;

      denominator++;
    }

    for (i => username in usernames)
    {
      var percentage:Float = (numerators[i] ?? 0) / denominator;
      percentages.set(username, percentage);
    }

    return macro $v{percentages};
  }

  #if macro
  static function logEmails():Array<String>
  {
    var gitProcess:Process = new Process('git', ['--no-pager', 'log', '--format=%aE']);

    var bytes:Bytes = gitProcess.stdout.readAll();
    var exitCode:Int = gitProcess.exitCode();
    gitProcess.close();

    if (exitCode != 0 || bytes == null)
    {
      Context.warning('Unable to get current git contributors. Is this a proper GitHub repository?', Context.currentPos());
      return [];
    }

    var emailList:String = bytes.toString().trim();
    return emailList.split('\n');
  }

  static function getUserFromEmail(email:String):Null<String>
  {
    var username:Null<String> = FunkinMacroCache.cache.get('userFromEmail_${email}');

    if (username != null)
      return username;

    if (!email.endsWith('@users.noreply.github.com'))
    {
      try
      {
        var firstItem:Dynamic = getFirstFromGitHubSearch('users', email, 'joined');
        username = firstItem.login;
      }
      catch (e:Exception)
      {
        try
        {
          var firstItem:Dynamic = getFirstFromGitHubSearch('commits', 'author-email:${email}', 'author-date');
          username = firstItem.author?.login;
        }
        catch (e:Exception)
        {
          trace('Could not get GitHub username from the email "${email}". (${e.message})');
        }
      }
    }
    else
    {
      var plusIndex:Int = email.indexOf('+') + 1;
      var atIndex:Int = email.lastIndexOf('@');
      username = email.substring(plusIndex, atIndex);
    }

    FunkinMacroCache.cache.set('userFromEmail_${email}', username);

    return username;
  }

  static function getFirstFromGitHubSearch(endpoint:String, query:String, sortBy:String):Dynamic
  {
    var link:String = 'https://api.github.com/search/${endpoint}';

    link += '?q=${query.urlEncode()}';
    link += '&sort=${sortBy.urlEncode()}';
    link += '&per_page=1';

    var status:Null<Int> = null;
    var response:Null<String> = null;

    var httpRequest:Http = new Http(link);
    httpRequest.setHeader("Accept", "application/vnd.github+json");
    httpRequest.setHeader("User-Agent", "TechNotDrip-Engine");

    httpRequest.onStatus = (code:Int) -> status = code;
    httpRequest.onData = (data:String) -> response = data;
    httpRequest.request();

    if (status >= 400)
    {
      if (status == 403)
      {
        throw new Exception('Exceeded GitHub rate limit!');
      }

      throw new Exception('HTTP Error Code ${status}');
    }

    try
    {
      var responseData:Dynamic = Json.parse(response);

      if (responseData.items == null || responseData.items.length < 1)
        throw new Exception('No items in request');

      return responseData.items[0];
    }
  }
  #end
}
#end
