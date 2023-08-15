let
  inherit (builtins)
    attrNames
    filter
    hasAttr
    head
    isAttrs
    listToAttrs
    map
    match
    readDir
    substring
  ;

  readTree = args:
    let
      tree = readTreeImpl args;
    in
    if tree ? skip
    then throw "Top-level folder has a .skip-tree marker and could not be read by readTree!"
    else tree.ok;

  readTreeImpl = { initPath, rootDir }:
    let
      dir = readDirVisible initPath;

      skipTree = hasAttr ".skip-tree" dir;
      skipSubtree = skipTree || hasAttr ".skip-subtree" dir;

      joinChild = child: initPath + ("/" + child);

      self =
        if rootDir
        then {}
        else { __functor = _: import initPath; };

      filterDir = f: dir."${f}" == "directory";
      filteredChildren = map
        (child: {
          name = child;
          value = readTreeImpl {
            initPath = joinChild child;
            rootDir = false;
          };
        })
        (filter filterDir (attrNames dir));

      children =
        if skipSubtree then []
        else map
          ({ name, value }: { inherit name; value = value.ok; })
          (filter (child: child.value ? ok) filteredChildren);

      nixFiles =
        if skipSubtree then []
        else filter (f: f != null) (map nixFileName (attrNames dir));
      nixChildren = map
        (child:
          let
            childPath = joinChild (child + ".nix");
          in {
            name = child;
            value = import childPath;
          })
        nixFiles;

      nodeValue = if dir ? "default.nix" then self else {};

      allChildren = listToAttrs (
        if dir ? "default.nix"
        then children
        else nixChildren ++ children
      );

    in
    if skipTree
    then { skip = true; }
    else {
      ok =
        if isAttrs nodeValue
        then nodeValue // allChildren
        else nodeValue;
    };

  readDirVisible = path:
    let
      children = readDir path;
      isVisible = f: f == ".skip-subtree" || f == ".skip-tree" || (substring 0 1 f) != ".";
      names = filter isVisible (attrNames children);
    in
    listToAttrs (map
      (name: {
        inherit name;
        value = children.${name};
      })
      names);

  nixFileName = file:
    let res = match "(.*)\\.nix" file;
    in if res == null then null else head res;

in {
  inherit
    nixFileName
    readDirVisible
    readTree
    readTreeImpl
  ;

  __functor = _: { path }:
    readTree {
      initPath = path;
      rootDir = true;
    };
}
