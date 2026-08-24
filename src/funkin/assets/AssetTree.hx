package funkin.assets;

import hxd.fs.FileSystem;
import hxd.fs.NotFound;

class AssetTree
{
  var tree:Array<AssetLibrary>;

  public function new()
  {
    tree = [];
  }

  /**
   * Fetches a file from the asset tree.
   * @param path The path to the file.
   * @return The `FileEntry`, if it exists.
   */
  public function get(path:String):FileEntry
  {
    for (library in tree)
    {
      if (library.fileSystem.exists(path))
        return library.fileSystem.get(path);
    }

    throw new NotFound(path);
  }

  /**
   * Checks if a file exists in the asset tree.
   * @param path The path to check.
   * @return If the file exists, or not.
   */
  public function exists(path:String):Bool
  {
    for (library in tree)
    {
      if (library.fileSystem.exists(path))
        return true;
    }

    return false;
  }

  /**
   * Fetches a file from a specific namespace in the asset tree.
   * @param path The path to the file.
   * @param namespace The namespace to fetch from.
   * @return The `FileEntry`, if it exists.
   */
  public function getFromNamespace(path:String, namespace:String):FileEntry
  {
    for (library in tree)
    {
      if (library.namespace != namespace)
        continue;

      return library.fileSystem.get(path);
    }

    throw new NotFound(path);
  }

  /**
   * Checks if a file exists for a specific namespace in the asset tree.
   * @param path The path to check.
   * @param namespace The namespace to check.
   * @return If the file exists, or not.
   */
  public function existsInNamespace(path:String, namespace:String):Bool
  {
    for (library in tree)
    {
      if (library.namespace != namespace)
        continue;

      return library.fileSystem.exists(path);
    }

    return false;
  }

  /**
   * Fetches the namespace from a path.
   * @param path The path to use.
   * @return The namespace, if found.
   */
  public function getNamespaceFromPath(path:String):Null<String>
  {
    for (library in tree)
    {
      if (library.fileSystem.exists(path))
        return library.namespace;
    }

    return null;
  }

  /**
   * Fetches all namespaces.
   * @return List of all namespaces.
   */
  public function getNamespaces():Array<String>
  {
    return tree.map(library -> library.namespace);
  }

  /**
   * Adds a file system to the tree.
   * @param namespace The namespace of this file system.
   * @param fileSystem The file system.
   */
  public function add(namespace:String, fileSystem:FileSystem):Void
  {
    tree.insert(0, {namespace: namespace, fileSystem: fileSystem});
  }
}

typedef AssetLibrary =
{
  var namespace:String;
  var fileSystem:FileSystem;
};
