package funkin.fs;

import hxd.fs.FileSystem;

// TODO: Redo the File System entirely once we have Polymod set up.
// File Merging should also happen here.
class FunkinFileSystem implements FileSystem
{
  @:allow(funkin.Paths)
  var child:Null<FileSystem>;

  public function new(?child:Null<FileSystem>)
  {
    this.child = child;
  }

  public function getRoot():FileEntry
  {
    return getChild().getRoot();
  }

  public function get(path:String):FileEntry
  {
    return getChild().get(path);
  };

  public function exists(path:String):Bool
  {
    return getChild().exists(path);
  }

  public function dir(path:String):Array<FileEntry>
  {
    return getChild().dir(path);
  }

  public function delete(path:String):Bool
  {
    return getChild().delete(path);
  }

  public function dispose():Void
  {
    child.dispose();
    child = null;
  }

  function getChild():FileSystem
  {
    if (child == null)
      throw 'FunkinFileSystem is currently not set up.';

    return child;
  }
}
