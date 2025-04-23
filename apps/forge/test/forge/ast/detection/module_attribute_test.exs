defmodule Forge.Ast.Detection.ModuleAttributeTest do
  alias Forge.Ast.Detection

  use Forge.Test.DetectionCase,
    for: Detection.ModuleAttribute,
    assertions: [
      [:module_attribute, :*],
      [:callbacks, :*]
    ],
    skip: [
      [:doc, :*],
      [:module_doc, :*],
      [:spec, :*],
      [:type, :*]
    ],
    variations: [:module]
end
