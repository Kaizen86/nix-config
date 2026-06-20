{ lib, ... }:

# TODO: Use asserts to validate function inputs

{  # Filter names from an attribute set where the predicate (n: v: ...) returns true.
  filterAttrNames = (pred: set:
    let filteredAttrs = lib.filterAttrs pred set;
    in builtins.attrNames filteredAttrs
  );
}
